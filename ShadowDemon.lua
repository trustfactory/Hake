local Utility = require("Utility")

local Shadow = {}

Shadow.optionKey1 = Menu.AddKeyOption({"Hero Specific","Shadow Demon"},"3. Poison Harass Key",Enum.ButtonCode.KEY_F)
Shadow.optionKey = Menu.AddKeyOption({"Hero Specific","Shadow Demon"},"2. Combo Key",Enum.ButtonCode.KEY_D)
Shadow.optionEnable = Menu.AddOption({"Hero Specific","Shadow Demon"},"1. Enabled","Enable/Disable Shadow Demon Combo")
Shadow.optionSDBlink = Menu.AddOption({ "Hero Specific", "Shadow Demon" }, "4. Use Blink to Initiate {{Shadow Demon}}", "")
Shadow.optionSDBlinkRange = Menu.AddOption({ "Hero Specific", "Shadow Demon" }, "5. Set Safe Blink Initiation Range {{Shadow Demon}}", "If over 550, then Euls will not activate in combo", 200, 800, 50)
Shadow.EulsEnable = Menu.AddOption({"Hero Specific", "Shadow Demon"}, "6. Turn On/Off Euls in Combo", "")
Shadow.UltEnable = Menu.AddOption({"Hero Specific", "Shadow Demon"}, "7. Turn On/Off Ult in Combo", "")
Shadow.posList = {}

function Shadow.OnUpdate()
    if not Menu.IsEnabled(Shadow.optionEnable) then return true end
	if Menu.IsKeyDown(Shadow.optionKey) then
    Shadow.Combo()
	end
	
	if not Menu.IsEnabled(Shadow.optionEnable) then return true end
	if Menu.IsKeyDown(Shadow.optionKey1) then
    Shadow.PoisonHarass()
	end
end

function Shadow.PoisonHarass(myHero)
if not Menu.IsKeyDown(Shadow.optionKey1) then return end
	local myHero = Heroes.GetLocal()
	local mana = NPC.GetMana(myHero)
	local npc = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_shadow_demon" then return end
    local Poison = NPC.GetAbility(myHero, "shadow_demon_shadow_poison")
    if not Poison or not Ability.IsCastable(Poison, NPC.GetMana(myHero)) then return end

    local enemies = NPC.GetHeroesInRadius(myHero, Utility.GetCastRange(myHero, Poison), Enum.TeamType.TEAM_ENEMY)
    if not enemies or #enemies <= 0 then end

    for i, npc in ipairs(enemies) do
        if npc and not NPC.IsIllusion(npc) and Ability.IsCastable(Poison, mana) then
            local speed = 1000
            local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(npc)):Length()
            local delay = dis / speed
            local pos = Utility.GetPredictedPosition(npc, delay)

            if not Shadow.PositionIsCovered(pos) then
                Ability.CastPosition(Poison, pos)
                table.insert(Shadow.posList, pos)
                return
            end
        end
    end
end

function Shadow.PositionIsCovered(pos)
    if not Shadow.posList or #Shadow.posList <= 0 then return false end

    local range = 200
    for i, vec in ipairs(Shadow.posList) do
        if vec and (pos - vec):Length() <= range then return true end
	end
end

function Shadow.Combo()
if not Menu.IsKeyDown(Shadow.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_shadow_demon" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local heroPos = Entity.GetAbsOrigin(hero)
	local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not hero then return end
	
    local Disruption = NPC.GetAbility(myHero, "shadow_demon_disruption")
    local Catcher = NPC.GetAbility(myHero, "shadow_demon_soul_catcher")
    local Poison = NPC.GetAbility(myHero, "shadow_demon_shadow_poison")
    local Ult = NPC.GetAbility(myHero, "shadow_demon_demonic_purge")
    
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Atos = NPC.GetItem(myHero, "item_rod_of_atos", true)
    local Veil  = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local Euls = NPC.GetItem(myHero, "item_cyclone", true)
	
	if Menu.IsEnabled(Shadow.optionEnable) then
	
	if Blink and Menu.IsEnabled(Shadow.optionSDBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, hero, 1150 + Menu.GetValue(Shadow.optionSDBlinkRange)) then
	Ability.CastPosition(Blink, (Entity.GetAbsOrigin(hero) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(hero)):Normalized():Scaled(Menu.GetValue(Shadow.optionSDBlinkRange)))) return end
    end
	
	if Atos and Ability.IsCastable(Atos, mana) and not NPC.IsIllusion(hero) and not NPC.GetModifier(hero, "modifier_sheepstick_debuff") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1100,0) then Ability.CastTarget(Atos, hero) return end
	
	if Veil and Ability.IsCastable(Veil, mana) and not NPC.IsIllusion(hero) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),950,0) then Ability.CastPosition(Veil, heroPos) return end
	
	if Disruption and Ability.IsCastable(Disruption, mana) and not NPC.IsIllusion(hero) and Utility.GetCastRange(myHero, Disruption) then Ability.CastTarget(Disruption, hero) return end
	
	if Catcher and Ability.IsCastable(Catcher, mana) and not NPC.IsIllusion(hero) and Utility.GetCastRange(myHero, Catcher) then Ability.CastPosition(Catcher, heroPos) return end
	
	if Poison and Ability.IsCastable(Poison, mana) and not NPC.IsIllusion(hero) and Utility.GetCastRange(myHero, Poison) then Ability.CastPosition(Poison, heroPos) return end
	
	if Euls and Menu.IsEnabled(Shadow.EulsEnable) and Ability.IsCastable(Euls, mana) and not NPC.IsIllusion(hero) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),550,0) then Ability.CastTarget(Euls, hero) return end

	if Ult and Menu.IsEnabled(Shadow.UltEnable) and Ability.IsCastable(Ult, mana) and not NPC.IsIllusion(hero) and Utility.CanCastSpellOn(hero) and Utility.GetCastRange(myHero, Ult) then Ability.CastTarget(Ult, hero) return 
	end
end
	
return Shadow