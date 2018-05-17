local Utility = require("Utility")
local Lina = {}

Lina.optionKey = Menu.AddKeyOption({"Hero Specific","Lina"},"3. Euls Combo Key",Enum.ButtonCode.KEY_D)
Lina.optionKey2 = Menu.AddKeyOption({"Hero Specific","Lina"},"4. Non-Euls Combo Key",Enum.ButtonCode.KEY_F)
Lina.optionKey3 = Menu.AddKeyOption({"Hero Specific","Lina"},"2. Dragon Harass Key",Enum.ButtonCode.KEY_S)
Lina.optionEnable = Menu.AddOption({"Hero Specific","Lina"},"1. Enabled","Enable Or Disable Lina Combo Script")
Lina.optionBlink = Menu.AddOption({"Hero Specific", "Lina" }, "5. Use Blink to Initiate {{Lina}}", "")
Lina.optionBlinkRange = Menu.AddOption({"Hero Specific", "Lina" }, "6. Set Safe Blink Initiation Range {{Lina}}", "If Pike then set at 400, if Euls/No Pike (575), if Lens (Add 250), if Talent Range (Add 200), if both then add totals", 400, 1050, 25)
--Skills Toggle Menu--
Lina.optionEnableDragon = Menu.AddOption({"Hero Specific","Lina","7. Skills"},"1. Use Dragon Slave","Enable Or Disable")
Lina.optionEnableArray = Menu.AddOption({"Hero Specific","Lina","7. Skills"},"2. Use Light Strike Array","Enable Or Disable")
Lina.optionEnableUlt = Menu.AddOption({"Hero Specific","Lina","7. Skills"},"3. Use Laguna Blade","Enable Or Disable")
--Items Toggle Menu--
Lina.optionEnableBKB = Menu.AddOption({"Hero Specific", "Lina","8. Items"},"1. Use BKB After Blink","Turn On/Off BKB in Combo")
Lina.optionEnableEuls = Menu.AddOption({"Hero Specific","Lina","8. Items"},"2. Use Euls","Turn On/Off Euls in Combo")
Lina.optionEnableOrchid = Menu.AddOption({"Hero Specific","Lina","8. Items"},"3. Use Orchid","Turn On/Off Orchid in Combo")
Lina.optionEnablePike = Menu.AddOption({"Hero Specific","Lina","8. Items"},"4. Use Hurricane Pike","Turn On/Off Pike in Combo")
Lina.optionEnableThorn = Menu.AddOption({"Hero Specific","Lina","8. Items"},"5. Use Bloodthorn","Turn On/Off Bloodthorn in Combo")

-- global Variables
Lina.lastAttackTime = 0
Lina.lastAttackTime2 = 0
Lina.LastTarget = nil

function Lina.ResetGlobalVariables()
    Lina.lastAttackTime = 0
	Lina.lastAttackTime2 = 0
	Lina.LastTarget = nil
end

function Lina.OnUpdate()
    if not Menu.IsEnabled(Lina.optionEnable) then return true end
	if Menu.IsKeyDown(Lina.optionKey)then
    Lina.Combo()
	end
	
	if not Menu.IsEnabled(Lina.optionEnable) then return true end
	if Menu.IsKeyDown(Lina.optionKey2)then
    Lina.Combo2()
	end
	
	if not Menu.IsEnabled(Lina.optionEnable) then return true end
	if Menu.IsKeyDown(Lina.optionKey3) then
    Lina.DragonHarass()
	end
	
	if not Engine.IsInGame() then
	Lina.ResetGlobalVariables()
	end
end	

function Lina.castPrediction(myHero, enemy, adjustmentVariable)

	if not myHero then return end
	if not enemy then return end

	local enemyRotation = Entity.GetRotation(enemy):GetVectors()
		enemyRotation:SetZ(0)
    	local enemyOrigin = NPC.GetAbsOrigin(enemy)
		enemyOrigin:SetZ(0)

	if enemyRotation and enemyOrigin then
			if not NPC.IsRunning(enemy) then
				return enemyOrigin
			else return enemyOrigin:__add(enemyRotation:Normalized():Scaled(Lina.GetMoveSpeed(enemy) * adjustmentVariable))
			end
	end
end

function Lina.GetMoveSpeed(enemy)

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

function Lina.isHeroChannelling(myHero)

	if not myHero then return true end

	if NPC.IsChannellingAbility(myHero) then return true end
	if NPC.HasModifier(myHero, "modifier_teleporting") then return true end

	return false
end

function Lina.heroCanCastItems(myHero)

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

function Lina.IsInAbilityPhase(myHero)

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

function Lina.Debugger(time, npc, ability, order)

	if not Menu.IsEnabled(Lina.optionEnable) then return end
	Log.Write(tostring(time) .. " " .. tostring(NPC.GetUnitName(npc)) .. " " .. tostring(ability) .. " " .. tostring(order))
end

function Lina.GenericMainAttack(myHero, attackType, target, position)
	
	if not myHero then return end
	if not target and not position then return end

	if Lina.isHeroChannelling(myHero) == true then return end
	if Lina.heroCanCastItems(myHero) == false then return end
	if Lina.IsInAbilityPhase(myHero) == true then return end

	if Menu.IsEnabled(Lina.optionEnable) then
		if target ~= nil then
			Lina.GenericAttackIssuer(attackType, target, position, myHero)
		end
	else
		Lina.GenericAttackIssuer(attackType, target, position, myHero)
	end
end

function Lina.GenericAttackIssuer(attackType, target, position, npc)

	if not npc then return end
	if not target and not position then return end
	if os.clock() - Lina.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= Lina.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Lina.LastTarget = target
				Lina.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= Lina.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					Lina.LastTarget = position:__tostring()
					Lina.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= Lina.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Lina.LastTarget = position:__tostring()
				Lina.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == Lina.LastTarget then
			if not NPC.IsAttacking(npc) then
				Lina.LastTarget = nil
				Lina.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == Lina.LastTarget then
			if not NPC.IsRunning(npc) then
				Lina.LastTarget = nil
				Lina.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

function Lina.DragonHarass(myHero)
if not Menu.IsKeyDown(Lina.optionKey3) then return end
local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_lina" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local mana = NPC.GetMana(myHero)
    
    if not enemy then return end
    
--Ability Calls--
    local Dragon = NPC.GetAbility(myHero, "lina_dragon_slave")
 
--Item Calls--
	local Lens = NPC.GetItem(myHero, "item_aether_lens", true) 
    
--Ability Ranges--
	local DragonRange = 1075
	
--Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_cast_range_125")
  	
  	if Lens then
    	DragonRange = DragonRange + 250
    end
    
    if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
    	DragonRange = DragonRange + 125
    end
  	


if Dragon and Menu.IsKeyDown(Lina.optionKey3) and Ability.IsCastable(Dragon, mana) and Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsEntityInRange(myHero, enemy, DragonRange) then
		local pred = 0.45 + ((Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Length2D() / 1200) + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)
		Ability.CastPosition(Dragon, Lina.castPrediction(myHero, enemy, pred)) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil)
		return 
	end
end

function Lina.Combo()
if not Menu.IsKeyDown(Lina.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_lina" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not enemy then return end

--Ability Calls--	
    local Dragon = NPC.GetAbility(myHero, "lina_dragon_slave")
    local Laguna = NPC.GetAbility(myHero, "lina_laguna_blade")

--Item Calls--
	local BKB = NPC.GetItem(myHero, "item_black_king_bar", true)
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Euls  = NPC.GetItem(myHero, "item_cyclone", true)
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local Orchid = NPC.GetItem(myHero, "item_orchid", true)
    local Pike = NPC.GetItem(myHero, "item_hurricane_pike", true)
    local Thorn = NPC.GetItem(myHero, "item_bloodthorn", true)
    
--Ability Ranges--
    local DragonRange = 1075
    local ArrayRange = 625
  	local LagunaRange = 600
  	
--Item Ranges--
  	local BlinkRange = 1200
  	local EulsRange = 575
  	local OrchidRange = 900
  	local PikeRange = 400
  	local ThornRange = 900
 
--Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_cast_range_125")
    
    if Lens then
    		DragonRange = DragonRange + 250
    		ArrayRange = ArrayRange + 250
    		LagunaRange = LagunaRange + 250
			BlinkRange = BlinkRange + 250
    		EulsRange = EulsRange + 250
    		OrchidRange = OrchidRange + 250
    		PikeRange = PikeRange + 250
    		ThornRange = ThornRange + 250
    end
	
	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
    		DragonRange = DragonRange + 125
    		ArrayRange = ArrayRange + 125
    		LagunaRange = LagunaRange + 125
    		BlinkRange = BlinkRange + 125
    		EulsRange = EulsRange + 125
    		OrchidRange = OrchidRange + 125
    		PikeRange = PikeRange + 125
    		ThornRange = ThornRange + 125
  	end		
	
	if Menu.IsEnabled(Lina.optionEnable) then
	
	if enemy and not NPC.IsIllusion(enemy) and Utility.CanCastSpellOn(enemy) then
        if Blink and Menu.IsEnabled(Lina.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange + Menu.GetValue(Lina.optionBlinkRange)) then
            Ability.CastPosition(Blink, (Entity.GetAbsOrigin(enemy) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Normalized():Scaled(Menu.GetValue(Lina.optionBlinkRange)))) return end
        end
	
	if BKB and Menu.IsEnabled(Lina.optionEnableBKB) and Ability.IsCastable(BKB, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy),575) then Ability.CastNoTarget(BKB) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Euls and Menu.IsEnabled(Lina.optionEnableEuls) and Ability.IsCastable(Euls, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), EulsRange) then Ability.CastTarget(Euls, enemy) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Dragon and Ability.IsReady(Dragon) and Menu.IsEnabled(Lina.optionEnableDragon) and Ability.IsCastable(Dragon, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and not NPC.IsRunning(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), EulsRange) then Ability.CastTarget(Dragon, enemy) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return end
			     
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Laguna and Ability.IsReady(Laguna) and Menu.IsEnabled(Lina.optionEnableUlt) and Ability.IsCastable(Laguna, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), EulsRange) then Ability.CastTarget(Laguna, enemy) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Orchid and Menu.IsEnabled(Lina.optionEnableOrchid) and Ability.IsCastable(Orchid, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), OrchidRange) then Ability.CastTarget(Orchid, enemy) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Thorn and Menu.IsEnabled(Lina.optionEnableThorn) and Ability.IsCastable(Thorn, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ThornRange) then Ability.CastTarget(Thorn, enemy) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Pike and Menu.IsEnabled(Lina.optionEnablePike) and Ability.IsCastable(Pike, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), PikeRange) then Ability.CastTarget(Pike, enemy) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION", enemy, nil) return end
    
    Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil)
		return
	end
end

function Lina.Combo2()
if not Menu.IsKeyDown(Lina.optionKey2) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_lina" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local enemyPos = Entity.GetAbsOrigin(enemy)
    local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not enemy then return end

--Ability Calls--	
    local Dragon = NPC.GetAbility(myHero, "lina_dragon_slave")
    local Array = NPC.GetAbility(myHero, "lina_light_strike_array")
    local Laguna = NPC.GetAbility(myHero, "lina_laguna_blade")

--Item Calls--
	local BKB = NPC.GetItem(myHero, "item_black_king_bar", true)
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Euls  = NPC.GetItem(myHero, "item_cyclone", true)
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local Orchid = NPC.GetItem(myHero, "item_orchid", true)
    local Pike = NPC.GetItem(myHero, "item_hurricane_pike", true)
    local Thorn = NPC.GetItem(myHero, "item_bloodthorn", true)
    
--Ability Ranges--
    local DragonRange = 1075
    local ArrayRange = 625
  	local LagunaRange = 600
 
--Item Ranges--
  	local BlinkRange = 1200
  	local EulsRange = 575
  	local OrchidRange = 900
  	local PikeRange = 400
  	local ThornRange = 900 
 
--Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_cast_range_125")
    
    if Lens then
    		DragonRange = DragonRange + 250
    		ArrayRange = ArrayRange + 250
    		LagunaRange = LagunaRange + 250
			BlinkRange = BlinkRange + 250
    		EulsRange = EulsRange + 250
    		OrchidRange = OrchidRange + 250
    		PikeRange = PikeRange + 250
    		ThornRange = ThornRange + 250
    end
	
	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
    		DragonRange = DragonRange + 125
    		ArrayRange = ArrayRange + 125
    		LagunaRange = LagunaRange + 125
    		BlinkRange = BlinkRange + 125
    		EulsRange = EulsRange + 125
    		OrchidRange = OrchidRange + 125
    		PikeRange = PikeRange + 125
    		ThornRange = ThornRange + 125
  	end		
	
	if Menu.IsEnabled(Lina.optionEnable) then
	
	if enemy and not NPC.IsIllusion(enemy) and Utility.CanCastSpellOn(enemy) then
        if Blink and Menu.IsEnabled(Lina.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange + Menu.GetValue(Lina.optionBlinkRange)) then
            Ability.CastPosition(Blink, (Entity.GetAbsOrigin(enemy) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Normalized():Scaled(Menu.GetValue(Lina.optionBlinkRange)))) return end
        end
	
	if BKB and Menu.IsEnabled(Lina.optionEnableBKB) and Ability.IsCastable(BKB, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy),575) then Ability.CastNoTarget(BKB) return end
	
	if Array and Menu.IsEnabled(Lina.optionEnableArray) and Ability.IsCastable(Array, mana) and NPC.IsEntityInRange(myHero, enemy, ArrayRange, 0) then
		local pred = 0.95 + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)
		local predPos = Lina.castPrediction(myHero, enemy, pred)
		if not NPC.IsPositionInRange(myHero, predPos, ArrayRange, 0) then
			local myPos = Entity.GetAbsOrigin(myHero)
			local dist = (myPos - predPos):Length2D()
			local saveCastPos = predPos
			for k = 1, math.floor(dist/25) do
				local searchPos = predPos + (myPos - predPos):Normalized():Scaled(k*25)
				if NPC.IsPositionInRange(myHero, searchPos, ArrayRange, 0) then
					saveCastPos = searchPos
					break
				end
			end
			if NPC.IsPositionInRange(myHero, saveCastPos, ArrayRange, 0) and Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") then	
				Ability.CastPosition(Array, saveCastPos) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil)
				return
			end
		else
			Ability.CastPosition(Array, predPos) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil)
			return
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Array and Menu.IsEnabled(Lina.optionEnableArray) and Ability.IsCastable(Array, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and not NPC.IsRunning(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ArrayRange) then Ability.CastPosition(Array, enemyPos) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Dragon and Menu.IsEnabled(Lina.optionEnableDragon) and Ability.IsCastable(Dragon, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and not NPC.IsRunning(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ArrayRange) then Ability.CastTarget(Dragon, enemy) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return end
	     	     
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Laguna and Menu.IsEnabled(Lina.optionEnableUlt) and Ability.IsCastable(Laguna, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), LagunaRange) then Ability.CastTarget(Laguna, enemy) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Orchid and Menu.IsEnabled(Lina.optionEnableOrchid) and Ability.IsCastable(Orchid, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), OrchidRange) then Ability.CastTarget(Orchid, enemy) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Thorn and Menu.IsEnabled(Lina.optionEnableThorn) and Ability.IsCastable(Thorn, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ThornRange) then Ability.CastTarget(Thorn, enemy) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return end

	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Pike and Menu.IsEnabled(Lina.optionEnablePike) and Ability.IsCastable(Pike, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), PikeRange) then Ability.CastTarget(Pike, enemy) Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return end

    Lina.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil)
		return
	end
end
	
return Lina
