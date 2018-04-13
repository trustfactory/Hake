local Utility = require("Utility")
local Lina = {}

Lina.optionKey = Menu.AddKeyOption({"Hero Specific","Lina"},"2. Euls Combo Key",Enum.ButtonCode.KEY_S)
Lina.optionKey2 = Menu.AddKeyOption({"Hero Specific","Lina"},"3. Non-Euls Combo Key",Enum.ButtonCode.KEY_D)
Lina.optionEnable = Menu.AddOption({"Hero Specific","Lina"},"1. Enabled","Enable Or Disable Lina Combo Script")
Lina.optionBlink = Menu.AddOption({"Hero Specific", "Lina" }, "4. Use Blink to Initiate {{Lina}}", "")
Lina.optionBlinkRange = Menu.AddOption({"Hero Specific", "Lina" }, "5. Set Safe Blink Initiation Range {{Lina}}", "If using Pike then set at 475, If not using Pike set at 575", 200, 800, 25)
--Skills Toggle Menu--
Lina.optionEnableDragon = Menu.AddOption({"Hero Specific","Lina","6. Skills"},"1. Use Dragon Slave","Enable Or Disable")
Lina.optionEnableArray = Menu.AddOption({"Hero Specific","Lina","6. Skills"},"2. Use Light Strike Array","Enable Or Disable")
Lina.optionEnableUlt = Menu.AddOption({"Hero Specific","Lina","6. Skills"},"3. Use Laguna Blade","Enable Or Disable")
--Items Toggle Menu--
Lina.optionEnableBKB = Menu.AddOption({"Hero Specific", "Lina","7. Items"},"1. Use BKB After Blink","Turn On/Off BKB in Combo")
Lina.optionEnableEuls = Menu.AddOption({"Hero Specific","Lina","7. Items"},"2. Use Euls","Turn On/Off Euls in Combo")
Lina.optionEnableOrchid = Menu.AddOption({"Hero Specific","Lina","7. Items"},"3. Use Orchid","Turn On/Off Orchid in Combo")
Lina.optionEnablePike = Menu.AddOption({"Hero Specific","Lina","7. Items"},"4. Use Hurricane Pike","Turn On/Off Pike in Combo")
Lina.optionEnableThorn = Menu.AddOption({"Hero Specific","Lina","7. Items"},"5. Use Bloodthorn","Turn On/Off Bloodthorn in Combo")

function Lina.OnUpdate()
    if not Menu.IsEnabled(Lina.optionEnable) then return true end
	if Menu.IsKeyDown(Lina.optionKey)then
    Lina.Combo()
	end
	
	if not Menu.IsEnabled(Lina.optionEnable) then return true end
	if Menu.IsKeyDown(Lina.optionKey2)then
    Lina.Combo2()
	end
end	


function Lina.Combo()
if not Menu.IsKeyDown(Lina.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_lina" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not hero then return end

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
  	local LagunaRange = 600
 
--Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_cast_range_125")
    
    if Lens then
    		DragonRange = DragonRange + 250
    		LagunaRange = LagunaRange + 250
    end
	
	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
    		DragonRange = DragonRange + 125
    		LagunaRange = LagunaRange + 125
  	end		
	
	if Menu.IsEnabled(Lina.optionEnable) then
	
	if hero and not NPC.IsIllusion(hero) and Utility.CanCastSpellOn(hero) then
        if Blink and Menu.IsEnabled(Lina.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, hero, 1150 + Menu.GetValue(Lina.optionBlinkRange)) then
            Ability.CastPosition(Blink, (Entity.GetAbsOrigin(hero) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(hero)):Normalized():Scaled(Menu.GetValue(Lina.optionBlinkRange)))) return end
        end
	
	if BKB and Menu.IsEnabled(Lina.optionEnableBKB) and Ability.IsCastable(BKB, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),575) then Ability.CastNoTarget(BKB) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Euls and Menu.IsEnabled(Lina.optionEnableEuls) and Ability.IsCastable(Euls, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Euls)) then Ability.CastTarget(Euls, hero) return end
		     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Dragon and Menu.IsEnabled(Lina.optionEnableDragon) and Ability.IsCastable(Dragon, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), DragonRange) then Ability.CastTarget(Dragon, hero) return end
			     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Laguna and Menu.IsEnabled(Lina.optionEnableUlt) and Ability.IsCastable(Laguna, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), LagunaRange) then Ability.CastTarget(Laguna, hero) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Orchid and Menu.IsEnabled(Lina.optionEnableOrchid) and Ability.IsCastable(Orchid, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Orchid)) then Ability.CastTarget(Orchid, hero) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Thorn and Menu.IsEnabled(Lina.optionEnableThorn) and Ability.IsCastable(Thorn, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Thorn)) then Ability.CastTarget(Thorn, hero) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Pike and Menu.IsEnabled(Lina.optionEnablePike) and Ability.IsCastable(Pike, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Pike)) then Ability.CastTarget(Pike, hero) return end
	end
	Player.PrepareUnitOrders(Players.GetLocal(),4, hero, Vector(0,0,0), hero, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
end

function Lina.Combo2()
if not Menu.IsKeyDown(Lina.optionKey2) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_lina" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local heroPos = Entity.GetAbsOrigin(hero)
    local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not hero then return end

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
 
--Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_cast_range_125")
    
    if Lens then
    		DragonRange = DragonRange + 250
    		ArrayRange = ArrayRange + 250
    		LagunaRange = LagunaRange + 250
    end
	
	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
    		DragonRange = DragonRange + 125
    		ArrayRange = ArrayRange + 125
    		LagunaRange = LagunaRange + 125
  	end		
	
	if Menu.IsEnabled(Lina.optionEnable) then
	
	if hero and not NPC.IsIllusion(hero) and Utility.CanCastSpellOn(hero) then
        if Blink and Menu.IsEnabled(Lina.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, hero, 1150 + Menu.GetValue(Lina.optionBlinkRange)) then
            Ability.CastPosition(Blink, (Entity.GetAbsOrigin(hero) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(hero)):Normalized():Scaled(Menu.GetValue(Lina.optionBlinkRange)))) return end
        end
	
	if BKB and Menu.IsEnabled(Lina.optionEnableBKB) and Ability.IsCastable(BKB, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),575) then Ability.CastNoTarget(BKB) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Array and Menu.IsEnabled(Lina.optionEnableArray) and Ability.IsCastable(Array, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), (ArrayRange)-25) then Ability.CastPosition(Array, heroPos) return end
			     	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Dragon and Menu.IsEnabled(Lina.optionEnableDragon) and Ability.IsCastable(Dragon, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), DragonRange) then Ability.CastTarget(Dragon, hero) return end
			     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Laguna and Menu.IsEnabled(Lina.optionEnableUlt) and Ability.IsCastable(Laguna, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), LagunaRange) then Ability.CastTarget(Laguna, hero) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Orchid and Menu.IsEnabled(Lina.optionEnableOrchid) and Ability.IsCastable(Orchid, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Orchid)) then Ability.CastTarget(Orchid, hero) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Thorn and Menu.IsEnabled(Lina.optionEnableThorn) and Ability.IsCastable(Thorn, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Thorn)) then Ability.CastTarget(Thorn, hero) return end
	
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Pike and Menu.IsEnabled(Lina.optionEnablePike) and Ability.IsCastable(Pike, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Pike)) then Ability.CastTarget(Pike, hero) return end
	end
	Player.PrepareUnitOrders(Players.GetLocal(),4, hero, Vector(0,0,0), hero, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
end
	
return Lina