local Utility = require("Utility")

local Silencer = {}

local optionAutoSilence = Menu.AddOption({"Hero Specific", "Silencer"}, "Auto Silence", "Auto cast 'Silence' to interrupt channelled ult")
local font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function Silencer.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero then return end
    if not Utility.IsSuitableToCastSpell(myHero) then return end
    
    if Menu.IsEnabled(optionAutoSilence) then
        Silencer.AutoSilence(myHero)
    end
end

function Silencer.AutoSilence(myHero)
	local Silence = NPC.GetAbility(myHero, "silencer_global_silence")
	local mana = NPC.GetMana(myHero)
	if not myHero then return end

	if not Menu.IsEnabled(optionAutoSilence) then return end

	if not Silence then return end
		if not Ability.IsCastable(Silence, mana) then return end


	for i = 1, Heroes.Count() do
		local enemy = Heroes.Get(i)
		if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_enigma" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local blackHole = NPC.GetAbility(enemy, "enigma_black_hole")
				
				if blackHole and Ability.IsInAbilityPhase(blackHole) or Ability.IsChannelling(blackHole) then
					if Ability.IsReady(Silence) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastNoTarget(Silence)
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_sand_king" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local epicenter = NPC.GetAbility(enemy, "sandking_epicenter")
				
				if epicenter and Ability.IsChannelling(epicenter) then
					if Ability.IsReady(Silence) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastNoTarget(Silence) 
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_witch_doctor" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local deathward = NPC.GetAbility(enemy, "witch_doctor_death_ward")
				
				if deathward and Ability.IsInAbilityPhase(deathward) or Ability.IsChannelling(deathward) then
					if Ability.IsReady(Silence) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastNoTarget(Silence) 
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_crystal_maiden" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local freezing = NPC.GetAbility(enemy, "crystal_maiden_freezing_field")
				
				if freezing and Ability.IsInAbilityPhase(freezing) or Ability.IsChannelling(freezing) then
					if Ability.IsReady(Silence) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastNoTarget(Silence) 
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_bane" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local grip = NPC.GetAbility(enemy, "bane_fiends_grip")
				
				if grip and Ability.IsInAbilityPhase(grip) or Ability.IsChannelling(grip) then
					if Ability.IsReady(Silence) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastNoTarget(Silence) 
					return end
				end
			end
		end
	end
end

return Silencer
