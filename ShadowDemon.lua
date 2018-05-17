local Utility = require("Utility")

local Shadow = {}

Shadow.poisonKey = Menu.AddKeyOption({"Hero Specific","Shadow Demon"},"3. Poison Harass Key",Enum.ButtonCode.KEY_F)
Shadow.comboKey = Menu.AddKeyOption({"Hero Specific","Shadow Demon"},"2. Combo Key",Enum.ButtonCode.KEY_D)
Shadow.optionEnable = Menu.AddOption({"Hero Specific","Shadow Demon"},"1. Enabled","Enable/Disable Shadow Demon Combo")
Shadow.optionSDBlink = Menu.AddOption({ "Hero Specific", "Shadow Demon" }, "4. Use Blink to Initiate {{Shadow Demon}}", "")
Shadow.optionSDBlinkRange = Menu.AddOption({ "Hero Specific", "Shadow Demon" }, "5. Set Safe Blink Initiation Range {{Shadow Demon}}", "If over 575, then Euls will not activate in combo, if Lens (+250 to your set Blink Range)", 200, 800, 25)
--Skills Toggle Menu--
Shadow.optionEnableDisruption = Menu.AddOption({ "Hero Specific","Shadow Demon","6. Skills"},"1. Use Disruption","Enable Or Disable")
Shadow.optionEnableCatcher = Menu.AddOption({ "Hero Specific","Shadow Demon","6. Skills"},"2. Use Catcher","Enable Or Disable")
Shadow.optionEnablePoison = Menu.AddOption({ "Hero Specific","Shadow Demon","6. Skills"},"3. Use Poison","Enable Or Disable")
Shadow.optionEnableUlt = Menu.AddOption({ "Hero Specific","Shadow Demon","6. Skills"},"4. Use Ult","Enable Or Disable")
--Items Toggle Menu--
Shadow.optionEnableAtos = Menu.AddOption({ "Hero Specific","Shadow Demon","7. Items"},"1. Use Atos","Turn On/Off Rod of Atos in Combo")
Shadow.optionEnableGlimmer = Menu.AddOption({ "Hero Specific","Shadow Demon","7. Items"},"2. Use Glimmer Cape","Turn On/Off Glimmer Cape in Combo")
Shadow.optionEnableEuls = Menu.AddOption({ "Hero Specific","Shadow Demon","7. Items"},"3. Use Euls","Turn On/Off Euls in Combo")

-- global Variables
Shadow.delay = 0
Shadow.lastTick = 0
Shadow.lastAttackTime = 0
Shadow.lastAttackTime2 = 0
Shadow.LastTarget = nil


function Shadow.ResetGlobalVariables()
	Shadow.delay = 0
	Shadow.lastTick = 0
	Shadow.lastAttackTime = 0
	Shadow.lastAttackTime2 = 0
	Shadow.LastTarget = nil
end



function Shadow.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero then return end
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_shadow_demon" then return end

    if not Menu.IsEnabled(Shadow.optionEnable) then return true end
	if Menu.IsKeyDown(Shadow.comboKey) then
        Shadow.Combo()
    end
    

    --auto kill with poison release
    local kaya = NPC.GetItem(myHero, "item_kaya", true)
    local kayaAmp = 0
    if kaya then
      kayaAmp = 10
    end
    local spellAmp = (Hero.GetIntellectTotal(myHero) * 0.06666) + kayaAmp
    local Poison = NPC.GetAbility(myHero, "shadow_demon_shadow_poison")

    if Poison ~= nil then
        for i = 1, NPCs.Count() do
            local npc = NPCs.Get(i)
            if npc and Entity.GetHealth(npc) > 0 and not Entity.IsSameTeam(myHero, npc) and not NPC.IsIllusion(npc) and (NPC.IsHero(npc) or NPC.HasModifier(npc, "modifier_morphling_replicate_timer")) then
                if NPC.HasModifier(npc, "modifier_shadow_demon_shadow_poison") then
                    local poisonMod = NPC.GetModifier(npc, "modifier_shadow_demon_shadow_poison")
                    local stacks = Modifier.GetStackCount(poisonMod)
                    local stacksDamage = Ability.GetLevelSpecialValueFor(Poison, "stack_damage")

                    local stackTalent = NPC.GetAbility(myHero, "special_bonus_unique_shadow_demon_4")
                    local bonusDamage = 50
                    if Ability.GetLevel(stackTalent) > 0 then
                        stacksDamage = stacksDamage + (stacksDamage * .25)
                        bonusDamage = 50 + 50 * .25
                    end

                    local totalStacksDamage = 0
                    local stacksToMultiply = stacks
                    local multDamage = 1
                    if stacks > 5 then
                        stacksToMultiply = 5
                    end
                    stacks = stacks - stacksToMultiply
                    if stacksToMultiply == 5 then multDamage = 16 end
                    if stacksToMultiply == 4 then multDamage = 8 end
                    if stacksToMultiply == 3 then multDamage = 4 end
                    if stacksToMultiply == 2 then multDamage = 2 end
                    if stacksToMultiply == 1 then multDamage = 1 end

                    local multStackDamage = 0
                    if stacksToMultiply then
                        multStackDamage = (stacksDamage * multDamage) * (1 + spellAmp / 100)
                    end

                    local bonusStackDamage = 0
                    if stacks > 0 then
                        bonusStackDamage = (bonusDamage * stacks) * (1 + spellAmp / 100)
                    end

                    totalStacksDamage = multStackDamage + bonusStackDamage
                    local extraDamage = totalStacksDamage
                    local ampPercent = 0
                    if NPC.HasModifier(npc, "modifier_shadow_demon_soul_catcher") then
                        local catcherMod = NPC.GetModifier(npc, "modifier_shadow_demon_soul_catcher")
                        local catcherLevel = Ability.GetLevel(NPC.GetAbility(myHero, "shadow_demon_soul_catcher"))
                        if catcherLevel > 0 then
                            ampPercent = (10 + catcherLevel * 10) -- * (1 + spellAmp / 100) DOTA BUG doesnt amp so sad
                        end
                        extraDamage = totalStacksDamage * (1 + ampPercent / 100)
                    end
                    totalDamage = (1 - NPC.GetMagicalArmorValue(npc)) * (extraDamage)
                    Log.Write("totalStacksDamage: " .. tostring(totalStacksDamage))
                    Log.Write("extraDamage: " .. tostring(extraDamage))
                    Log.Write("ampPercent: " .. tostring(ampPercent))
                    Log.Write("totalDamage: " .. tostring(totalDamage))
                    if totalDamage > Entity.GetHealth(npc) then
                        local release = NPC.GetAbility(myHero, "shadow_demon_shadow_poison_release")
                        Ability.CastNoTarget(release)
                    end
                end
            end
        end
    end
    --end auto kill with poison release
    
    -- poison harass aimbot
    if not Shadow.PoisonStartCastTime then Shadow.PoisonStartCastTime = 0 end
    if not Shadow.PoisonCastPos then Shadow.PoisonCastPos = nil end
    if not Shadow.PoisonCastEnemy then Shadow.PoisonCastEnemy = nil end
    if GameRules.GetGameTime() - Shadow.PoisonStartCastTime < 0.25 and Shadow.PoisonCastPos and Shadow.PoisonCastEnemy then
        if Shadow.PoisonCastEnemy ~= nil and NPC.IsVisible(Shadow.PoisonCastEnemy) then
            local speed = 1000
            local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(Shadow.PoisonCastEnemy)):Length()
            local delay = dis / speed

            -- -- check rotation diff
            -- if NPC.GetTimeToFacePosition(myHero, Shadow.PoisonCastPos) < 0.03 then
            --     local targetAngle = Entity.GetAbsRotation(Shadow.PoisonCastEnemy)
            --     local myAngle = Entity.GetAbsRotation(myHero)
            --     local diff = math.abs(targetAngle:GetYaw() - myAngle:GetYaw())
            --     if NPC.IsRunning(Shadow.PoisonCastEnemy) then
            --     if (dis > 1500 and not (diff < 33 or (diff > 180 - 44 and diff < 180 + 44))) or
            --     (dis > 1000 and dis < 1500 and not (diff < 55 or (diff > 180 - 55 and diff < 180 + 55))) or
            --     (dis > 750 and dis < 1000 and not (diff < 66 or (diff > 180 - 66 and diff < 180 + 66))) or
            --     (dis > 500 and dis < 750 and not (diff < 77 or (diff > 180 - 77 and diff < 180 + 77))) or
            --     (dis > 250 and dis < 500 and not (diff < 85 or (diff > 180 - 85 and diff < 180 + 85))) then
            --         Player.HoldPosition(Players.GetLocal(), myHero, false)
            --         Shadow.PoisonStartCastTime = 0
            --         Shadow.PoisonCastPos = nil
            --         Shadow.PoisonCastEnemy = nil
            --         return
            --     end
            --     end
            -- end


            if (Utility.GetPredictedPosition(Shadow.PoisonCastEnemy, delay)-Shadow.PoisonCastPos):Length2D() > 180 then
                Player.HoldPosition(Players.GetLocal(), myHero, false)
                Shadow.PoisonStartCastTime = 0
                Shadow.PoisonCastPos = nil
                Shadow.PoisonCastEnemy = nil
                return
            end
        end
    end
    -- end poison harass aimbot

	
	if not Menu.IsEnabled(Shadow.optionEnable) then return true end
	if Menu.IsKeyDown(Shadow.poisonKey) then
        Shadow.PoisonHarass()
	end
end

function Shadow.PoisonHarass(myHero)
if not Menu.IsKeyDown(Shadow.poisonKey) then return end
	local myHero = Heroes.GetLocal()
	local mana = NPC.GetMana(myHero)
	local npc = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_shadow_demon" then return end
    local Poison = NPC.GetAbility(myHero, "shadow_demon_shadow_poison")
    if not Poison or not Ability.IsCastable(Poison, NPC.GetMana(myHero)) then return end

    local enemies = NPC.GetHeroesInRadius(myHero, Utility.GetCastRange(myHero, Poison)+200, Enum.TeamType.TEAM_ENEMY)
    if not enemies or #enemies <= 0 or not Ability.IsReady(Poison) then 
        Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, Input.GetWorldCursorPos(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
    end

    for i, npc in ipairs(enemies) do
        if npc and not NPC.IsIllusion(npc) and Ability.IsCastable(Poison, mana) and not Ability.IsInAbilityPhase(Poison) and Ability.IsReady(Poison) then            
            local speed = 1000
            local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(npc)):Length()
            local delay = dis / speed
            local pos = Utility.GetPredictedPosition(npc, delay)
            if NPC.IsPositionInRange(myHero, pos, Ability.GetCastRange(Poison)+200) then
                if not Entity.IsTurning(npc) then
                    Ability.CastPosition(Poison, pos)
                    Shadow.PoisonStartCastTime = GameRules.GetGameTime()
                    Shadow.PoisonCastPos = pos
                    Shadow.PoisonCastEnemy = npc
                    return
                end
            end
        end
    end
end

function Shadow.Combo()
if not Menu.IsKeyDown(Shadow.comboKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_shadow_demon" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local heroPos
    if hero ~= nil then
    heroPos = Entity.GetAbsOrigin(hero)
    end
	local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not hero then return end
	
	--Ability Calls--
    local Disruption = NPC.GetAbility(myHero, "shadow_demon_disruption")
    local Catcher = NPC.GetAbility(myHero, "shadow_demon_soul_catcher")
    local Poison = NPC.GetAbility(myHero, "shadow_demon_shadow_poison")
    local Ult = NPC.GetAbility(myHero, "shadow_demon_demonic_purge")
    
    --Item Calls--
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Atos = NPC.GetItem(myHero, "item_rod_of_atos", true)
    local Veil  = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local Euls = NPC.GetItem(myHero, "item_cyclone", true)
    local Glimmer = NPC.GetItem(myHero, "item_glimmer_cape", true)
	
	--Ability Ranges--
    local DisruptionRange = 600
  	local CatcherRange = 600
  	local PoisonRange = 1500
  	local UltRange = 800
  	
  	--Item Ranges--
  	local BlinkRange = 1200
  	local AtosRange = 1150
  	local EulsRange = 575
  	local VeilRange = 1000
    
    if Lens then
    		DisruptionRange = DisruptionRange + 250
    		CatcherRange = CatcherRange + 250
    		PoisonRange = PoisonRange + 250
    		UltRange = UltRange + 250
    		BlinkRange = BlinkRange + 250
    		AtosRange = AtosRange + 250
    		EulsRange = EulsRange +250
			VeilRange = VeilRange +250   		
    end
    
	if Menu.IsEnabled(Shadow.optionEnable) then
    
    if Shadow.SleepReady(0.05) and hero and not NPC.IsIllusion(hero) and Utility.CanCastSpellOn(hero) then
        if Blink and Menu.IsEnabled(Shadow.optionSDBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, hero, BlinkRange + Menu.GetValue(Shadow.optionSDBlinkRange)) then
            Ability.CastPosition(Blink, (Entity.GetAbsOrigin(hero) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(hero)):Normalized():Scaled(Menu.GetValue(Shadow.optionSDBlinkRange)))) Shadow.lastTick = os.clock() return end
        end
        
        if Shadow.SleepReady(0.05) and Utility.CanCastSpellOn(hero) and Euls and Ability.IsReady(Euls) and Menu.IsEnabled(Shadow.optionEnableEuls) and Ability.IsCastable(Euls, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), EulsRange) and not NPC.HasModifier(hero, "modifier_rod_of_atos_debuff") and not NPC.HasModifier(hero, "modifier_eul_cyclone") then Ability.CastTarget(Euls, hero) Shadow.lastTick = os.clock() return end
        
        if Shadow.SleepReady(0.3) and Disruption and Ability.IsReady(Disruption) and Menu.IsEnabled(Shadow.optionEnableDisruption) and Ability.IsCastable(Disruption, mana) and not NPC.IsIllusion(hero) and Entity.IsAlive(hero) and not NPC.IsStructure(hero) and not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), DisruptionRange) then Ability.CastTarget(Disruption, hero) Shadow.lastTick = os.clock() return end
        
        if Shadow.SleepReady(0.05) and Veil and Ability.IsReady(Veil) and Ability.IsCastable(Veil, mana) and not NPC.IsIllusion(hero) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), VeilRange) and NPC.HasModifier(hero, "modifier_shadow_demon_disruption") and heroPos and Entity.IsAlive(hero) and not NPC.IsStructure(hero) then Ability.CastPosition(Veil, heroPos) Shadow.lastTick = os.clock() return end
        
        if Shadow.SleepReady(0.3) and Catcher and Ability.IsReady(Catcher) and Menu.IsEnabled(Shadow.optionEnableCatcher) and Ability.IsCastable(Catcher, mana) and not NPC.IsIllusion(hero) and not NPC.IsStructure(hero) and not NPC.HasModifier(hero, "modifier_black_king_bar_immune") and NPC.HasModifier(hero, "modifier_shadow_demon_disruption") and heroPos and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), CatcherRange+CatcherRange*0.5,0) then
 		Ability.CastPosition(Catcher, heroPos)
        Shadow.lastTick = os.clock() return 
		end
        
        if Shadow.SleepReady(0.3) and Poison and Ability.IsReady(Poison) and Menu.IsEnabled(Shadow.optionEnablePoison) and Ability.IsCastable(Poison, mana) and not NPC.HasModifier(hero, "modifier_eul_cyclone") and not NPC.IsIllusion(hero) and Entity.IsAlive(hero) and not NPC.IsStructure(hero) and not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and heroPos and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), PoisonRange)
		then Ability.CastPosition(Poison, heroPos) Shadow.lastTick = os.clock() return end

        if Shadow.SleepReady(0.3) and Shadow.CanCastSpellOn(hero) and Ult and Ability.IsReady(Ult) and Menu.IsEnabled(Shadow.optionEnableUlt) and Ability.IsCastable(Ult, mana) and not NPC.HasModifier(hero, "modifier_eul_cyclone") and not NPC.IsIllusion(hero) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), UltRange) then Ability.CastTarget(Ult, hero) Shadow.lastTick = os.clock() return end
        
        if Shadow.SleepReady(0.05) and Utility.CanCastSpellOn(hero) and Atos and Ability.IsReady(Atos) and Menu.IsEnabled(Shadow.optionEnableAtos) and Ability.IsCastable(Atos, mana) and not NPC.IsIllusion(hero) and not NPC.HasModifier(hero, "modifier_sheepstick_debuff") and not NPC.HasModifier(hero, "modifier_eul_cyclone") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), AtosRange)
		and Ability.SecondsSinceLastUse(Disruption) > 1.7 then 
			if not NPC.HasModifier(hero, "modifier_shadow_demon_disruption") then
			Ability.CastTarget(Atos, hero) Shadow.lastTick = os.clock() return end
		end
        
        if Shadow.SleepReady(0.05) and Glimmer and Ability.IsReady(Glimmer) and Menu.IsEnabled(Shadow.optionEnableGlimmer) and Ability.IsCastable(Glimmer, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Glimmer),0) then Ability.CastTarget(Glimmer, myHero) Shadow.lastTick = os.clock() return
		end
		
		Shadow.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", hero, nil) return
    end
end

function Shadow.CanCastSpellOn(npc)
	if Entity.IsDormant(npc) or not Entity.IsAlive(npc) then return false end
	if NPC.IsStructure(npc) or not NPC.IsKillable(npc) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end
	
	return true
end

function Shadow.SleepReady(sleep)

	if (os.clock() - Shadow.lastTick) >= sleep then
		return true
	end
	return false
end

function Shadow.makeDelay(sec)

	Shadow.delay = sec + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING)
	Shadow.lastTick = os.clock()
end

function Shadow.isHeroChannelling(myHero)

	if not myHero then return true end

	if NPC.IsChannellingAbility(myHero) then return true end
	if NPC.HasModifier(myHero, "modifier_teleporting") then return true end

	return false
end

function Shadow.heroCanCastItems(myHero)

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

function Shadow.IsInAbilityPhase(myHero)

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

function Shadow.Debugger(time, npc, ability, order)

	if not Menu.IsEnabled(Shadow.optionEnable) then return end
	Log.Write(tostring(time) .. " " .. tostring(NPC.GetUnitName(npc)) .. " " .. tostring(ability) .. " " .. tostring(order))
end

function Shadow.GenericMainAttack(myHero, attackType, target, position)
	
	if not myHero then return end
	if not target and not position then return end

	if Shadow.isHeroChannelling(myHero) == true then return end
	if Shadow.heroCanCastItems(myHero) == false then return end
	if Shadow.IsInAbilityPhase(myHero) == true then return end

	if Menu.IsEnabled(Shadow.optionEnable) then
		if target ~= nil then
			Shadow.GenericAttackIssuer(attackType, target, position, myHero)
		end
	else
		Shadow.GenericAttackIssuer(attackType, target, position, myHero)
	end
end

function Shadow.GenericAttackIssuer(attackType, target, position, npc)

	if not npc then return end
	if not target and not position then return end
	if os.clock() - Shadow.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= Shadow.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Shadow.LastTarget = target
				Shadow.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= Shadow.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					Shadow.LastTarget = position:__tostring()
					Shadow.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= Shadow.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Shadow.LastTarget = position:__tostring()
				Shadow.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == Shadow.LastTarget then
			if not NPC.IsAttacking(npc) then
				Shadow.LastTarget = nil
				Shadow.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == Shadow.LastTarget then
			if not NPC.IsRunning(npc) then
				Shadow.LastTarget = nil
				Shadow.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

return Shadow
