local Utility = require("Utility")

local Oracle = {}

local optionAutoSave = Menu.AddOption({"Hero Specific", "Oracle"}, "Auto Save", "Auto cast 'False Promise' to save needed ally")
local optionAutoHeal = Menu.AddOption({"Hero Specific", "Oracle"}, "Auto Heal", "Auto cast 'Purifying Flames' to heal ally")
local font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function Oracle.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero then return end
    if not Utility.IsSuitableToCastSpell(myHero) then return end
    
    if Menu.IsEnabled(optionAutoSave) then
        Oracle.AutoSave(myHero)
    end

    if Menu.IsEnabled(optionAutoHeal) then
        Oracle.AutoHeal(myHero)
    end
end

function Oracle.AutoSave(myHero)
    local promise = NPC.GetAbility(myHero, "oracle_false_promise")
    if not promise or not Ability.IsCastable(promise, NPC.GetMana(myHero)) then return end

    if Utility.NeedToBeSaved(myHero) and Utility.CanCastSpellOn(myHero) then
        Ability.CastTarget(promise, myHero)
        return
    end

    local range = Ability.GetCastRange(promise)
    local allies = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_FRIEND)
    for i, ally in ipairs(allies) do
	    if Utility.NeedToBeSaved(ally) and Utility.CanCastSpellOn(ally) then
	        Ability.CastTarget(promise, ally)
	        return
	    end
    end
end

function Oracle.AutoHeal(myHero)
local flames = NPC.GetAbility(myHero, "oracle_purifying_flames")
    if not flames or not Ability.IsCastable(flames, NPC.GetMana(myHero)) then return end
    
	if Utility.NeedToBeSaved(myHero) and Utility.CanCastSpellOn(myHero) then
	    Ability.CastTarget(flames, myHero)
	    return
	end
	    
    local range = Ability.GetCastRange(flames)
    local allies = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_FRIEND)
    for i, ally in ipairs(allies) do
	    if Utility.NeedToBeSaved(ally) and Utility.CanCastSpellOn(ally) then
		    Ability.CastTarget(flames, ally)
			return
		end 
	end
end   

return Oracle