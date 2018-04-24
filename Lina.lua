local Utility = require("Utility")
local Lina = {}

Lina.optionKey = Menu.AddKeyOption({"Hero Specific","Lina"},"3. Euls Combo Key",Enum.ButtonCode.KEY_D)
Lina.optionKey2 = Menu.AddKeyOption({"Hero Specific","Lina"},"4. Non-Euls Combo Key",Enum.ButtonCode.KEY_F)
Lina.optionKey3 = Menu.AddKeyOption({"Hero Specific","Lina"},"2. Dragon Harass Key",Enum.ButtonCode.KEY_S)
Lina.optionEnable = Menu.AddOption({"Hero Specific","Lina"},"1. Enabled","Enable Or Disable Lina Combo Script")
Lina.optionBlink = Menu.AddOption({"Hero Specific", "Lina" }, "5. Use Blink to Initiate {{Lina}}", "")
Lina.optionBlinkRange = Menu.AddOption({"Hero Specific", "Lina" }, "6. Set Safe Blink Initiation Range {{Lina}}", "If using Pike then set at 475, If not using Pike set at 575", 200, 800, 25)
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
		Ability.CastPosition(Dragon, Lina.castPrediction(myHero, enemy, pred))
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
	and Dragon and Menu.IsEnabled(Lina.optionEnableDragon) and Ability.IsCastable(Dragon, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and not NPC.IsRunning(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ArrayRange) then Ability.CastTarget(Dragon, enemy) return end
			     
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Laguna and Menu.IsEnabled(Lina.optionEnableUlt) and Ability.IsCastable(Laguna, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), LagunaRange) then Ability.CastTarget(Laguna, enemy) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Orchid and Menu.IsEnabled(Lina.optionEnableOrchid) and Ability.IsCastable(Orchid, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), OrchidRange) then Ability.CastTarget(Orchid, enemy) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Thorn and Menu.IsEnabled(Lina.optionEnableThorn) and Ability.IsCastable(Thorn, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ThornRange) then Ability.CastTarget(Thorn, enemy) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Pike and Menu.IsEnabled(Lina.optionEnablePike) and Ability.IsCastable(Pike, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), PikeRange) then Ability.CastTarget(Pike, enemy) return end
	
	if enemy and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ArrayRange) then Player.PrepareUnitOrders(Players.GetLocal(),4, enemy, Vector(0,0,0), enemy, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero) end
	end
	if enemy and not NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ArrayRange) and not NPC.HasModifier(myHero, "modifier_item_hurricane_pike_range") then Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, enemy, mousePos, enemy, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero) end 
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
	
	if Array and Menu.IsEnabled(Lina.optionEnableArray) and Ability.IsCastable(Array, mana) and NPC.IsEntityInRange(myHero, enemy, ArrayRange) then
		local pred = 1.5 + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)
		local predPos = Lina.castPrediction(myHero, enemy, pred)
		if not NPC.IsPositionInRange(myHero, predPos, ArrayRange) then
			local myPos = Entity.GetAbsOrigin(myHero)
			local dist = (myPos - predPos):Length2D()
			local saveCastPos = predPos
			for k = 1, math.floor(dist/25) do
				local searchPos = predPos + (myPos - predPos):Normalized():Scaled(k*25)
				if NPC.IsPositionInRange(myHero, searchPos, ArrayRange) then
					saveCastPos = searchPos
					break
				end
			end
			if NPC.IsPositionInRange(myHero, saveCastPos, ArrayRange) and Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") then	
				Ability.CastPosition(Array, saveCastPos)
				return
			end
		else
			Ability.CastPosition(Array, predPos)
			return
		end
	end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Dragon and Menu.IsEnabled(Lina.optionEnableDragon) and Ability.IsCastable(Dragon, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and not NPC.IsRunning(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ArrayRange) and Ability.SecondsSinceLastUse(Array)<=0.9 and Ability.SecondsSinceLastUse(Array)>0.7 then Ability.CastTarget(Dragon, enemy) return end
	     	     
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Laguna and Menu.IsEnabled(Lina.optionEnableUlt) and Ability.IsCastable(Laguna, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), LagunaRange) then Ability.CastTarget(Laguna, enemy) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Orchid and Menu.IsEnabled(Lina.optionEnableOrchid) and Ability.IsCastable(Orchid, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), OrchidRange) then Ability.CastTarget(Orchid, enemy) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Thorn and Menu.IsEnabled(Lina.optionEnableThorn) and Ability.IsCastable(Thorn, mana) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ThornRange) then Ability.CastTarget(Thorn, enemy) return end
	
	if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy)
	and Pike and Menu.IsEnabled(Lina.optionEnablePike) and Ability.IsCastable(Pike, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), PikeRange) then Ability.CastTarget(Pike, enemy) return end
	
	if enemy and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ArrayRange) then Player.PrepareUnitOrders(Players.GetLocal(),4, enemy, Vector(0,0,0), enemy, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero) end
	end
	if enemy and not NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ArrayRange) and not NPC.HasModifier(myHero, "modifier_item_hurricane_pike_range") then Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, enemy, mousePos, enemy, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero) end 
end
	
return Lina
