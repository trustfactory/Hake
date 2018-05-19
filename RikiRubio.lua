local Utility = require("Utility")
local RikiRubio = {}

RikiRubio.optionEnable = Menu.AddOption({"Hero Specific","Riki"}, "1. Enabled", "Enable Or Disable Riki Combo Script")
RikiRubio.optionKey = Menu.AddKeyOption({"Hero Specific","Riki"}, "2. Combo Key", Enum.ButtonCode.KEY_D)
RikiRubio.optionEnablePhase = Menu.AddOption({"Hero Specific","Riki"}, "3. Auto Phase Boots", "Enable Or Disable Auto Phase Boots")
RikiRubio.optionEnableKS = Menu.AddOption({"Hero Specific","Riki"}, "4. KillSteal", "Enable Or Disable KillSteal")
--Ability Toggle Menu--
RikiRubio.optionEnableSmoke = Menu.AddOption({"Hero Specific","Riki","5. Skills"},"1. Use Smoke Screen","Enable Or Disable")
RikiRubio.optionEnableStrike = Menu.AddOption({"Hero Specific","Riki","5. Skills"},"2. Use Blink Strike","Enable Or Disable")
RikiRubio.optionEnableUlt = Menu.AddOption({"Hero Specific","Riki","5. Skills"},"3. Use Tricks of the Trade","Enable Or Disable")
--Items Toggle Menu--
RikiRubio.optionEnableAbyssal = Menu.AddOption({"Hero Specific","Riki","6. Items"},"1. Use Abyssal","Turn On/Off Abyssal in Combo")
RikiRubio.optionEnableButterfly = Menu.AddOption({"Hero Specific","Riki","6. Items"},"2. Use Butterfly","Turn On/Off Butterfly in Combo")
RikiRubio.optionEnableCrest = Menu.AddOption({"Hero Specific","Riki","6. Items"},"3. Use Solar Crest","Turn On/Off Crest in Combo")
RikiRubio.optionEnableDiffusal = Menu.AddOption({"Hero Specific","Riki","6. Items"},"4. Use Diffusal","Turn On/Off Diffusal in Combo")
RikiRubio.optionEnableMedallion = Menu.AddOption({"Hero Specific","Riki","6. Items"},"5. Use Medallion","Turn On/Off Medallion in Combo")
RikiRubio.optionEnableNullifier = Menu.AddOption({"Hero Specific","Riki","6. Items"},"6. Use Nullifier","Turn On/Off Nullifier in Combo")
RikiRubio.optionEnableUrn = Menu.AddOption({"Hero Specific","Riki","6. Items"},"7. Use Urn on Target","Turn On/Off Urn in Combo")
RikiRubio.optionEnableVessel = Menu.AddOption({"Hero Specific","Riki","6. Items"},"8. Use Vessel on Target","Turn On/Off Vessel in Combo")

-- Global Variables
RikiRubio.lastAttackTime = 0
RikiRubio.lastAttackTime2 = 0
RikiRubio.LastTarget = nil

function RikiRubio.ResetGlobalVariables()
    RikiRubio.lastAttackTime = 0
	RikiRubio.lastAttackTime2 = 0
	RikiRubio.LastTarget = nil
end

function RikiRubio.isHeroChannelling(myHero)

	if not myHero then return true end

	if NPC.IsChannellingAbility(myHero) then return true end
	if NPC.HasModifier(myHero, "modifier_teleporting") then return true end

	return false
end

function RikiRubio.heroCanCastItems(myHero)

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

function RikiRubio.IsInAbilityPhase(myHero)

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

function RikiRubio.Debugger(time, npc, ability, order)

	if not Menu.IsEnabled(RikiRubio.optionEnable) then return end
	Log.Write(tostring(time) .. " " .. tostring(NPC.GetUnitName(npc)) .. " " .. tostring(ability) .. " " .. tostring(order))
end

function RikiRubio.GenericMainAttack(myHero, attackType, target, position)
	
	if not myHero then return end
	if not target and not position then return end

	if RikiRubio.isHeroChannelling(myHero) == true then return end
	if RikiRubio.heroCanCastItems(myHero) == false then return end
	if RikiRubio.IsInAbilityPhase(myHero) == true then return end

	if Menu.IsEnabled(RikiRubio.optionEnable) then
		if target ~= nil then
			RikiRubio.GenericAttackIssuer(attackType, target, position, myHero)
		end
	else
		RikiRubio.GenericAttackIssuer(attackType, target, position, myHero)
	end
end

function RikiRubio.GenericAttackIssuer(attackType, target, position, npc)

	if not npc then return end
	if not target and not position then return end
	if os.clock() - RikiRubio.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= RikiRubio.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				RikiRubio.LastTarget = target
				RikiRubio.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= RikiRubio.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					RikiRubio.LastTarget = position:__tostring()
					RikiRubio.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= RikiRubio.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				RikiRubio.LastTarget = position:__tostring()
				RikiRubio.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == RikiRubio.LastTarget then
			if not NPC.IsAttacking(npc) then
				RikiRubio.LastTarget = nil
				RikiRubio.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == RikiRubio.LastTarget then
			if not NPC.IsRunning(npc) then
				RikiRubio.LastTarget = nil
				RikiRubio.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

function RikiRubio.OnUpdate()
    if not Menu.IsEnabled(RikiRubio.optionEnable) then return true end
	if Menu.IsKeyDown(RikiRubio.optionKey)then
    RikiRubio.Combo()
	end
	
	if Menu.IsEnabled(RikiRubio.optionEnablePhase) then
        RikiRubio.AutoPhaseBoots()
	end
	
	if Menu.IsEnabled(RikiRubio.optionEnableKS) then
        RikiRubio.KillSteal()
	end
	
	if not Engine.IsInGame() then
	RikiRubio.ResetGlobalVariables()
	end
end	

function RikiRubio.IsSuitableToCastSpell(myHero)
	if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
	return true
end

function RikiRubio.AutoPhaseBoots()
if not Menu.IsEnabled(RikiRubio.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_riki" then return end
	local mana = NPC.GetMana(myHero)
	
	if not myHero then return end  
	
	--Item Calls--
	local PhaseBoots = NPC.GetItem(myHero, "item_phase_boots", true)
	
	if PhaseBoots and Menu.IsEnabled(RikiRubio.optionEnablePhase) and NPC.IsRunning(myHero) and Ability.IsReady(PhaseBoots) then
		Ability.CastNoTarget(PhaseBoots) return
	end
end

function RikiRubio.KillSteal()
    local myHero = Heroes.GetLocal()
    if not myHero or not RikiRubio.IsSuitableToCastSpell(myHero) then return end

    local BlinkStrike = NPC.GetAbility(myHero, "riki_blink_strike")
    if not BlinkStrike or not Ability.IsCastable(BlinkStrike, NPC.GetMana(myHero)) then return end
    
    --Ability Ranges--
    local BlinkRange = Ability.GetCastRange(BlinkStrike)
    
    --Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_unique_riki_3")
	
	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
    	BlinkRange = BlinkRange + 900
  	end	

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        local BasicAttackDamage = NPC.GetDamageMultiplierVersus(myHero, enemy) * ((NPC.GetMinDamage(myHero) + NPC.GetBonusDamage(myHero)) * NPC.GetArmorDamageMultiplier(enemy))
        local damage = BasicAttackDamage + (40 + 15 * Ability.GetLevel(BlinkStrike))
        
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), BlinkRange) and Utility.CanCastSpellOn(enemy)
        and damage >= Entity.GetHealth(enemy) then
            Ability.CastTarget(BlinkStrike, enemy)
            return
        end
    end
end
	
function RikiRubio.Combo()
if not Menu.IsKeyDown(RikiRubio.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_riki" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local enemyPos = Entity.GetAbsOrigin(enemy)
    local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not enemy then return end
	
	--Ability Calls--
    local Smoke = NPC.GetAbility(myHero, "riki_smoke_screen")
    local Strike = NPC.GetAbility(myHero, "riki_blink_strike")
    local Ult = NPC.GetAbility(myHero, "riki_tricks_of_the_trade")
    
    --Item Calls--
    local Abyssal = NPC.GetItem(myHero, "item_abyssal_blade", true)
    local Aghs = NPC.GetItem(myHero, "item_ultimate_scepter", true)
    local Butterfly = NPC.GetItem(myHero, "item_butterfly", true)
    local Crest = NPC.GetItem(myHero, "item_solar_crest", true)
    local Diffusal = NPC.GetItem(myHero, "item_diffusal_blade", true)
    local Medallion = NPC.GetItem(myHero, "item_medallion_of_courage", true)
    local Nullifier = NPC.GetItem(myHero, "item_nullifier", true)
    local Urn = NPC.GetItem(myHero, "item_urn_of_shadows", true)
    local Vessel = NPC.GetItem(myHero, "item_spirit_vessel", true)
    
    --Ability Ranges--
    local SmokeRange = 550
  	local BlinkRange = 800
  	
  	--Item Ranges--
    local AbyssalRange = 140
  	local DaggerRange = 1200
  	local CrestRange = 1000
  	local DiffusalRange = 600
  	local MedallionRange = 1000
  	local NullifierRange = 600
  	local UrnRange = 950
  	local VesselRange = 950
  	
  	--Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_unique_riki_3")
	
	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
    	BlinkRange = BlinkRange + 900
  	end		
	
	if Menu.IsEnabled(RikiRubio.optionEnable) then
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Smoke and Menu.IsEnabled(RikiRubio.optionEnableSmoke) and not Ability.IsChannelling(Ult) and Ability.IsCastable(Smoke, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), SmokeRange) then Ability.CastPosition(Smoke, enemyPos) return 
	end
		     
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Strike and Menu.IsEnabled(RikiRubio.optionEnableStrike) and not Ability.IsChannelling(Ult) and Ability.IsCastable(Strike, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), BlinkRange) then Ability.CastTarget(Strike, enemy) return
	end	     
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Diffusal and Menu.IsEnabled(RikiRubio.optionEnableDiffusal) and not Ability.IsChannelling(Ult) and Ability.IsCastable(Diffusal, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), DiffusalRange) then Ability.CastTarget(Diffusal, enemy) return
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and NPC.IsAttacking(myHero) and Medallion and Menu.IsEnabled(RikiRubio.optionEnableMedallion) and not Ability.IsChannelling(Ult) and Ability.IsCastable(Medallion, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), MedallionRange) then Ability.CastTarget(Medallion, enemy) return
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and NPC.IsAttacking(myHero) and Crest and Menu.IsEnabled(RikiRubio.optionEnableCrest) and not Ability.IsChannelling(Ult) and Ability.IsCastable(Crest, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), CrestRange) then Ability.CastTarget(Crest, enemy) return
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and NPC.IsAttacking(myHero) and Urn and Menu.IsEnabled(RikiRubio.optionEnableUrn) and not Ability.IsChannelling(Ult) and Ability.IsCastable(Urn, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), UrnRange) and Item.GetCurrentCharges(Urn) > 0 and not NPC.HasModifier(enemy, "modifier_item_urn_damage") then Ability.CastTarget(Urn, enemy) return 
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and NPC.IsAttacking(myHero) and Vessel and Menu.IsEnabled(RikiRubio.optionEnableVessel) and not Ability.IsChannelling(Ult) and Ability.IsCastable(Vessel, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), VesselRange) and Item.GetCurrentCharges(Vessel) > 0 and not NPC.HasModifier(enemy, "modifier_item_spirit_vessel_damage") then Ability.CastTarget(Vessel, enemy) return 
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Abyssal and Menu.IsEnabled(RikiRubio.optionEnableAbyssal) and Ability.IsCastable(Abyssal, mana) and not Ability.IsChannelling(Ult) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), AbyssalRange) then Ability.CastTarget(Abyssal, enemy) return
	end
	
	if NPC.IsAttacking(myHero) and Butterfly and Menu.IsEnabled(RikiRubio.optionEnableButterfly) and not Ability.IsChannelling(Ult) and Ability.IsReady(Butterfly) and NPC.IsEntityInRange(myHero, enemy, NPC.GetAttackRange(myHero)) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED) and not NPC.IsStunned(enemy) then Ability.CastNoTarget(Butterfly) return 
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active")
	and NPC.IsAttacking(myHero) and Nullifier and Menu.IsEnabled(RikiRubio.optionEnableNullifier) and not Ability.IsChannelling(Ult) and Ability.IsCastable(Nullifier, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), NullifierRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) and not NPC.IsSilenced(enemy) then Ability.CastTarget(Nullifier, enemy) return 
	end
	
	if NPC.IsAttacking(myHero) and not Entity.IsDormant(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and Ult and Ability.IsReady(Ult) and Menu.IsEnabled(RikiRubio.optionEnableUlt) and Ability.IsCastable(Ult, mana) then
			if Aghs then
				Ability.CastTarget(Ult, myHero)
			else
				Ability.CastNoTarget(Ult)
			end
		return end
	if Ability.IsInAbilityPhase(Ult) then return end
  	if Ability.IsChannelling(Ult) then return end
	
	RikiRubio.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
	end
end
	
return RikiRubio