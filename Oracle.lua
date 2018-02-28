local Utility = require("Utility")

local Oracle = {}

local optionAutoSave = Menu.AddOption({"Hero Specific", "Oracle"}, "Auto Save", "Auto cast 'False Promise' to save needed ally")
local optionAutoHeal = Menu.AddOption({"Hero Specific", "Oracle"}, "Auto Heal", "Auto cast 'Purifying Flames' to heal ally")
local key = Menu.AddKeyOption({"Hero Specific", "Oracle"}, "Activate Auto Spells Key", Enum.ButtonCode.KEY_S)
local font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
local inAutoSpellsMode = false

function Oracle.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero then return end
    if not Utility.IsSuitableToCastSpell(myHero) then return end
    
    if Menu.IsKeyDownOnce(key) then
        inAutoSpellsMode = not inAutoSpellsMode
    end
    
    if Menu.IsEnabled(optionAutoSave) and inAutoSpellsMode then
        Oracle.AutoSave(myHero)
    end

    if Menu.IsEnabled(optionAutoHeal) and inAutoSpellsMode then
        Oracle.AutoHeal(myHero)
    end
end

function Oracle.OnDraw()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_oracle" then return end
    if not inAutoSpellsMode then return end
    local pos = Entity.GetAbsOrigin(myHero)
    local x, y, visible = Renderer.WorldToScreen(pos)
    Renderer.SetDrawColor(255, 255, 0, 255)
    Renderer.DrawTextCentered(font, x, y, "I Know De Wey", 1)
end

function Oracle.AutoSave(myHero)
    local promise = NPC.GetAbility(myHero, "oracle_false_promise")
    local mana = NPC.GetMana(myHero)
    local range = Ability.GetCastRange(promise)
    local teamMatesAround = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_FRIEND)
    if next(teamMatesAround) ~= nil then
    for _, ally in ipairs(teamMatesAround) do
    if ally and Entity.IsHero(ally) and not NPC.IsIllusion(ally) and Entity.GetHealth(ally) <= Entity.GetMaxHealth(ally) * 0.3 and Ability.IsReady(promise) and Ability.IsCastable(promise, math.floor(mana)) then
    Ability.CastTarget(promise, ally)
    return end
    
    local myHealth = Entity.GetHealth(myHero)

    if myHealth <= Entity.GetMaxHealth(myHero) * 0.3 and Ability.IsReady(promise) and Ability.IsCastable(promise, math.floor(mana)) then
    Ability.CastTarget(promise, myHero)
    return end
	end
end
end

function Oracle.AutoHeal(myHero)
    local flames = NPC.GetAbility(myHero, "oracle_purifying_flames")
    local mana = NPC.GetMana(myHero)
    local range = Ability.GetCastRange(flames)
    local teamMatesAround = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_FRIEND)
    if next(teamMatesAround) ~= nil then
    for _, ally in ipairs(teamMatesAround) do
    if ally and Entity.IsHero(ally) and not NPC.IsIllusion(ally) and Entity.GetHealth(ally) <= Entity.GetMaxHealth(ally) * 0.3 and Ability.IsReady(flames) and Ability.IsCastable(flames, math.floor(mana)) then
    Ability.CastTarget(flames, ally)
    return end
    
    local myHealth = Entity.GetHealth(myHero)

    if myHealth <= Entity.GetMaxHealth(myHero) * 0.3 and Ability.IsReady(flames) and Ability.IsCastable(flames, math.floor(mana)) then
    Ability.CastTarget(flames, myHero)
    return end
end  
end
end

return Oracle
