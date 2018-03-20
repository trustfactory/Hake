local Utility = require("Utility")

local Shadow = {}

Shadow.poisonKey = Menu.AddKeyOption({"Hero Specific","Shadow Demon"},"3. Poison Harass Key",Enum.ButtonCode.KEY_F)
Shadow.comboKey = Menu.AddKeyOption({"Hero Specific","Shadow Demon"},"2. Combo Key",Enum.ButtonCode.KEY_D)
Shadow.optionEnable = Menu.AddOption({"Hero Specific","Shadow Demon"},"1. Enabled","Enable/Disable Shadow Demon Combo")
Shadow.optionSDBlink = Menu.AddOption({ "Hero Specific", "Shadow Demon" }, "4. Use Blink to Initiate {{Shadow Demon}}", "")
Shadow.optionSDBlinkRange = Menu.AddOption({ "Hero Specific", "Shadow Demon" }, "5. Set Safe Blink Initiation Range {{Shadow Demon}}", "If over 575, then Euls will not activate in combo", 200, 800, 25)
Shadow.EulsEnable = Menu.AddOption({"Hero Specific", "Shadow Demon"}, "6. Turn On/Off Euls in Combo", "")
Shadow.UltEnable = Menu.AddOption({"Hero Specific", "Shadow Demon"}, "7. Turn On/Off Ult in Combo", "")

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
                        multStackDamage = (1 - NPC.GetMagicalArmorValue(npc)) * ((stacksDamage * multDamage) * (1 + spellAmp / 100))
                    end

                    local bonusStackDamage = 0
                    if stacks > 0 then
                        bonusStackDamage = (1 - NPC.GetMagicalArmorValue(npc)) * ((bonusDamage * stacks) * (1 + spellAmp / 100))
                    end

                    totalStacksDamage = multStackDamage + bonusStackDamage
                    Log.Write("multDamage: " .. tostring(multDamage))
                    Log.Write("multStackDamage: " .. tostring(multStackDamage))
                    Log.Write("bonusStackDamage: " .. tostring(bonusStackDamage))
                    Log.Write("totalstacksDamage: " .. tostring(totalStacksDamage))
                    if totalStacksDamage > Entity.GetHealth(npc) then
                        Log.Write("tried to kill")
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
        if NPC.IsVisible(Shadow.PoisonCastEnemy) then
            local speed = 1000
            local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(Shadow.PoisonCastEnemy)):Length()
            local delay = dis / speed

            -- check rotation diff
            if NPC.GetTimeToFacePosition(myHero, Shadow.PoisonCastPos) < 0.03 then
                local targetAngle = Entity.GetAbsRotation(Shadow.PoisonCastEnemy)
                local myAngle = Entity.GetAbsRotation(myHero)
                local diff = math.abs(targetAngle:GetYaw() - myAngle:GetYaw())
                if NPC.IsRunning(Shadow.PoisonCastEnemy) then
                if (dis > 1500 and not (diff < 33 or (diff > 180 - 33 and diff < 180 + 33))) or
                (dis > 1000 and dis < 1500 and not (diff < 44 or (diff > 180 - 44 and diff < 180 + 44))) or
                (dis > 750 and dis < 1000 and not (diff < 66 or (diff > 180 - 66 and diff < 180 + 66))) or
                (dis > 500 and dis < 750 and not (diff < 77 or (diff > 180 - 77 and diff < 180 + 77))) or
                (dis > 250 and dis < 500 and not (diff < 85 or (diff > 180 - 85 and diff < 180 + 85))) then
                    Player.HoldPosition(Players.GetLocal(), myHero, false)
                    Shadow.PoisonStartCastTime = 0
                    Shadow.PoisonCastPos = nil
                    Shadow.PoisonCastEnemy = nil
                    return
                end
                end
            end


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
	
    local Disruption = NPC.GetAbility(myHero, "shadow_demon_disruption")
    local Catcher = NPC.GetAbility(myHero, "shadow_demon_soul_catcher")
    local Poison = NPC.GetAbility(myHero, "shadow_demon_shadow_poison")
    local Ult = NPC.GetAbility(myHero, "shadow_demon_demonic_purge")
    
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Atos = NPC.GetItem(myHero, "item_rod_of_atos", true)
    local Veil  = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local Euls = NPC.GetItem(myHero, "item_cyclone", true)
	
	if Menu.IsEnabled(Shadow.optionEnable) then
    
    if hero and not NPC.IsIllusion(hero) and Utility.CanCastSpellOn(hero) then
        if Blink and Menu.IsEnabled(Shadow.optionSDBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, hero, 1150 + Menu.GetValue(Shadow.optionSDBlinkRange)) then
            Ability.CastPosition(Blink, (Entity.GetAbsOrigin(hero) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(hero)):Normalized():Scaled(Menu.GetValue(Shadow.optionSDBlinkRange)))) return end
        end
        
        if Atos and Ability.IsCastable(Atos, mana) and not NPC.IsIllusion(hero) and not NPC.GetModifier(hero, "modifier_sheepstick_debuff") and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),Ability.GetCastRange(Atos),0) then Ability.CastTarget(Atos, hero) return end
        
        if Veil and Ability.IsCastable(Veil, mana) and not NPC.IsIllusion(hero) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Veil),0) and heroPos then Ability.CastPosition(Veil, heroPos) return end
        
        if Disruption and Ability.IsCastable(Disruption, mana) and not NPC.IsIllusion(hero) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Disruption),0) then Ability.CastTarget(Disruption, hero) return end
        
        if Catcher and Ability.IsCastable(Catcher, mana) and not NPC.IsIllusion(hero) and heroPos and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Catcher),0) then Ability.CastPosition(Catcher, heroPos) return end
        
        if Poison and Ability.IsCastable(Poison, mana) and not NPC.IsIllusion(hero) and heroPos and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Poison),0) then Ability.CastPosition(Poison, heroPos) return end
        
        if Euls and Menu.IsEnabled(Shadow.EulsEnable) and Ability.IsCastable(Euls, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Euls),0) then Ability.CastTarget(Euls, hero) return end

        if Ult and Menu.IsEnabled(Shadow.UltEnable) and Ability.IsCastable(Ult, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero), Ability.GetCastRange(Ult),0) then Ability.CastTarget(Ult, hero) return end
    end
end
	
return Shadow
