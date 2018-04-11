local Sandking = {}

Sandking.optionKey = Menu.AddKeyOption({"Hero Specific","Sandking"},"2. Non-Ult Combo Key",Enum.ButtonCode.KEY_D)
Sandking.optionKey2 = Menu.AddKeyOption({"Hero Specific","Sandking"},"3. Ult Combo Key",Enum.ButtonCode.KEY_F)
Sandking.optionEnable = Menu.AddOption({"Hero Specific","Sandking"},"1. Enabled","Enable Or Disable Sandking Combo Script")
--Skills Toggle Menu--
Sandking.optionEnableBurrowStrike = Menu.AddOption({ "Hero Specific","Sandking","4. Skills"},"1. Use BurrowStrike","Enable Or Disable")
Sandking.optionEnableSandstorm = Menu.AddOption({ "Hero Specific","Sandking","4. Skills"},"2. Use Sandstorm","Enable Or Disable")
Sandking.optionEnableUlt = Menu.AddOption({ "Hero Specific","Sandking","4. Skills"},"3. Use Epicenter","Enable Or Disable")
--Items Toggle Menu--
Sandking.BKBEnable = Menu.AddOption({"Hero Specific", "Sandking"}, "5. Use BKB Before Ultimate", "")
Sandking.BKBEnable1 = Menu.AddOption({"Hero Specific", "Sandking"}, "6. Use BKB After Ultimate", "")

function Sandking.OnUpdate()
    if not Menu.IsEnabled(Sandking.optionEnable) then return true end
	if Menu.IsKeyDown(Sandking.optionKey)then
    Sandking.Combo()
    end
    
    if not Menu.IsEnabled(Sandking.optionEnable) then return true end
	if Menu.IsKeyDown(Sandking.optionKey2)then
    Sandking.Combo2()
	end
end

function Sandking.Combo()
if not Menu.IsKeyDown(Sandking.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_sand_king" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local heroPos = Entity.GetAbsOrigin(hero)
	local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not hero then return end
	
    local BurrowStrike = NPC.GetAbility(myHero, "sandking_burrowstrike")
    local Sandstorm = NPC.GetAbility(myHero, "sandking_sand_storm")
    
    local BKB = NPC.GetItem(myHero, "item_black_king_bar", true)
    local Hood = NPC.GetItem(myHero, "item_hood_of_defiance", true)
    local Pipe = NPC.GetItem(myHero, "item_pipe", true)
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Veil  = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local Shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
	
	if Menu.IsEnabled(Sandking.optionEnable) then
	
	if not NPC.IsPositionInRange(myHero,Entity.GetAbsOrigin(hero), 0 , 275) then 
	if Blink and Ability.IsCastable(Blink, mana) and hero ~= nil and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200) then Ability.CastPosition(Blink, mousePos) return end
	end
	
	if Hood and Ability.IsCastable(Hood, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200) then Ability.CastNoTarget(Hood) return end
	
	if Pipe and Ability.IsCastable(Pipe, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200) then Ability.CastNoTarget(Pipe) return end
	
	if Veil and Ability.IsCastable(Veil, mana) then Ability.CastPosition(Veil, heroPos) return end
	
	if Shivas and Ability.IsCastable(Shivas, mana) then Ability.CastNoTarget(Shivas) return end
	
	if BurrowStrike and Menu.IsEnabled(Sandking.optionEnableBurrowStrike) and Ability.IsCastable(BurrowStrike, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(BurrowStrike)) then Ability.CastTarget(BurrowStrike, hero) return end
	
	if Sandstorm and Menu.IsEnabled(Sandking.optionEnableSandstorm) and Ability.IsCastable (Sandstorm, mana) then Ability.CastNoTarget (Sandstorm) return end
  	if Ability.IsInAbilityPhase(Sandstorm) then return end
  	if Ability.IsChannelling(Sandstorm) then return end
	end
end
	
function Sandking.Combo2()
if not Menu.IsKeyDown(Sandking.optionKey2) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_sand_king" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local heroPos = Entity.GetAbsOrigin(hero)
	local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not hero then return end
	
    local Epicenter = NPC.GetAbility(myHero, "sandking_epicenter")
    local BurrowStrike = NPC.GetAbility(myHero, "sandking_burrowstrike")
    local Sandstorm = NPC.GetAbility(myHero, "sandking_sand_storm")
    
    local BKB = NPC.GetItem(myHero, "item_black_king_bar", true)
    local Hood = NPC.GetItem(myHero, "item_hood_of_defiance", true)
    local Pipe = NPC.GetItem(myHero, "item_pipe", true)
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Veil  = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local Shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
	
	if Menu.IsEnabled(Sandking.optionEnable) then
	
	if BKB and Menu.IsEnabled(Sandking.BKBEnable) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200) and Ability.IsCastable(BKB, mana)then Ability.CastNoTarget(BKB) return end
	
	
	if Epicenter and Menu.IsEnabled(Sandking.optionEnableUlt) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200) and Ability.IsCastable (Epicenter, mana) then Ability.CastNoTarget (Epicenter) return end
  	if Ability.IsInAbilityPhase(Epicenter) then return end
  	if Ability.IsChannelling(Epicenter) then return end
	
	if not NPC.IsPositionInRange(myHero,Entity.GetAbsOrigin(hero), 0 , 275) then 
	if Blink and Ability.IsCastable(Blink, mana) and hero ~= nil and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200) then Ability.CastPosition(Blink, mousePos) return end
	end
	
	if Hood and Ability.IsCastable(Hood, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200) then Ability.CastNoTarget(Hood) return end
	
	if Pipe and Ability.IsCastable(Pipe, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200) then Ability.CastNoTarget(Pipe) return end
	
	if BKB and Menu.IsEnabled(Sandking.BKBEnable1) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200) and Ability.IsCastable(BKB, mana) then Ability.CastNoTarget(BKB) return end
	
	if Veil and Ability.IsCastable(Veil, mana) then Ability.CastPosition(Veil, heroPos) return end
	
	if Shivas and Ability.IsCastable(Shivas, mana) then Ability.CastNoTarget(Shivas) return end
	
	if BurrowStrike and Menu.IsEnabled(Sandking.optionEnableBurrowStrike) and Ability.IsCastable(BurrowStrike, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(BurrowStrike)) then Ability.CastTarget(BurrowStrike, hero) return end
	
	if Sandstorm and Menu.IsEnabled(Sandking.optionEnableSandstorm) and Ability.IsCastable (Sandstorm, mana) then Ability.CastNoTarget (Sandstorm) return end
  	if Ability.IsInAbilityPhase(Sandstorm) then return end
  	if Ability.IsChannelling(Sandstorm) then return end
	end
end
	
return Sandking
