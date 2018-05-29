local Oracle = {}

Oracle.optionEnable = Menu.AddOption({"Hero Specific","Oracle"}, "1. Enabled", "Enable Or Disable Oracle Combo Script")
Oracle.optionKey = Menu.AddKeyOption({"Hero Specific","Oracle"}, "2. Non-Ult Healing Key", Enum.ButtonCode.KEY_D)
Oracle.optionKey2 = Menu.AddKeyOption({"Hero Specific","Oracle"}, "3. Ult Healing Key", Enum.ButtonCode.KEY_F)
--Items Toggle Menu--
Oracle.optionEnableBottle = Menu.AddOption({"Hero Specific","Oracle","4. Items"},"1. Use Bottle on Target During Ult","Turn On/Off Bottle in Ult Combo")
Oracle.optionEnableGreaves = Menu.AddOption({"Hero Specific","Oracle","4. Items"},"2. Use Greaves on Target During Ult","Turn On/Off Greaves in Ult Combo")
Oracle.optionEnableMekansm = Menu.AddOption({"Hero Specific","Oracle","4. Items"},"3. Use Mekansm on Target During Ult","Turn On/Off Mekansm in Ult Combo")
Oracle.optionEnableSalve = Menu.AddOption({"Hero Specific","Oracle","4. Items"},"4. Use Salve on Target During Ult","Turn On/Off Salve in Ult Combo")
Oracle.optionEnableUrn = Menu.AddOption({"Hero Specific","Oracle","4. Items"},"5. Use Urn on Target During Ult","Turn On/Off Urn in Ult Combo")
Oracle.optionEnableVessel = Menu.AddOption({"Hero Specific","Oracle","4. Items"},"6. Use Vessel on Target During Ult","Turn On/Off Vessel in Ult Combo")

function Oracle.OnUpdate()
    if not Menu.IsEnabled(Oracle.optionEnable) then return true end
	if Menu.IsKeyDown(Oracle.optionKey)then
    Oracle.Combo()
	end
	
	if not Menu.IsEnabled(Oracle.optionEnable) then return true end
	if Menu.IsKeyDown(Oracle.optionKey2)then
    Oracle.Combo2()
	end
end	


function Oracle.Combo()
if not Menu.IsKeyDown(Oracle.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_oracle" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_FRIEND)
    if not hero then return end
    local mana = NPC.GetMana(myHero)
	
	--Ability Calls--
    local Edict = NPC.GetAbility(myHero, "oracle_fates_edict")
    local Flames = NPC.GetAbility(myHero, "oracle_purifying_flames")
    
    --Item Calls--
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    
    --Ability Ranges--
    local EdictRange = Ability.GetCastRange(Edict)
  	local FlamesRange = Ability.GetCastRange(Flames)
  	
  	--Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_cast_range_150")
    
    if Lens then
    		EdictRange = EdictRange + 250
    		FlamesRange = FlamesRange + 250
    end
	
	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
    		EdictRange = EdictRange + 150
    		FlamesRange = FlamesRange + 150
  	end		
	
	if Menu.IsEnabled(Oracle.optionEnable) then
		     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Edict and Ability.IsCastable(Edict, mana) and Ability.IsReady(Edict) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), EdictRange) then Ability.CastTarget(Edict, hero) return 
	end
			     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Flames and Ability.IsCastable(Flames, mana) and Ability.IsReady(Flames) and NPC.HasModifier(hero, "modifier_oracle_fates_edict") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), EdictRange) then Ability.CastTarget(Flames, hero) return end
	end
	Player.PrepareUnitOrders(Players.GetLocal(), 4, hero, Vector(0,0,0), hero, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero) 
end

function Oracle.Combo2()
if not Menu.IsKeyDown(Oracle.optionKey2) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_oracle" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_FRIEND)
    if not hero then return end
    local mana = NPC.GetMana(myHero)
	
	--Ability Calls--
    local Promise = NPC.GetAbility(myHero, "oracle_false_promise")
    local Flames = NPC.GetAbility(myHero, "oracle_purifying_flames")
    
    --Item Calls--
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local Bottle = NPC.GetItem(myHero, "item_bottle", true)
    local Greaves = NPC.GetItem(myHero, "item_guardian_greaves", true)
    local Mekansm = NPC.GetItem(myHero, "item_mekansm", true)
    local Salve = NPC.GetItem(myHero, "item_flask", true)
    local Urn = NPC.GetItem(myHero, "item_urn_of_shadows", true)
    local Vessel = NPC.GetItem(myHero, "item_spirit_vessel", true)
    
    --Ability Ranges--
    local PromiseRange = Ability.GetCastRange(Promise)
  	local FlamesRange = Ability.GetCastRange(Flames)
  	
  	--Item Ranges--
  	local BottleRange = 350
  	local GreavesRange = 900
  	local MekansmRange = 900
  	local SalveRange = 250
  	local UrnRange = 950
  	local VesselRange = 950
  	
  	--Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_cast_range_150")
    
    if Lens then
    		PromiseRange = PromiseRange + 250
    		FlamesRange = FlamesRange + 250
    		BottleRange = BottleRange + 250
    		SalveRange = SalveRange + 250
    		UrnRange = UrnRange + 250
    		VesselRange = VesselRange + 250
    end
	
	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
    		PromiseRange = PromiseRange + 150
    		FlamesRange = FlamesRange + 150
    		BottleRange = BottleRange + 150
    		SalveRange = SalveRange + 150
    		UrnRange = UrnRange + 150
    		VesselRange = VesselRange + 150
  	end		
  	
  	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 and NPC.HasItem(myHero, "item_aether_lens", true) then
    		PromiseRange = PromiseRange + 150
    		FlamesRange = FlamesRange + 150
    		BottleRange = BottleRange + 150
    		SalveRange = SalveRange + 150
    		UrnRange = UrnRange + 150
    		VesselRange = VesselRange + 150
  	end		
	
	if Menu.IsEnabled(Oracle.optionEnable) then
		     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Promise and Ability.IsCastable(Promise, mana) and Ability.IsReady(Promise) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), PromiseRange) then Ability.CastTarget(Promise, hero) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Bottle and Menu.IsEnabled(Oracle.optionEnableBottle) and Ability.IsReady(Bottle) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), BottleRange) and NPC.HasModifier(hero, "modifier_oracle_false_promise") and Item.GetCurrentCharges(Bottle) > 0 and not NPC.HasModifier(hero, "modifier_bottle_regeneration") then Ability.CastTarget(Bottle, hero) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Salve and Menu.IsEnabled(Oracle.optionEnableSalve) and Ability.IsReady(Salve) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), SalveRange) and NPC.HasModifier(hero, "modifier_oracle_false_promise") and not NPC.HasModifier(hero, "modifier_flask_healing") then Ability.CastTarget(Salve, hero) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Urn and Menu.IsEnabled(Oracle.optionEnableUrn) and Ability.IsReady(Urn) and Ability.IsCastable(Urn, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), UrnRange) and NPC.HasModifier(hero, "modifier_oracle_false_promise") and Item.GetCurrentCharges(Urn) > 0 and not NPC.HasModifier(hero, "modifier_item_urn_heal") then Ability.CastTarget(Urn, hero) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Vessel and Menu.IsEnabled(Oracle.optionEnableVessel) and Ability.IsReady(Vessel) and Ability.IsCastable(Vessel, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), VesselRange) and NPC.HasModifier(hero, "modifier_oracle_false_promise") and Item.GetCurrentCharges(Vessel) > 0 and not NPC.HasModifier(hero, "modifier_item_spirit_vessel_heal") then Ability.CastTarget(Vessel, hero) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Greaves and Menu.IsEnabled(Oracle.optionEnableGreaves) and Ability.IsReady(Greaves) and Ability.IsCastable(Greaves, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), GreavesRange) and NPC.HasModifier(hero, "modifier_oracle_false_promise") then Ability.CastNoTarget(Greaves) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Mekansm and Menu.IsEnabled(Oracle.optionEnableMekansm) and Ability.IsReady(Mekansm) and Ability.IsCastable(Mekansm, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), MekansmRange) and NPC.HasModifier(hero, "modifier_oracle_false_promise") then Ability.CastNoTarget(Mekansm) return end
			     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Flames and Ability.IsCastable(Flames, mana) and Ability.IsReady(Flames) and NPC.HasModifier(hero, "modifier_oracle_false_promise") then Ability.CastTarget(Flames, hero) return end
	end
	Player.PrepareUnitOrders(Players.GetLocal(), 4, hero, Vector(0,0,0), hero, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
end
	
return Oracle
