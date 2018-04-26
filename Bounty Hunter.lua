local Utility = require("Utility")
local BountyHunter = {}

BountyHunter.optionEnable = Menu.AddOption({"Hero Specific", "Bounty Hunter"}, "0. Enabled", "Enable Or Disable BH Auto Script")
BountyHunter.optionKillSteal = Menu.AddOption({"Hero Specific", "Bounty Hunter"}, "1. Tracked Bounce KS", "Calculates killable target through bounces if tracked")
BountyHunter.optionKey = Menu.AddKeyOption({"Hero Specific","Bounty Hunter"}, "2. Combo Key", Enum.ButtonCode.KEY_S)
BountyHunter.ToggleKey = Menu.AddKeyOption({"Hero Specific", "Bounty Hunter"}, "3.Toggle Auto Mode Key", Enum.ButtonCode.KEY_D)
BountyHunter.InvisAfterTrack = Menu.AddOption({"Hero Specific", "Bounty Hunter"}, "4. Auto-Cast Shadow Walk post-Track", "Auto-casts WindWalk after Track is Auto cast")
BountyHunter.ScrollBoTsCancel = Menu.AddOption({"Hero Specific", "Bounty Hunter"}, "5. Auto-Cancel TPs and Ult Channel", "Cancels TP/BoT/Ult Channels with Shuriken")

--Auto Track Kill Threshold--
BountyHunter.ThresholdEnable = Menu.AddOption({"Hero Specific", "Bounty Hunter"}, "6. Enable Auto Track on %", "Enables or Disable Auto Track on Desired Enemy HP %")
BountyHunter.KillableHealth = Menu.AddOption({ "Hero Specific", "Bounty Hunter", "7. Set Threshold %"}, "Treshold Hero Health", "Set threshold for Killable Enemy", 5, 75, 5)
BountyHunter.FontLarge = Renderer.LoadFont("Calibri", 24, Enum.FontWeight.EXTRABOLD)

--Skills Toggle Menu--
BountyHunter.optionEnableWind = Menu.AddOption({"Hero Specific","Bounty Hunter","8. Skills"},"Use Shadow Walk in Combo","Enable Or Disable")
BountyHunter.optionEnableShuriken = Menu.AddOption({"Hero Specific","Bounty Hunter","8. Skills"},"Use Shuriken in Combo","Enable Or Disable")
BountyHunter.optionEnableTrack = Menu.AddOption({"Hero Specific","Bounty Hunter","8. Skills"},"Use Track in Combo","Enable Or Disable")

--Items Toggle Menu--
BountyHunter.optionEnableAbyssal = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use Abyssal in Combo","Use Abyssal on Target During Combo")
BountyHunter.optionEnableButterfly = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use Butterfly in Combo","Use Butterfly on Self During Combo")
BountyHunter.optionEnableThorn = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use BloodThorn in Combo","Use BloodThorn on Target During Combo")
BountyHunter.optionEnableDagon = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use Dagon in Combo","Use Dagon on Target During Combo")
BountyHunter.optionEnableEBlade = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use EBlade in Combo","Use EBlade on Target During Combo")
BountyHunter.optionEnableHalberd = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use Halberd in Combo","Use Halberd on Target During Combo")
BountyHunter.optionEnableMedallion = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use Medallion in Combo","Use Medallion on Target During Combo")
BountyHunter.optionEnableNullifier = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use Nullifier in Combo","Use Nullifier on Target During Combo")
BountyHunter.optionEnableOrchid = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use Orchid in Combo","Use Orchid on Target During Combo")
BountyHunter.optionEnableScythe = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use Scythe in Combo","Use Scythe on Target During Combo")
BountyHunter.optionEnableSolarCrest = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use Solar Crest in Combo","Use Solar Crest on Target During Combo")
BountyHunter.optionEnableUrn = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use Urn in Combo","Use Urn on Target During Combo")
BountyHunter.optionEnableVessel = Menu.AddOption({"Hero Specific","Bounty Hunter","9. Items"},"Use Vessel in Combo","Use Vessel on Target During Combo")

local AutoMode = false

-- global Variables
BountyHunter.lastAttackTime = 0
BountyHunter.lastAttackTime2 = 0
BountyHunter.LastTarget = nil

function BountyHunter.ResetGlobalVariables()
    BountyHunter.lastAttackTime = 0
	BountyHunter.lastAttackTime2 = 0
	BountyHunter.LastTarget = nil
end

function BountyHunter.isHeroChannelling(myHero)

	if not myHero then return true end

	if NPC.IsChannellingAbility(myHero) then return true end
	if NPC.HasModifier(myHero, "modifier_teleporting") then return true end

	return false
end

function BountyHunter.heroCanCastItems(myHero)

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

function BountyHunter.IsInAbilityPhase(myHero)

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

function BountyHunter.Debugger(time, npc, ability, order)

	if not Menu.IsEnabled(BountyHunter.optionEnable) then return end
	Log.Write(tostring(time) .. " " .. tostring(NPC.GetUnitName(npc)) .. " " .. tostring(ability) .. " " .. tostring(order))
end

function BountyHunter.GenericMainAttack(myHero, attackType, target, position)
	
	if not myHero then return end
	if not target and not position then return end

	if BountyHunter.isHeroChannelling(myHero) == true then return end
	if BountyHunter.heroCanCastItems(myHero) == false then return end
	if BountyHunter.IsInAbilityPhase(myHero) == true then return end

	if Menu.IsEnabled(BountyHunter.optionEnable) then
		if target ~= nil then
			BountyHunter.GenericAttackIssuer(attackType, target, position, myHero)
		end
	else
		BountyHunter.GenericAttackIssuer(attackType, target, position, myHero)
	end
end

function BountyHunter.GenericAttackIssuer(attackType, target, position, npc)

	if not npc then return end
	if not target and not position then return end
	if os.clock() - BountyHunter.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= BountyHunter.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				BountyHunter.LastTarget = target
				BountyHunter.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= BountyHunter.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					BountyHunter.LastTarget = position:__tostring()
					BountyHunter.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= BountyHunter.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				BountyHunter.LastTarget = position:__tostring()
				BountyHunter.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == BountyHunter.LastTarget then
			if not NPC.IsAttacking(npc) then
				BountyHunter.LastTarget = nil
				BountyHunter.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == BountyHunter.LastTarget then
			if not NPC.IsRunning(npc) then
				BountyHunter.LastTarget = nil
				BountyHunter.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

function BountyHunter.IsSuitableToCastSpell(myHero)
	if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
	return true
end

function BountyHunter.TossTarget(myHero, target, toss, r1, r2, counter)
    -- set maximum depth as 3 to avoid infinite loops
    if counter >= 3 then return end
    if Utility.CanCastSpellOn(target) and NPC.IsEntityInRange(myHero, target, r1) then Ability.CastTarget(toss, target) return end

    if NPC.HasModifier(target, "modifier_bounty_hunter_track") then
        for i, npc in ipairs(NPC.GetUnitsInRadius(target, r2, Enum.TeamType.TEAM_FRIEND)) do
            BountyHunter.TossTarget(myHero, npc, toss, r1, r2, counter+1)
        end
    else
        for i, npc in ipairs(NPC.GetUnitsInRadius(target, r1, Enum.TeamType.TEAM_FRIEND)) do
            BountyHunter.TossTarget(myHero, npc, toss, r1, r2, counter+1)
        end
    end
end

function BountyHunter.OnDraw()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_bounty_hunter" then return end
    if not AutoMode then return end

    --Displays when Auto Mode is toggled On--
    local pos = Entity.GetAbsOrigin(myHero)
    local x, y, visible = Renderer.WorldToScreen(pos)
    Renderer.SetDrawColor(0, 255, 0, 255)
    Renderer.DrawTextCentered(BountyHunter.FontLarge, x, y, "Auto", 1)
end

function BountyHunter.OnUpdate()
	if not Menu.IsEnabled(BountyHunter.optionEnable) then return true end
	if Menu.IsKeyDown(BountyHunter.optionKey) and not AutoMode then
    BountyHunter.Combo()
	end
	
	if Menu.IsEnabled(BountyHunter.optionKillSteal) then
        BountyHunter.KillSteal()
	end
	
	if Menu.IsEnabled(BountyHunter.ThresholdEnable) then
        BountyHunter.KillableTrack()
	end
	
	if Menu.IsKeyDownOnce(BountyHunter.ToggleKey) then
        AutoMode = not AutoMode
    end
    if not AutoMode then return 
	end
	
	if Menu.IsEnabled(BountyHunter.InvisAfterTrack) and AutoMode then
        BountyHunter.AutoTrackInvis()
    end
    
    if Menu.IsEnabled(BountyHunter.ScrollBoTsCancel) and AutoMode then
        BountyHunter.ScrollTPCancel()
    end
end

function BountyHunter.KillableTrack()
if not Menu.IsEnabled(BountyHunter.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_bounty_hunter" then return end
	local mana = NPC.GetMana(myHero)
	
	if not myHero then return end  
    
	--Ability Calls--
	local Track = NPC.GetAbility(myHero, "bounty_hunter_track")
	
	--Item Calls--
	local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
	
	--Ability Ranges--
  	local TrackRange = Ability.GetCastRange(Track)
  	
  	--Lens Bonus Range--
  	if Lens then
    	TrackRange = TrackRange + 250
    end
    
    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) then
        
        local KillableEnemy = (Entity.GetHealth(enemy) / Entity.GetMaxHealth(enemy)) * 100

	    if Track and KillableEnemy <= Menu.GetValue(BountyHunter.KillableHealth) and not NPC.HasModifier(enemy, "modifier_bounty_hunter_track") and not NPC.IsLinkensProtected(enemy) and NPC.IsEntityInRange(enemy, myHero, TrackRange) and Ability.IsReady(Track) then
	        if Ability.IsCastable(Track, mana) then
		        Ability.CastTarget(Track, enemy) return 
				end
			end
		end
	end
end

function BountyHunter.KillSteal()
    local myHero = Heroes.GetLocal()
    if not myHero or not BountyHunter.IsSuitableToCastSpell(myHero) then return end

    local Shuriken = NPC.GetAbility(myHero, "bounty_hunter_shuriken_toss")
    if not Shuriken or not Ability.IsCastable(Shuriken, NPC.GetMana(myHero)) then return end
    local level = Ability.GetLevel(Shuriken)
    local damage = 75 * (level + 1)
    
    --Ability Ranges--
    local ShurikenRange = Ability.GetCastRange(Shuriken)
    
    --Lens Bonus Range--
  	if Lens then
    	ShurikenRange = ShurikenRange + 250
    end
    
    if NPC.GetCurrentLevel(myHero) >= 20 then damage = damage + 75 end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy)
        and NPC.GetMagicalArmorDamageMultiplier(enemy) * damage >= Entity.GetHealth(enemy) then

            BountyHunter.TossTarget(myHero, enemy, Shuriken, ShurikenRange, 1200, 0)
            return
        end
    end
end

function BountyHunter.AutoTrackInvis()
    if not Menu.IsEnabled(BountyHunter.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_bounty_hunter" then return end
	local myTeam = Entity.GetTeamNum(myHero)
	local mana = NPC.GetMana(myHero)
    
    
	--Ability Calls--
	local Shuriken = NPC.GetAbility(myHero, "bounty_hunter_shuriken_toss")
	local WindWalk = NPC.GetAbility(myHero, "bounty_hunter_wind_walk")
	local Track = NPC.GetAbility(myHero, "bounty_hunter_track")
	
	--Item Calls--
	local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
	
	--Ability Ranges--
    local ShurikenRange = Ability.GetCastRange(Shuriken)
  	local TrackRange = Ability.GetCastRange(Track)
  	
  	--Lens Bonus Range--
  	if Lens then
    	ShurikenRange = ShurikenRange + 250
    	TrackRange = TrackRange + 250
    end

    if Menu.IsEnabled(BountyHunter.optionEnable) then

	for i = 1, Heroes.Count() do
		local enemy = Heroes.Get(i)
			if Menu.IsEnabled(BountyHunter.InvisAfterTrack) and enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) then
				if Ability.IsReady(Track) and Ability.IsReady(WindWalk) and NPC.GetMana(myHero) > Ability.GetManaCost(WindWalk) + Ability.GetManaCost(Track) and NPC.IsEntityInRange(enemy, myHero, TrackRange) and not NPC.HasModifier(enemy, "modifier_bounty_hunter_track") and not NPC.HasModifier(myHero, "modifier_wind_walk") and not NPC.IsLinkensProtected(enemy) then
					Ability.CastTarget(Track, enemy) return end
					
				if Ability.IsReady(WindWalk) and Ability.IsCastable(WindWalk, mana) and not NPC.HasModifier(myHero, "modifier_wind_walk") and not NPC.IsLinkensProtected(enemy) and Ability.SecondsSinceLastUse(Track)<=1 and Ability.SecondsSinceLastUse(Track)>0 then
					Ability.CastNoTarget(WindWalk) return
				end
			end
		end
	end
end
			
function BountyHunter.ScrollTPCancel()

if not Menu.IsEnabled(BountyHunter.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_bounty_hunter" then return end
	local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
	local mana = NPC.GetMana(myHero)
	
	if not enemy then return end  
    
	--Ability Calls--
	local Shuriken = NPC.GetAbility(myHero, "bounty_hunter_shuriken_toss")
	local WindWalk = NPC.GetAbility(myHero, "bounty_hunter_wind_walk")
	local Track = NPC.GetAbility(myHero, "bounty_hunter_track")
	
	--Item Calls--
	local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
	
	--Ability Ranges--
    local ShurikenRange = Ability.GetCastRange(Shuriken)
  	local TrackRange = Ability.GetCastRange(Track)
  	
  	--Lens Bonus Range--
  	if Lens then
    	ShurikenRange = ShurikenRange + 250
    	TrackRange = TrackRange + 250
    end
    
	local sameTeam = Entity.GetTeamNum(enemy) == myTeam
	if not sameTeam and not Entity.IsDormant(enemy) and Entity.GetHealth(enemy) > 0 then
		local pos = Entity.GetAbsOrigin(enemy)

	if Menu.IsEnabled(BountyHunter.ScrollBoTsCancel) then
		if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_enigma" and not NPC.IsIllusion(enemy) then if Entity.IsAlive(enemy) then
			local Blackhole = NPC.GetAbility(enemy, "enigma_black_hole")
				
		if Blackhole and Ability.IsInAbilityPhase(Blackhole) or Ability.IsChannelling(Blackhole) then
			if Ability.IsReady(Shuriken) and Ability.IsCastable(Shuriken, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShurikenRange +10) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.IsLinkensProtected(enemy) then 
			Ability.CastTarget(Shuriken, enemy) return end
				if Ability.IsReady(WindWalk) and Ability.IsCastable(WindWalk, mana) and not NPC.HasModifier(myHero, "modifier_wind_walk") and Ability.SecondsSinceLastUse(Shuriken)<=1 and Ability.SecondsSinceLastUse(Shuriken)>0 then
			Ability.CastNoTarget(WindWalk) return end
				end
			end
		end
			
		if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_sand_king" and not NPC.IsIllusion(enemy) then if Entity.IsAlive(enemy) then
			local Epicenter = NPC.GetAbility(enemy, "sandking_epicenter")
				
		if Epicenter and Ability.IsChannelling(Epicenter) then
			if Ability.IsReady(Shuriken) and Ability.IsCastable(Shuriken, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShurikenRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.IsLinkensProtected(enemy) then 
			Ability.CastTarget(Shuriken, enemy) return end
				if Ability.IsReady(WindWalk) and Ability.IsCastable(WindWalk, mana) and not NPC.HasModifier(myHero, "modifier_wind_walk") and Ability.SecondsSinceLastUse(Shuriken)<=1 and Ability.SecondsSinceLastUse(Shuriken)>0 then
			Ability.CastNoTarget(WindWalk) return end
				end
			end
		end
			
		if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_witch_doctor" and not NPC.IsIllusion(enemy) then if Entity.IsAlive(enemy) then
			local Deathward = NPC.GetAbility(enemy, "witch_doctor_death_ward")
				
		if Deathward and Ability.IsInAbilityPhase(Deathward) or Ability.IsChannelling(Deathward) then
			if Ability.IsReady(Shuriken) and Ability.IsCastable(Shuriken, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShurikenRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.IsLinkensProtected(enemy) then 
			Ability.CastTarget(Shuriken, enemy) return end
				if Ability.IsReady(WindWalk) and Ability.IsCastable(WindWalk, mana) and not NPC.HasModifier(myHero, "modifier_wind_walk") and Ability.SecondsSinceLastUse(Shuriken)<=1 and Ability.SecondsSinceLastUse(Shuriken)>0 then
			Ability.CastNoTarget(WindWalk) return end
				end
			end
		end
			
		if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_crystal_maiden" and not NPC.IsIllusion(enemy) then if Entity.IsAlive(enemy) then
			local Freezing = NPC.GetAbility(enemy, "crystal_maiden_freezing_field")
				
		if Freezing and Ability.IsInAbilityPhase(Freezing) or Ability.IsChannelling(Freezing) then
			if Ability.IsReady(Shuriken) and Ability.IsCastable(Shuriken, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShurikenRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.IsLinkensProtected(enemy) then 
			Ability.CastTarget(Shuriken, enemy) return end
				if Ability.IsReady(WindWalk) and Ability.IsCastable(WindWalk, mana) and not NPC.HasModifier(myHero, "modifier_wind_walk") and Ability.SecondsSinceLastUse(Shuriken)<=1 and Ability.SecondsSinceLastUse(Shuriken)>0 then
			Ability.CastNoTarget(WindWalk) return end
				end
			end
		end
			
			if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_bane" and not NPC.IsIllusion(enemy) then if Entity.IsAlive(enemy) then
				local Grip = NPC.GetAbility(enemy, "bane_fiends_grip")
			
			if Grip and Ability.IsInAbilityPhase(Grip) or Ability.IsChannelling(Grip) then
				if Ability.IsReady(Shuriken) and Ability.IsCastable(Shuriken, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShurikenRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.IsLinkensProtected(enemy) then 
				Ability.CastTarget(Shuriken, enemy) return end
					if Ability.IsReady(WindWalk) and Ability.IsCastable(WindWalk, mana) and not NPC.HasModifier(myHero, "modifier_wind_walk") and Ability.SecondsSinceLastUse(Shuriken)<=1 and Ability.SecondsSinceLastUse(Shuriken)>0 then
				Ability.CastNoTarget(WindWalk) return end
					end
				end
			end
			
			if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_nevermore" and not NPC.IsIllusion(enemy) then if Entity.IsAlive(enemy) then
				local Requiem = NPC.GetAbility(enemy, "nevermore_requiem")
	  		
			if Requiem and Ability.IsInAbilityPhase(Requiem) then
			    if Ability.IsReady(Shuriken) and Ability.IsCastable(Shuriken, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShurikenRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.IsLinkensProtected(enemy) then 
				Ability.CastTarget(Shuriken, enemy) return end
					if Ability.IsReady(WindWalk) and Ability.IsCastable(WindWalk, mana) and not NPC.HasModifier(myHero, "modifier_wind_walk") and Ability.SecondsSinceLastUse(Shuriken)<=1 and Ability.SecondsSinceLastUse(Shuriken)>0 then
				Ability.CastNoTarget(WindWalk) return end
					end
				end
			end
	    	
			if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_pugna" and not NPC.IsIllusion(enemy) then if Entity.IsAlive(enemy) then
				local Drain = NPC.GetAbility(enemy, "pugna_life_drain")
				
			if Drain and Ability.IsChannelling(Drain) then
				if Ability.IsReady(Shuriken) and Ability.IsCastable(Shuriken, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShurikenRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.IsLinkensProtected(enemy) then 
				Ability.CastTarget(Shuriken, enemy) return end
					if Ability.IsReady(WindWalk) and Ability.IsCastable(WindWalk, mana) and not NPC.HasModifier(myHero, "modifier_wind_walk") and Ability.SecondsSinceLastUse(Shuriken)<=1 and Ability.SecondsSinceLastUse(Shuriken)>0 then
				Ability.CastNoTarget(WindWalk) return end
					end
				end
			end
				
			if enemy and Entity.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_spirit_breaker" and not NPC.IsIllusion(enemy) then if Entity.IsAlive(enemy) then
				local Charge = NPC.GetAbility(enemy, "spirit_breaker_charge_of_darkness")
				
			if Charge and NPC.HasModifier(enemy, "modifier_spirit_breaker_charge_of_darkness") then
				if Ability.IsReady(Shuriken) and Ability.IsCastable(Shuriken, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShurikenRange +10) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.IsLinkensProtected(enemy) then 
				Ability.CastTarget(Shuriken, enemy) return end
					if Ability.IsReady(WindWalk) and Ability.IsCastable(WindWalk, mana) and not NPC.HasModifier(myHero, "modifier_wind_walk") and Ability.SecondsSinceLastUse(Shuriken)<=1 and Ability.SecondsSinceLastUse(Shuriken)>0 then
				Ability.CastNoTarget(WindWalk) return end
					end
				end
			end
				
			if Ability.IsReady(Track) and Ability.IsReady(WindWalk) and NPC.GetMana(myHero) > Ability.GetManaCost(WindWalk) + Ability.GetManaCost(Track) and NPC.IsEntityInRange(enemy, myHero, TrackRange) and not NPC.HasModifier(enemy, "modifier_bounty_hunter_track") and not NPC.HasModifier(myHero, "modifier_wind_walk") and not NPC.IsLinkensProtected(enemy) then
				Ability.CastTarget(Track, enemy) return end
					
			if Ability.IsReady(WindWalk) and Ability.IsCastable(WindWalk, mana) and not NPC.HasModifier(myHero, "modifier_wind_walk") and not NPC.IsLinkensProtected(enemy) and Ability.SecondsSinceLastUse(Track)<=1 and Ability.SecondsSinceLastUse(Track)>0 then
				Ability.CastNoTarget(WindWalk) return end
			
			if Ability.IsReady(Shuriken) and Ability.IsCastable(Shuriken, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShurikenRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.IsLinkensProtected(enemy) and NPC.HasModifier(enemy, "modifier_teleporting") then 
				Ability.CastTarget(Shuriken, enemy) return 
			end
		end
	end
end

function BountyHunter.Combo()

if not Menu.IsKeyDown(BountyHunter.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_bounty_hunter" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not enemy then return end
	
	if not NPC.IsPositionInRange(enemy, mousePos, 3000) then
		enemy = nil
	end 
		
	--Ability Calls--
	local Shuriken = NPC.GetAbility(myHero, "bounty_hunter_shuriken_toss")
	local WindWalk = NPC.GetAbility(myHero, "bounty_hunter_wind_walk")
	local Jinada = NPC.GetAbility(myHero, "bounty_hunter_jinada")
	local Track = NPC.GetAbility(myHero, "bounty_hunter_track")
	
	--Item Calls--
	local Abyssal = NPC.GetItem(myHero, "item_abyssal_blade", true)
	local Butterfly = NPC.GetItem(myHero, "item_butterfly", true)
	local EBlade = NPC.GetItem(myHero, "item_ethereal_blade", true)
	local Halberd = NPC.GetItem(myHero, "item_heavens_halberd", true)
	local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
	local Medallion = NPC.GetItem(myHero, "item_medallion_of_courage", true)
	local Nullifier = NPC.GetItem(myHero, "item_nullifier", true)
	local Orchid = NPC.GetItem(myHero, "item_orchid", true)
	local Scythe = NPC.GetItem(myHero, "item_sheepstick", true)
	local SolarCrest = NPC.GetItem(myHero, "item_solar_crest", true)
	local Thorn = NPC.GetItem(myHero, "item_bloodthorn", true)
	local Urn = NPC.GetItem(myHero, "item_urn_of_shadows", true)
    local Vessel = NPC.GetItem(myHero, "item_spirit_vessel", true)
    
    local Dagon = NPC.GetItem(myHero, "item_dagon", true)
        if not Dagon then
	        for i = 2, 5 do
		    Dagon = NPC.GetItem(myHero, "item_dagon_" .. i, true)
		    if Dagon then break end
	    end
    end
	
	--Ability Ranges--
    local ShurikenRange = Ability.GetCastRange(Shuriken)
  	local TrackRange = Ability.GetCastRange(Track)
  	
  	--Item Ranges--
  	local AbyssalRange = 140
  	local DagonRange = Ability.GetCastRange(Dagon)
  	local EBladeRange = 800
  	local HalberdRange = 600
  	local MedallionRange = 1000
  	local NullifierRange = 600
  	local OrchidRange = 900
  	local ScytheRange = 800
  	local SolarCrestRange = 1000
  	local ThornRange = 900
  	local UrnRange = 950
    local VesselRange = 950
	  	
  	--Lens Bonus Range--
  	if Lens then
    	ShurikenRange = ShurikenRange + 250
    	TrackRange = TrackRange + 250
    	AbyssalRange = AbyssalRange + 250
    	DagonRange = DagonRange +250
    	EBladeRange = EBladeRange + 250
    	HalberdRange = HalberdRange + 250
    	MedallionRange = MedallionRange + 250
    	NullifierRange = NullifierRange + 250
    	OrchidRange = OrchidRange + 250
    	ScytheRange = ScytheRange + 250
    	SolarCrestRange = SolarCrestRange + 250
    	ThornRange = ThornRange + 250
    	UrnRange = UrnRange + 250
    	VesselRange = VesselRange + 250
    end
	
	if enemy and Menu.IsEnabled(BountyHunter.optionEnable) then
		     
	if Ability.IsReady(WindWalk) and Menu.IsEnabled(BountyHunter.optionEnableWind) and Ability.IsCastable(WindWalk, mana) and not NPC.HasModifier(myHero, "modifier_wind_walk") then
	Ability.CastNoTarget(WindWalk) return 
	end
	
	if not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active")
	and NPC.IsAttacking(myHero) and Track and Menu.IsEnabled(BountyHunter.optionEnableTrack) and Ability.IsCastable(Track, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), TrackRange) and not NPC.HasModifier(enemy, "modifier_bounty_hunter_track") then Ability.CastTarget(Track, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active") and not NPC.IsLinkensProtected(enemy)
	and NPC.IsAttacking(myHero) and Orchid and Menu.IsEnabled(BountyHunter.optionEnableOrchid) and Ability.IsCastable(Orchid, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), OrchidRange) and not NPC.HasModifier(enemy, "modifier_orchid_malevolence_debuff") and not NPC.HasModifier(enemy, "modifier_orchid_malevolence_debuff") then Ability.CastTarget(Orchid, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active") and not NPC.IsLinkensProtected(enemy)
	and NPC.IsAttacking(myHero) and Thorn and Menu.IsEnabled(BountyHunter.optionEnableThorn) and Ability.IsCastable(Thorn, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ThornRange) and not NPC.HasModifier(enemy, "modifier_orchid_malevolence_debuff") and not NPC.HasModifier(enemy, "modifier_bloodthorn_debuff") then Ability.CastTarget(Thorn, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active") and not NPC.IsLinkensProtected(enemy)
	and NPC.IsAttacking(myHero) and Scythe and Menu.IsEnabled(BountyHunter.optionEnableScythe) and Ability.IsCastable(Scythe, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ScytheRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) then Ability.CastTarget(Scythe, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active")
	and NPC.IsAttacking(myHero) and Butterfly and Menu.IsEnabled(BountyHunter.optionEnableButterfly) and Ability.IsReady(Butterfly) and NPC.IsEntityInRange(myHero, enemy, NPC.GetAttackRange(myHero)) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED) and not NPC.IsStunned(enemy) then Ability.CastNoTarget(Butterfly) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active") and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and not NPC.IsLinkensProtected(enemy)
	and NPC.IsAttacking(myHero) and EBlade and Menu.IsEnabled(BountyHunter.optionEnableEBlade) and Ability.IsCastable(EBlade, mana) and not NPC.HasModifier(enemy, "modifier_sheepstick_debuff") then Ability.CastTarget(EBlade, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active") and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and not NPC.IsLinkensProtected(enemy)
	and Dagon and Menu.IsEnabled(BountyHunter.optionEnableDagon) and Menu.IsEnabled(BountyHunter.optionEnableEBlade) and Ability.IsCastable(Dagon, mana) and not NPC.HasModifier(enemy, "modifier_sheepstick_debuff") and NPC.HasModifier(enemy, "modifier_item_ethereal_blade_ethereal") then Ability.CastTarget(Dagon, enemy) Ability.CastTarget(Shuriken, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active") and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and not NPC.IsLinkensProtected(enemy)
	and NPC.IsAttacking(myHero) and Dagon and Menu.IsEnabled(BountyHunter.optionEnableDagon) and not Menu.IsEnabled(BountyHunter.optionEnableEBlade) and Ability.IsCastable(Dagon, mana) then Ability.CastTarget(Dagon, enemy) Ability.CastTarget(Shuriken, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active")
	and NPC.IsAttacking(myHero) and Abyssal and Menu.IsEnabled(BountyHunter.optionEnableAbyssal) and Ability.IsCastable(Abyssal, mana) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) and not NPC.IsStunned(enemy) then Ability.CastTarget(Abyssal, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE)
	and NPC.IsAttacking(myHero) and Urn and Menu.IsEnabled(BountyHunter.optionEnableUrn) and Ability.IsCastable(Urn, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), UrnRange) and Item.GetCurrentCharges(Urn) > 0 and not NPC.HasModifier(enemy, "modifier_item_urn_damage") then Ability.CastTarget(Urn, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE)
	and NPC.IsAttacking(myHero) and Vessel and Menu.IsEnabled(BountyHunter.optionEnableVessel) and Ability.IsCastable(Vessel, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), VesselRange) and Item.GetCurrentCharges(Vessel) > 0 and not NPC.HasModifier(enemy, "modifier_item_spirit_vessel_damage") then Ability.CastTarget(Vessel, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE)
	and NPC.IsAttacking(myHero) and Medallion and Menu.IsEnabled(BountyHunter.optionEnableMedallion) and Ability.IsCastable(Medallion, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), MedallionRange) and not NPC.HasModifier(enemy, "modifier_item_medallion_of_courage_armor_reduction") then Ability.CastTarget(Medallion, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE)
	and NPC.IsAttacking(myHero) and SolarCrest and Menu.IsEnabled(BountyHunter.optionEnableSolarCrest) and Ability.IsCastable(SolarCrest, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), SolarCrestRange) and not NPC.HasModifier(enemy, "modifier_item_solar_crest_armor_reduction") then Ability.CastTarget(SolarCrest, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active")
	and NPC.IsAttacking(myHero) and Halberd and Menu.IsEnabled(BountyHunter.optionEnableHalberd) and Ability.IsCastable(Halberd, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), HalberdRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_DISARMED) then Ability.CastTarget(Halberd, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active")
	and NPC.IsAttacking(myHero) and Shuriken and Menu.IsEnabled(BountyHunter.optionEnableShuriken) and Ability.IsCastable(Shuriken, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShurikenRange) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) and not NPC.IsStunned(enemy) then Ability.CastTarget(Shuriken, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.HasModifier(enemy, "modifier_item_lotus_orb_active")
	and NPC.IsAttacking(myHero) and Nullifier and Menu.IsEnabled(BountyHunter.optionEnableNullifier) and Ability.IsCastable(Nullifier, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), NullifierRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) and not NPC.IsSilenced(enemy) then Ability.CastTarget(Nullifier, enemy) BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
	
	BountyHunter.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
	end
end

return BountyHunter