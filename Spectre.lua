local Spectre = {}

local optionAutoHaunt = Menu.AddOption({"Hero Specific", "Spectre"}, "Auto Haunt", "Auto cast 'Haunt' to KS low enemy")
local key = Menu.AddKeyOption({"Hero Specific", "Spectre"}, "Activate Auto Spells Key", Enum.ButtonCode.KEY_S)
local font = Renderer.LoadFont("Tahoma", 25, Enum.FontWeight.EXTRABOLD)
local inAutoSpellsMode = false

function Spectre.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero then return end
    
    if Menu.IsKeyDownOnce(key) then
        inAutoSpellsMode = not inAutoSpellsMode
    end
    
    if Menu.IsEnabled(optionAutoHaunt) and inAutoSpellsMode then
        Spectre.AutoHaunt(myHero)
    end
end

function Spectre.OnDraw()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_spectre" then return end
    if not inAutoSpellsMode then return end
    local pos = Entity.GetAbsOrigin(myHero)
    local x, y, visible = Renderer.WorldToScreen(pos)
    Renderer.SetDrawColor(255, 255, 0, 255)
    Renderer.DrawTextCentered(font, x, y, "Auto Haunt ON", 1)
end

function Spectre.AutoHaunt(myHero)
	local haunt = NPC.GetAbility(myHero, "spectre_haunt")
	local mana = NPC.GetMana(myHero)
	for i = 1, Heroes.Count() do
	local hero = Heroes.Get(i)
	
    if hero and Entity.IsHero(hero) and not NPC.IsIllusion(hero) and Entity.GetHealth(hero) <= Entity.GetMaxHealth(hero) * 0.15 and Ability.IsReady(haunt) and Ability.IsCastable(haunt, math.floor(mana)) then Ability.CastNoTarget(haunt) return end
    end
end

return Spectre
