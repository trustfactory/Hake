local Utility = require("Utility")
local OrlandoDoom = {}

OrlandoDoom.optionEnable = Menu.AddOption({"Hero Specific","Doom"},"1. Enabled","Enable Or Disable Doom Combo Script")
OrlandoDoom.optionAutoDoom = Menu.AddOption({"Hero Specific", "Doom"}, "2. Auto Doom", "Auto cast 'Doom' to interrupt channelled ult")
OrlandoDoom.optionToggleKey = Menu.AddKeyOption({"Hero Specific", "Doom"}, "3. Auto Doom Toggle Key", Enum.ButtonCode.KEY_S)
OrlandoDoom.optionKey = Menu.AddKeyOption({"Hero Specific","Doom"},"4. Non-Ult Combo Key",Enum.ButtonCode.KEY_D)
OrlandoDoom.optionKey2 = Menu.AddKeyOption({"Hero Specific","Doom"},"5. Ult Combo Key",Enum.ButtonCode.KEY_F)
OrlandoDoom.optionBlink = Menu.AddOption({"Hero Specific", "Doom" }, "6. Use Blink to Initiate {{Doom}}", "")
OrlandoDoom.optionBlinkRange = Menu.AddOption({"Hero Specific", "Doom" }, "7. Set Safe Blink Initiation Range {{Doom}}", "150 Range is Doom's Base Attack Range", 100, 500, 25)
--Skills Toggle Menu--
OrlandoDoom.optionEnableScorched = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"1. Use Scorched Earth","Enable Or Disable")
OrlandoDoom.optionEnableInfernal = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"2. Use Infernal Blade","Enable Or Disable")
OrlandoDoom.optionEnableUlt = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"3. Use Doom Ult","Enable Or Disable")
OrlandoDoom.optionEnableCreepIceArmor = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"4. Use Creep Ice Armor","Enable Or Disable")
OrlandoDoom.optionEnableCreepKentStun = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"4.1. Use Creep Kent Stun","Enable Or Disable")
OrlandoDoom.optionEnableCreepManaburn = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"4.2. Use Creep Manaburn","Enable Or Disable")
OrlandoDoom.optionEnableCreepNet = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"4.3. Use Creep Net","Enable Or Disable")
OrlandoDoom.optionEnableCreepRockStun = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"4.4. Use Creep Rock Stun","Enable Or Disable")
OrlandoDoom.optionEnableCreepShock = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"4.5. Use Creep Lightning","Enable Or Disable")
OrlandoDoom.optionEnableCreepSWave = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"4.6. Use Creep Shock Wave","Enable Or Disable")
OrlandoDoom.optionEnableCreepTClap = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"4.7. Use Creep ThunderClap","Enable Or Disable")
OrlandoDoom.optionEnableProwlerStomp = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"5. Use Ancient Prowler Stomp","Enable Or Disable")
OrlandoDoom.optionEnableThunderFrenzy = Menu.AddOption({"Hero Specific","Doom","8. Skills"},"5.1. Use Ancient Lizard Frenzy","Enable Or Disable")
--Items Toggle Menu--
OrlandoDoom.optionEnableHalberd = Menu.AddOption({"Hero Specific","Doom","9. Items"},"1. Use Halberd","Turn On/Off Halberd in Combo")
OrlandoDoom.optionEnableScythe = Menu.AddOption({"Hero Specific","Doom","9. Items"},"2. Use Scythe","Turn On/Off Scythe in Combo")
OrlandoDoom.optionEnableShadowBlade = Menu.AddOption({"Hero Specific", "Doom","9. Items"},"3. Use Shadow Blade","Turn On/Off Shadow Blade in Combo")
OrlandoDoom.optionEnableShivas = Menu.AddOption({"Hero Specific","Doom","9. Items"},"4. Use Shivas","Turn On/Off Shivas in Combo")
OrlandoDoom.optionEnableSilverEdge = Menu.AddOption({"Hero Specific", "Doom","9. Items"},"5. Use Silver Edge","Turn On/Off Silver Edge in Combo")

local AutoMode = false
local font = Renderer.LoadFont("Copperplate Gothic Bold", 27, Enum.FontWeight.EXTRABOLD)

OrlandoDoom.lastTick = 0
OrlandoDoom.delay = 0
OrlandoDoom.lastAttackTime = 0
OrlandoDoom.lastAttackTime2 = 0
OrlandoDoom.LastTarget = nil

function OrlandoDoom.ResetGlobalVariables()
    OrlandoDoom.lastTick = 0
	OrlandoDoom.delay = 0
	OrlandoDoom.lastAttackTime = 0
	OrlandoDoom.lastAttackTime2 = 0
	OrlandoDoom.LastTarget = nil
end

function OrlandoDoom.OnUpdate()
	local myHero = Heroes.GetLocal()
    if not myHero then return end
    
    if not Menu.IsEnabled(OrlandoDoom.optionEnable) then return true end
	if Menu.IsKeyDown(OrlandoDoom.optionKey) then
    OrlandoDoom.Combo()
	end
	
	if not Menu.IsEnabled(OrlandoDoom.optionEnable) then return true end
	if Menu.IsKeyDown(OrlandoDoom.optionKey2) then
    OrlandoDoom.UltCombo()
	end
	
	if Menu.IsKeyDownOnce(OrlandoDoom.optionToggleKey) then
    	AutoMode = not AutoMode
	end

	if Menu.IsEnabled(OrlandoDoom.optionAutoDoom) and AutoMode then
    	OrlandoDoom.AutoDoom(myHero)
	end
	
	if not Engine.IsInGame() then
	OrlandoDoom.ResetGlobalVariables()
	end
end	

function OrlandoDoom.castPrediction(myHero, enemy, adjustmentVariable)

	if not myHero then return end
	if not enemy then return end

	local enemyRotation = Entity.GetRotation(enemy):GetVectors()
		enemyRotation:SetZ(0)
    	local enemyOrigin = NPC.GetAbsOrigin(enemy)
		enemyOrigin:SetZ(0)

	if enemyRotation and enemyOrigin then
			if not NPC.IsRunning(enemy) then
				return enemyOrigin
			else return enemyOrigin:__add(enemyRotation:Normalized():Scaled(OrlandoDoom.GetMoveSpeed(enemy) * adjustmentVariable))
			end
	end
end

function OrlandoDoom.GetMoveSpeed(enemy)

	if not enemy then return end

	local base_speed = NPC.GetBaseSpeed(enemy)
	local bonus_speed = NPC.GetMoveSpeed(enemy) - NPC.GetBaseSpeed(enemy)
	local modifierHex
    	local modSheep = NPC.GetModifier(enemy, "modifier_sheepstick_debuff")
    	local modLionVoodoo = NPC.GetModifier(enemy, "modifier_lion_voodoo")
    	local modShamanVoodoo = NPC.GetModifier(enemy, "modifier_shadow_shaman_voodoo")

	if modSheep then
		modifierHex = modSheep
	end
	if modLionVoodoo then
		modifierHex = modLionVoodoo
	end
	if modShamanVoodoo then
		modifierHex = modShamanVoodoo
	end

	if modifierHex then
		if math.max(Modifier.GetDieTime(modifierHex) - GameRules.GetGameTime(), 0) > 0 then
			return 140 + bonus_speed
		end
	end

    	if NPC.HasModifier(enemy, "modifier_invoker_ice_wall_slow_debuff") then 
		return 100 
	end

	if NPC.HasModifier(enemy, "modifier_invoker_cold_snap_freeze") or NPC.HasModifier(enemy, "modifier_invoker_cold_snap") then
		return (base_speed + bonus_speed) * 0.5
	end

	if NPC.HasModifier(enemy, "modifier_spirit_breaker_charge_of_darkness") then
		local chargeAbility = NPC.GetAbility(enemy, "spirit_breaker_charge_of_darkness")
		if chargeAbility then
			local specialAbility = NPC.GetAbility(enemy, "special_bonus_unique_spirit_breaker_2")
			if specialAbility then
				 if Ability.GetLevel(specialAbility) < 1 then
					return Ability.GetLevel(chargeAbility) * 50 + 550
				else
					return Ability.GetLevel(chargeAbility) * 50 + 1050
				end
			end
		end
	end
			
    	return base_speed + bonus_speed
end

function OrlandoDoom.isHeroChannelling(myHero)

	if not myHero then return true end

	if NPC.IsChannellingAbility(myHero) then return true end
	if NPC.HasModifier(myHero, "modifier_teleporting") then return true end

	return false
end

function OrlandoDoom.heroCanCastItems(myHero)

	if not myHero then return false end
	if not Entity.IsAlive(myHero) then return false end

	if NPC.IsStunned(myHero) then return false end
	if NPC.HasModifier(myHero, "modifier_bashed") then return false end
	if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end	
	if NPC.HasModifier(myHero, "modifier_eul_cyclone") then return false end
	if NPC.HasModifier(myHero, "modifier_obsidian_destroyer_astral_imprisonment_prison") then return false end
	if NPC.HasModifier(myHero, "modifier_shadow_demon_disruption") then return false end	
	if NPC.HasModifier(myHero, "modifier_invoker_tornado") then return false end
	if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_HEXED) then return false end
	if NPC.HasModifier(myHero, "modifier_legion_commander_duel") then return false end
	if NPC.HasModifier(myHero, "modifier_axe_berserkers_call") then return false end
	if NPC.HasModifier(myHero, "modifier_winter_wyvern_winters_curse") then return false end
	if NPC.HasModifier(myHero, "modifier_bane_fiends_grip") then return false end
	if NPC.HasModifier(myHero, "modifier_bane_nightmare") then return false end
	if NPC.HasModifier(myHero, "modifier_faceless_void_chronosphere_freeze") then return false end
	if NPC.HasModifier(myHero, "modifier_enigma_black_hole_pull") then return false end
	if NPC.HasModifier(myHero, "modifier_magnataur_reverse_polarity") then return false end
	if NPC.HasModifier(myHero, "modifier_pudge_dismember") then return false end
	if NPC.HasModifier(myHero, "modifier_shadow_shaman_shackles") then return false end
	if NPC.HasModifier(myHero, "modifier_techies_stasis_trap_stunned") then return false end
	if NPC.HasModifier(myHero, "modifier_storm_spirit_electric_vortex_pull") then return false end
	if NPC.HasModifier(myHero, "modifier_tidehunter_ravage") then return false end
	if NPC.HasModifier(myHero, "modifier_windrunner_shackle_shot") then return false end
	if NPC.HasModifier(myHero, "modifier_item_nullifier_mute") then return false end

	return true	
end

function OrlandoDoom.IsInAbilityPhase(myHero)

	if not myHero then return false end

	local myAbilities = {}

	for i= 0, 10 do
		local ability = NPC.GetAbilityByIndex(myHero, i)
		if ability and Entity.IsAbility(ability) and Ability.GetLevel(ability) > 0 then
			table.insert(myAbilities, ability)
		end
	end

	if #myAbilities < 1 then return false end

	for _, v in ipairs(myAbilities) do
		if v then
			if Ability.IsInAbilityPhase(v) then
				return true
			end
		end
	end

	return false
end

function OrlandoDoom.Debugger(time, npc, ability, order)

	if not Menu.IsEnabled(OrlandoDoom.optionEnable) then return end
	Log.Write(tostring(time) .. " " .. tostring(NPC.GetUnitName(npc)) .. " " .. tostring(ability) .. " " .. tostring(order))
end

function OrlandoDoom.GenericMainAttack(myHero, attackType, target, position)
	
	if not myHero then return end
	if not target and not position then return end

	if OrlandoDoom.isHeroChannelling(myHero) == true then return end
	if OrlandoDoom.heroCanCastItems(myHero) == false then return end
	if OrlandoDoom.IsInAbilityPhase(myHero) == true then return end

	if Menu.IsEnabled(OrlandoDoom.optionEnable) then
		if target ~= nil then
			OrlandoDoom.GenericAttackIssuer(attackType, target, position, myHero)
		end
	else
		OrlandoDoom.GenericAttackIssuer(attackType, target, position, myHero)
	end
end

function OrlandoDoom.GenericAttackIssuer(attackType, target, position, npc)

	if not npc then return end
	if not target and not position then return end
	if os.clock() - OrlandoDoom.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= OrlandoDoom.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				OrlandoDoom.LastTarget = target
				OrlandoDoom.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= OrlandoDoom.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					OrlandoDoom.LastTarget = position:__tostring()
					OrlandoDoom.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= OrlandoDoom.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				OrlandoDoom.LastTarget = position:__tostring()
				OrlandoDoom.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == OrlandoDoom.LastTarget then
			if not NPC.IsAttacking(npc) then
				OrlandoDoom.LastTarget = nil
				OrlandoDoom.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == OrlandoDoom.LastTarget then
			if not NPC.IsRunning(npc) then
				OrlandoDoom.LastTarget = nil
				OrlandoDoom.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

function OrlandoDoom.castLinearPrediction(myHero, enemy, adjustmentVariable)

	if not myHero then return end
	if not enemy then return end

	local enemyRotation = Entity.GetRotation(enemy):GetVectors()
		enemyRotation:SetZ(0)
    	local enemyOrigin = NPC.GetAbsOrigin(enemy)
		enemyOrigin:SetZ(0)


	local cosGamma = (NPC.GetAbsOrigin(myHero) - enemyOrigin):Dot2D(enemyRotation:Scaled(100)) / ((NPC.GetAbsOrigin(myHero) - enemyOrigin):Length2D() * enemyRotation:Scaled(100):Length2D())

		if enemyRotation and enemyOrigin then
			if not NPC.IsRunning(enemy) then
				return enemyOrigin
			else return enemyOrigin:__add(enemyRotation:Normalized():Scaled(OrlandoDoom.GetMoveSpeed(enemy) * adjustmentVariable * (1 - cosGamma)))
		end
	end
end

function OrlandoDoom.OnDraw()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_doom_bringer" then return end
    if not AutoMode then return end

    -- Draw text when Auto Doom is Active --
    local pos = Entity.GetAbsOrigin(myHero)
    local x, y, visible = Renderer.WorldToScreen(pos)
    Renderer.SetDrawColor(0, 255, 0, 255)
    Renderer.DrawTextCentered(font, x, y, "Auto", 1)
end

function OrlandoDoom.AutoDoom(myHero)
	local Ult = NPC.GetAbility(myHero, "doom_bringer_doom")
	local mana = NPC.GetMana(myHero)
	if not myHero then return end

	if not Menu.IsEnabled(OrlandoDoom.optionAutoDoom) then return end

	if not Ult then return end
	if not Ability.IsCastable(Ult, mana) then return end


	for i = 1, Heroes.Count() do
		local enemy = Heroes.Get(i)
		if enemy and Entity.IsHero(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 550) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_enigma" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local blackHole = NPC.GetAbility(enemy, "enigma_black_hole")
				
				if blackHole and Ability.IsInAbilityPhase(blackHole) or Ability.IsChannelling(blackHole) then
					if Ability.IsReady(Ult) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastTarget(Ult, enemy)
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 550) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_sand_king" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local epicenter = NPC.GetAbility(enemy, "sandking_epicenter")
				
				if epicenter and Ability.IsChannelling(epicenter) then
					if Ability.IsReady(Ult) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastTarget(Ult, enemy) 
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 550) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_witch_doctor" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local deathward = NPC.GetAbility(enemy, "witch_doctor_death_ward")
				
				if deathward and Ability.IsInAbilityPhase(deathward) or Ability.IsChannelling(deathward) then
					if Ability.IsReady(Ult) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastTarget(Ult, enemy) 
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 550) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_crystal_maiden" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local freezing = NPC.GetAbility(enemy, "crystal_maiden_freezing_field")
				
				if freezing and Ability.IsInAbilityPhase(freezing) or Ability.IsChannelling(freezing) then
					if Ability.IsReady(Ult) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastTarget(Ult, enemy) 
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 550) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_bane" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local grip = NPC.GetAbility(enemy, "bane_fiends_grip")
				
				if grip and Ability.IsInAbilityPhase(grip) or Ability.IsChannelling(grip) then
					if Ability.IsReady(Ult) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastTarget(Ult, enemy) 
					return end
				end
			end
		end
	end
end

function OrlandoDoom.Combo()
if not Menu.IsKeyDown(OrlandoDoom.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_doom_bringer" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if not enemy then return end
    local enemyPos = Entity.GetAbsOrigin(enemy) 
    local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)

--Ability Calls--	
    local Scorched = NPC.GetAbility(myHero, "doom_bringer_scorched_earth")
    local Infernal = NPC.GetAbility(myHero, "doom_bringer_infernal_blade")
    local CreepIceArmor = NPC.GetAbility(myHero, "ogre_magi_frost_armor")
    local CreepKentStun = NPC.GetAbility(myHero, "centaur_khan_war_stomp")
    local CreepManaburn = NPC.GetAbility(myHero, "satyr_soulstealer_mana_burn")
    local CreepNet = NPC.GetAbility(myHero, "dark_troll_warlord_ensnare")
    local CreepRockStun = NPC.GetAbility(myHero, "mud_golem_hurl_boulder")
	local CreepShock = NPC.GetAbility(myHero, "harpy_storm_chain_lightning") --Cheap Dagon--
	local CreepSWave = NPC.GetAbility(myHero, "satyr_hellcaller_shockwave") --Input Prediction--
	local CreepTClap = NPC.GetAbility(myHero, "polar_furbolg_ursa_warrior_thunder_clap")
	local ProwlerStomp = NPC.GetAbility(myHero, "spawnlord_master_stomp")
	local ThunderFrenzy = NPC.GetAbility(myHero, "big_thunder_lizard_frenzy")
    

--Item Calls--
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Halberd  = NPC.GetItem(myHero, "item_heavens_halberd", true)
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local Scythe = NPC.GetItem(myHero, "item_sheepstick", true)
    local ShadowBlade = NPC.GetItem(myHero, "item_invis_sword", true)
    local Shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
    local SilverEdge = NPC.GetItem(myHero, "item_silver_edge", true)
    
--Ability Ranges--
    local InfernalRange = 150
    local FrenzyRange = 900
    local NetRange = 550
    local IceArmorRange = 800
  	local KentStunRadius = 225
  	local ManaBurnRange = 600
  	local ProwlerStompRange = 275
  	local RockStunRange = 800
  	local ScorchedRadius = 550
  	local ShockRange = 900
  	local SWaveRange = 700
  	local CreepTClapRadius = 275
  	
  	
--Item Ranges--
  	local BlinkRange = 1200
  	local HalberdRange = 575
  	local ScytheRange = 900
  	local ShivasRadius = 900
	
	if not NPC.IsEntityInRange(myHero, enemy, 300) then
		if enemy and not NPC.IsIllusion(enemy) and Utility.CanCastSpellOn(enemy) then
       		if Blink and Menu.IsEnabled(OrlandoDoom.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange - 150 + Menu.GetValue(OrlandoDoom.optionBlinkRange)) then
         		Ability.CastPosition(Blink, (Entity.GetAbsOrigin(enemy) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Normalized():Scaled(Menu.GetValue(OrlandoDoom.optionBlinkRange)))) return
      		end
      	end
    end
	
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) then
		if ThunderFrenzy and Ability.IsReady(ThunderFrenzy) and Menu.IsEnabled(OrlandoDoom.optionEnableThunderFrenzy) and Ability.IsCastable(ThunderFrenzy, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastTarget(ThunderFrenzy, myHero) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_stunned") and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) then
		if CreepKentStun and Ability.IsReady(CreepKentStun) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepKentStun) and Ability.IsCastable(CreepKentStun, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), KentStunRadius) then
				Ability.CastNoTarget(CreepKentStun) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if CreepManaburn and Ability.IsReady(CreepManaburn) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepManaburn) and Ability.IsCastable(CreepManaburn, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ManaBurnRange) then
				Ability.CastTarget(CreepManaburn, enemy) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if CreepShock and Ability.IsReady(CreepShock) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepShock) and Ability.IsCastable(CreepShock, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShockRange) then
				Ability.CastTarget(CreepShock, enemy) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_stunned") and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) then
		if CreepRockStun and Ability.IsReady(CreepRockStun) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepRockStun) and Ability.IsCastable(CreepRockStun, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), RockStunRange) then
				Ability.CastTarget(CreepRockStun, enemy) return
			end
		end
	end
			     
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED) then
		if CreepNet and Ability.IsReady(CreepNet) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepNet) and Ability.IsCastable(CreepNet, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), NetRange) then
				Ability.CastTarget(CreepNet, enemy) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) and not NPC.HasModifier(myHero, "modifier_ogre_magi_frost_armor") then
		if CreepIceArmor and Ability.IsReady(CreepIceArmor) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepIceArmor) and Ability.IsCastable(CreepIceArmor, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 400) then
				Ability.CastTarget(CreepIceArmor, myHero) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if CreepSWave and Ability.IsReady(CreepSWave) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepSWave) and Ability.IsCastable(CreepSWave, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), SWaveRange) then
				local SWavePrediction = Ability.GetCastPoint(CreepSWave) + (Entity.GetAbsOrigin(enemy):__sub(Entity.GetAbsOrigin(myHero)):Length2D() / 900) + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)
				Ability.CastPosition((CreepSWave), OrlandoDoom.castLinearPrediction(myHero, enemy, SWavePrediction)) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if ProwlerStomp and Ability.IsReady(ProwlerStomp) and Menu.IsEnabled(OrlandoDoom.optionEnableProwlerStomp) and Ability.IsCastable(ProwlerStomp, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ProwlerStompRange) then
				Ability.CastNoTarget(ProwlerStomp) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if CreepTClap and Ability.IsReady(CreepTClap) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepTClap) and Ability.IsCastable(CreepTClap, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), CreepTClapRadius) then
				Ability.CastNoTarget(CreepTClap) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) then
		if Scorched and Ability.IsReady(Scorched) and Menu.IsEnabled(OrlandoDoom.optionEnableScorched) and Ability.IsCastable(Scorched, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ScorchedRadius) then
				Ability.CastNoTarget(Scorched) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) then
		if ShadowBlade and Ability.IsReady(ShadowBlade) and Menu.IsEnabled(OrlandoDoom.optionEnableShadowBlade) and Ability.IsCastable(ShadowBlade, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastNoTarget(ShadowBlade) return
			end
		end
	end
		
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) then
		if SilverEdge and Ability.IsReady(SilverEdge) and Menu.IsEnabled(OrlandoDoom.optionEnableSilverEdge) and Ability.IsCastable(SilverEdge, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastNoTarget(SilverEdge) return
			end
		end
	end
		
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if Infernal and Ability.IsReady(Infernal) and Menu.IsEnabled(OrlandoDoom.optionEnableInfernal) and Ability.IsCastable(Infernal, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 250) then
				if NPC.HasItem(myHero, "item_invis_sword", true) or NPC.HasItem(myHero, "item_silver_edge", true) then
					if ShadowBlade and Ability.IsReady(ShadowBlade) or SilverEdge and Ability.IsReady(SilverEdge) then
				    	if NPC.HasModifier(myHero, "modifier_item_invisibility_edge_windwalk") or NPC.HasModifier(myHero, "modifier_item_silver_edge_windwalk") then
							Ability.CastTarget(Infernal, enemy) return
						end
					else
						Ability.CastTarget(Infernal, enemy) return
					end
				else
					Ability.CastTarget(Infernal, enemy) return
				end
			end
		end
	end
		
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) then
		if Shivas and Ability.IsReady(Shivas) and Menu.IsEnabled(OrlandoDoom.optionEnableShivas) and Ability.IsCastable(Shivas, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 800) then
				Ability.CastNoTarget(Shivas) return
			end
		end
	end
		
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_sheepstick") then
		if Scythe and Ability.IsReady(Scythe) and Menu.IsEnabled(OrlandoDoom.optionEnableScythe) and Ability.IsCastable(Scythe, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ScytheRange) then
				Ability.CastTarget(Scythe, enemy) return
			end
		end
	end
		
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_sheepstick") then
		if Halberd and Ability.IsReady(Halberd) and Menu.IsEnabled(OrlandoDoom.optionEnableHalberd) and Ability.IsCastable(Halberd, mana) then
			if NPC.IsAttacking(enemy) then
				Ability.CastTarget(Halberd, enemy) return
			end
		end
	end
			
    OrlandoDoom.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
end

function OrlandoDoom.UltCombo()
if not Menu.IsKeyDown(OrlandoDoom.optionKey2) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_doom_bringer" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY) 
    if not enemy then return end
    local enemyPos = Entity.GetAbsOrigin(enemy)
    local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
--Ability Calls--	
    local Scorched = NPC.GetAbility(myHero, "doom_bringer_scorched_earth")
    local Infernal = NPC.GetAbility(myHero, "doom_bringer_infernal_blade")
    local Ult = NPC.GetAbility(myHero, "doom_bringer_doom")
    local CreepIceArmor = NPC.GetAbility(myHero, "ogre_magi_frost_armor")
    local CreepKentStun = NPC.GetAbility(myHero, "centaur_khan_war_stomp")
    local CreepManaburn = NPC.GetAbility(myHero, "satyr_soulstealer_mana_burn")
    local CreepNet = NPC.GetAbility(myHero, "dark_troll_warlord_ensnare")
    local CreepRockStun = NPC.GetAbility(myHero, "mud_golem_hurl_boulder")
	local CreepShock = NPC.GetAbility(myHero, "harpy_storm_chain_lightning") --Cheap Dagon--
	local CreepSWave = NPC.GetAbility(myHero, "satyr_hellcaller_shockwave") --Input Prediction--
	local CreepTClap = NPC.GetAbility(myHero, "polar_furbolg_ursa_warrior_thunder_clap")
	local ProwlerStomp = NPC.GetAbility(myHero, "spawnlord_master_stomp")
	local ThunderFrenzy = NPC.GetAbility(myHero, "big_thunder_lizard_frenzy")
    

--Item Calls--
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Halberd  = NPC.GetItem(myHero, "item_heavens_halberd", true)
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local Scythe = NPC.GetItem(myHero, "item_sheepstick", true)
    local ShadowBlade = NPC.GetItem(myHero, "item_invis_sword", true)
    local Shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
    local SilverEdge = NPC.GetItem(myHero, "item_silver_edge", true)
    
--Ability Ranges--
    local InfernalRange = 150
    local FrenzyRange = 900
    local NetRange = 550
    local IceArmorRange = 800
  	local KentStunRadius = 225
  	local ManaBurnRange = 600
  	local ProwlerStompRange = 275
  	local RockStunRange = 800
  	local ScorchedRadius = 550
  	local ShockRange = 900
  	local SWaveRange = 700
  	local CreepTClapRadius = 275
  	local UltRange = 550
  	
  	
--Item Ranges--
  	local BlinkRange = 1200
  	local HalberdRange = 575
  	local ScytheRange = 900
  	local ShivasRadius = 900
	
	if not NPC.IsEntityInRange(myHero, enemy, 300) then
		if enemy and not NPC.IsIllusion(enemy) and Utility.CanCastSpellOn(enemy) then
       		if Blink and Menu.IsEnabled(OrlandoDoom.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange - 150 + Menu.GetValue(OrlandoDoom.optionBlinkRange)) then
         		Ability.CastPosition(Blink, (Entity.GetAbsOrigin(enemy) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Normalized():Scaled(Menu.GetValue(OrlandoDoom.optionBlinkRange)))) return
      		end
      	end
    end
	
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) then
		if ThunderFrenzy and Ability.IsReady(ThunderFrenzy) and Menu.IsEnabled(OrlandoDoom.optionEnableThunderFrenzy) and Ability.IsCastable(ThunderFrenzy, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastTarget(ThunderFrenzy, myHero) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_stunned") and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) then
		if CreepKentStun and Ability.IsReady(CreepKentStun) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepKentStun) and Ability.IsCastable(CreepKentStun, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), KentStunRadius) then
				Ability.CastNoTarget(CreepKentStun) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if CreepManaburn and Ability.IsReady(CreepManaburn) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepManaburn) and Ability.IsCastable(CreepManaburn, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ManaBurnRange) then
				Ability.CastTarget(CreepManaburn, enemy) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if CreepShock and Ability.IsReady(CreepShock) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepShock) and Ability.IsCastable(CreepShock, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShockRange) then
				Ability.CastTarget(CreepShock, enemy) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_stunned") and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) then
		if CreepRockStun and Ability.IsReady(CreepRockStun) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepRockStun) and Ability.IsCastable(CreepRockStun, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), RockStunRange) then
				Ability.CastTarget(CreepRockStun, enemy) return
			end
		end
	end
			     
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED) then
		if CreepNet and Ability.IsReady(CreepNet) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepNet) and Ability.IsCastable(CreepNet, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), NetRange) then
				Ability.CastTarget(CreepNet, enemy) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) and not NPC.HasModifier(myHero, "modifier_ogre_magi_frost_armor") then
		if CreepIceArmor and Ability.IsReady(CreepIceArmor) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepIceArmor) and Ability.IsCastable(CreepIceArmor, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 400) then
				Ability.CastTarget(CreepIceArmor, myHero) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if CreepSWave and Ability.IsReady(CreepSWave) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepSWave) and Ability.IsCastable(CreepSWave, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), SWaveRange) then
				local SWavePrediction = Ability.GetCastPoint(CreepSWave) + (Entity.GetAbsOrigin(enemy):__sub(Entity.GetAbsOrigin(myHero)):Length2D() / 900) + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)
				Ability.CastPosition((CreepSWave), OrlandoDoom.castLinearPrediction(myHero, enemy, SWavePrediction)) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if ProwlerStomp and Ability.IsReady(ProwlerStomp) and Menu.IsEnabled(OrlandoDoom.optionEnableProwlerStomp) and Ability.IsCastable(ProwlerStomp, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ProwlerStompRange) then
				Ability.CastNoTarget(ProwlerStomp) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if CreepTClap and Ability.IsReady(CreepTClap) and Menu.IsEnabled(OrlandoDoom.optionEnableCreepTClap) and Ability.IsCastable(CreepTClap, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), CreepTClapRadius) then
				Ability.CastNoTarget(CreepTClap) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) then
		if Scorched and Ability.IsReady(Scorched) and Menu.IsEnabled(OrlandoDoom.optionEnableScorched) and Ability.IsCastable(Scorched, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ScorchedRadius) then
				Ability.CastNoTarget(Scorched) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) then
		if ShadowBlade and Ability.IsReady(ShadowBlade) and Menu.IsEnabled(OrlandoDoom.optionEnableShadowBlade) and Ability.IsCastable(ShadowBlade, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastNoTarget(ShadowBlade) return
			end
		end
	end
		
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) then
		if SilverEdge and Ability.IsReady(SilverEdge) and Menu.IsEnabled(OrlandoDoom.optionEnableSilverEdge) and Ability.IsCastable(SilverEdge, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastNoTarget(SilverEdge) return
			end
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) then
		if Infernal and Ability.IsReady(Infernal) and Menu.IsEnabled(OrlandoDoom.optionEnableInfernal) and Ability.IsCastable(Infernal, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 250) then
				if NPC.HasItem(myHero, "item_invis_sword", true) or NPC.HasItem(myHero, "item_silver_edge", true) then
					if ShadowBlade and Ability.IsReady(ShadowBlade) or SilverEdge and Ability.IsReady(SilverEdge) then
				    	if NPC.HasModifier(myHero, "modifier_item_invisibility_edge_windwalk") or NPC.HasModifier(myHero, "modifier_item_silver_edge_windwalk") then
							Ability.CastTarget(Infernal, enemy) return
						end
					else
						Ability.CastTarget(Infernal, enemy) return
					end
				else
					Ability.CastTarget(Infernal, enemy) return
				end
			end
		end
	end
	
	if OrlandoDoom.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.IsLinkensProtected(enemy) then
		if Ult and Ability.IsReady(Ult) and Menu.IsEnabled(OrlandoDoom.optionEnableUlt) and Ability.IsCastable(Ult, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), UltRange) then
				Ability.CastTarget(Ult, enemy) return
			end
		end
	end
		
	if Utility.CanCastSpellOn(myHero) and not NPC.IsIllusion(myHero) then
		if Shivas and Ability.IsReady(Shivas) and Menu.IsEnabled(OrlandoDoom.optionEnableShivas) and Ability.IsCastable(Shivas, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 800) then
				Ability.CastNoTarget(Shivas) return
			end
		end
	end
		
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_sheepstick") then
		if Scythe and Ability.IsReady(Scythe) and Menu.IsEnabled(OrlandoDoom.optionEnableScythe) and Ability.IsCastable(Scythe, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ScytheRange) then
				Ability.CastTarget(Scythe, enemy) return
			end
		end
	end
		
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_sheepstick") then
		if Halberd and Ability.IsReady(Halberd) and Menu.IsEnabled(OrlandoDoom.optionEnableHalberd) and Ability.IsCastable(Halberd, mana) then
			if NPC.IsAttacking(enemy) then
				Ability.CastTarget(Halberd, enemy) return
			end
		end
	end
			
    OrlandoDoom.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
end

function OrlandoDoom.SleepReady(sleep)

	if (os.clock() - OrlandoDoom.lastTick) >= sleep then
		return true
	end
	return false
end

function OrlandoDoom.makeDelay(sec)

	OrlandoDoom.delay = sec + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING)
	OrlandoDoom.lastTick = os.clock() 
end

function OrlandoDoom.CanCastSpellOn(npc)
	if Entity.IsDormant(npc) or not Entity.IsAlive(npc) then return false end
	if NPC.IsStructure(npc) or not NPC.IsKillable(npc) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end

	return true
end
	
return OrlandoDoom