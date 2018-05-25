local Sandking = {}

Sandking.optionEnable = Menu.AddOption({"Hero Specific","Sandking"},"1. Enabled","Enable Or Disable Sandking Combo Script")
Sandking.optionKey = Menu.AddKeyOption({"Hero Specific","Sandking"},"2. Non-Ult Combo Key",Enum.ButtonCode.KEY_D)
Sandking.optionKey2 = Menu.AddKeyOption({"Hero Specific","Sandking"},"3. Ult Combo Key",Enum.ButtonCode.KEY_F)
Sandking.optionBlink = Menu.AddOption({"Hero Specific", "Sandking"}, "4. Use Blink to Initiate {{Sandking}}", "Use Blink Dagger to initiate")
Sandking.optionBlinkStyle = Menu.AddOption({"Hero Specific", "Sandking"}, "5. Blink Style {{Sandking}}", "Blink to Cursor, or Blink to Best Position", 0, 1, 1)
Sandking.BKBEnable = Menu.AddOption({"Hero Specific", "Sandking"}, "6. Use BKB Before Ultimate", "Enable Or Disable")
Sandking.BKBEnable1 = Menu.AddOption({"Hero Specific", "Sandking"}, "6. Use BKB After Ultimate", "Enable Or Disable")
--Skills Toggle Menu--
Sandking.optionEnableBurrowStrike = Menu.AddOption({ "Hero Specific","Sandking","7. Skills"},"1. Use BurrowStrike","Enable Or Disable")
Sandking.optionEnableSandstorm = Menu.AddOption({ "Hero Specific","Sandking","7. Skills"},"2. Use Sandstorm","Enable Or Disable")
Sandking.optionEnableUlt = Menu.AddOption({ "Hero Specific","Sandking","7. Skills"},"3. Use Epicenter","Enable Or Disable")
--Items Toggle Menu--
Sandking.optionEnableHood = Menu.AddOption({ "Hero Specific","Sandking","8. Items"},"1. Use Hood","Enable Or Disable")
Sandking.optionEnablePipe = Menu.AddOption({ "Hero Specific","Sandking","8. Items"},"2. Use Pipe","Enable Or Disable")
Sandking.optionEnableShivas = Menu.AddOption({ "Hero Specific","Sandking","8. Items"},"3. Use Shivas","Enable Or Disable")
Sandking.optionEnableVeil = Menu.AddOption({ "Hero Specific","Sandking","8. Items"},"4. Use Veil","Enable Or Disable")

Menu.SetValueName(Sandking.optionBlinkStyle, 0, 'Blink to Cursor')
Menu.SetValueName(Sandking.optionBlinkStyle, 1, 'Blink to Best Position')

Sandking.lastAttackTime = 0
Sandking.lastAttackTime2 = 0
Sandking.LastTarget = nil

function Sandking.ResetGlobalVariables()
	Sandking.lastAttackTime = 0
	Sandking.lastAttackTime2 = 0
	Sandking.LastTarget = nil
end

function Sandking.CanCastSpellOn(npc)
	if Entity.IsDormant(npc) or not Entity.IsAlive(npc) then return false end
	if NPC.IsStructure(npc) or not NPC.IsKillable(npc) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end
	
	return true
end

function Sandking.isHeroChannelling(myHero)

	if not myHero then return true end

	if NPC.IsChannellingAbility(myHero) then return true end
	if NPC.HasModifier(myHero, "modifier_teleporting") then return true end
	return false
end

function Sandking.heroCanCastItems(myHero)

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

function Sandking.IsInAbilityPhase(myHero)

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

function Sandking.Debugger(time, npc, ability, order)

	if not Menu.IsEnabled(Sandking.optionEnable) then return end
	Log.Write(tostring(time) .. " " .. tostring(NPC.GetUnitName(npc)) .. " " .. tostring(ability) .. " " .. tostring(order))
end

function Sandking.GenericMainAttack(myHero, attackType, target, position)
	
	if not myHero then return end
	if not target and not position then return end

	if Sandking.isHeroChannelling(myHero) == true then return end
	if Sandking.heroCanCastItems(myHero) == false then return end
	if Sandking.IsInAbilityPhase(myHero) == true then return end

	if Menu.IsEnabled(Sandking.optionEnable) then
		if target ~= nil then
			Sandking.GenericAttackIssuer(attackType, target, position, myHero)
		end
	else
		Sandking.GenericAttackIssuer(attackType, target, position, myHero)
	end
end

function Sandking.GenericAttackIssuer(attackType, target, position, npc)

	if not npc then return end
	if not target and not position then return end
	if os.clock() - Sandking.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= Sandking.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Sandking.LastTarget = target
				Sandking.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= Sandking.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					Sandking.LastTarget = position:__tostring()
					Sandking.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= Sandking.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Sandking.LastTarget = position:__tostring()
				Sandking.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == Sandking.LastTarget then
			if not NPC.IsAttacking(npc) then
				Sandking.LastTarget = nil
				Sandking.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == Sandking.LastTarget then
			if not NPC.IsRunning(npc) then
				Sandking.LastTarget = nil
				Sandking.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

function Sandking.getBestPosition(unitsAround, radius)

	if not unitsAround or #unitsAround < 1 then
		return 
	end

	local countEnemies = #unitsAround

	if countEnemies == 1 then 
		return Entity.GetAbsOrigin(unitsAround[1]) 
	end

	return Sandking.getMidPoint(unitsAround)

--	local maxCount = 1
--	local bestPosition = Entity.GetAbsOrigin(unitsAround[1])
--	for i = 1, (countEnemies - 1) do
--		for j = i + 1, countEnemies do
--			if unitsAround[i] and unitsAround[j] then
--				local pos1 = Entity.GetAbsOrigin(unitsAround[i])
--				local pos2 = Entity.GetAbsOrigin(unitsAround[j])
--				local mid = pos1:__add(pos2):Scaled(0.5)
--
--				local heroesCount = 0
--				for k = 1, countEnemies do
--				--	if NPC.IsPositionInRange(unitsAround[k], mid, radius, 0) then
--					if (Entity.GetAbsOrigin(unitsAround[k]) - mid):Length2D() <= radius then
--						heroesCount = heroesCount + 1
--					end
--				end
--
--				if heroesCount > maxCount then
--					maxCount = heroesCount
--					bestPosition = mid
--				end
--			end
--		end
--	end
--	return bestPosition
end

function Sandking.getMidPoint(entityList)

	if not entityList then return end
	if #entityList < 1 then return end

	local pts = {}
		for i, v in ipairs(entityList) do
			if v and not Entity.IsDormant(v) then
				local pos = Entity.GetAbsOrigin(v)
				local posX = pos:GetX()
				local posY = pos:GetY()
				table.insert(pts, { x=posX, y=posY })
			end
		end
	
	local x, y, c = 0, 0, #pts

		if (pts.numChildren and pts.numChildren > 0) then c = pts.numChildren end

	for i = 1, c do

		x = x + pts[i].x
		y = y + pts[i].y

	end

	return Vector(x/c, y/c, 0)
end

function Sandking.GetMoveSpeed(enemy)

	if not enemy then return end

	local base_speed = NPC.GetBaseSpeed(enemy)
	local bonus_speed = NPC.GetMoveSpeed(enemy) - NPC.GetBaseSpeed(enemy)
	local modifierHex
    	local modSheep = NPC.GetModifier(enemy, "modifier_sheepstick_debuff")
    	local modLionVoodoo = NPC.GetModifier(enemy, "modifier_lion_voodoo")
    	local modShamanVoodoo = NPC.GetModifier(enemy, "modifier_shadow_shaman_voodoo")

	if modSheep then
		modifierHex = modSheep
	end
	if modLionVoodoo then
		modifierHex = modLionVoodoo
	end
	if modShamanVoodoo then
		modifierHex = modShamanVoodoo
	end

	if modifierHex then
		if math.max(Modifier.GetDieTime(modifierHex) - GameRules.GetGameTime(), 0) > 0 then
			return 140 + bonus_speed
		end
	end

    	if NPC.HasModifier(enemy, "modifier_invoker_ice_wall_slow_debuff") then 
		return 100 
	end

	if NPC.HasModifier(enemy, "modifier_invoker_cold_snap_freeze") or NPC.HasModifier(enemy, "modifier_invoker_cold_snap") then
		return (base_speed + bonus_speed) * 0.5
	end

	if NPC.HasModifier(enemy, "modifier_spirit_breaker_charge_of_darkness") then
		local chargeAbility = NPC.GetAbility(enemy, "spirit_breaker_charge_of_darkness")
		if chargeAbility then
			local specialAbility = NPC.GetAbility(enemy, "special_bonus_unique_spirit_breaker_2")
			if specialAbility then
				 if Ability.GetLevel(specialAbility) < 1 then
					return Ability.GetLevel(chargeAbility) * 50 + 550
				else
					return Ability.GetLevel(chargeAbility) * 50 + 1050
				end
			end
		end
	end
			
    	return base_speed + bonus_speed
end

function Sandking.castLinearPrediction(myHero, enemy, adjustmentVariable)

	if not myHero then return end
	if not enemy then return end

	local enemyRotation = Entity.GetRotation(enemy):GetVectors()
		enemyRotation:SetZ(0)
    	local enemyOrigin = NPC.GetAbsOrigin(enemy)
		enemyOrigin:SetZ(0)


	local cosGamma = (NPC.GetAbsOrigin(myHero) - enemyOrigin):Dot2D(enemyRotation:Scaled(100)) / ((NPC.GetAbsOrigin(myHero) - enemyOrigin):Length2D() * enemyRotation:Scaled(100):Length2D())

	if enemyRotation and enemyOrigin then
		if not NPC.IsRunning(enemy) then
			return enemyOrigin
		else return enemyOrigin:__add(enemyRotation:Normalized():Scaled(Sandking.GetMoveSpeed(enemy) * adjustmentVariable * (1 - cosGamma)))
		end
	end
end

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
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local enemyPos = Entity.GetAbsOrigin(enemy)
    local myPos = Entity.GetAbsOrigin(myHero)
	local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not enemy then return end
	
	--Ability Calls--
    local BurrowStrike = NPC.GetAbility(myHero, "sandking_burrowstrike")
    local Sandstorm = NPC.GetAbility(myHero, "sandking_sand_storm")
    
    --Item Calls--
    local Aghs = NPC.GetItem(myHero, "item_ultimate_scepter", true)
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local BKB = NPC.GetItem(myHero, "item_black_king_bar", true)
    local Hood = NPC.GetItem(myHero, "item_hood_of_defiance", true)
    local Pipe = NPC.GetItem(myHero, "item_pipe", true)
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Veil  = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local Shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
    
    --Special Calls--
    local BurrowSpeed = 2000
    
    --Ability Ranges--
    local BurrowRange = Ability.GetCastRange(BurrowStrike)
    
    --Item Ranges--
	local BlinkRange = 1200
    
	--Lens Bonus Range--
	if Lens then
		BlinkRange = BlinkRange + 250
    	BurrowRange = BurrowRange + 250
    end
    
    --Aghs Bonus Range--
    if Aghs then
    	BurrowRange = BurrowRange + BurrowRange
    	BurrowSpeed = BurrowSpeed + 1000
	end
	 
	
	if Menu.IsEnabled(Sandking.optionEnable) then
	
		if BurrowStrike and Menu.IsEnabled(Sandking.optionEnableBurrowStrike) and Ability.IsReady(BurrowStrike) and Ability.IsCastable(BurrowStrike, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, BurrowRange) then
				local pred = Ability.GetCastPoint(BurrowStrike) + (Entity.GetAbsOrigin(enemy):__sub(Entity.GetAbsOrigin(myHero)):Length2D() / BurrowSpeed) + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)
				local predPos = Sandking.castLinearPrediction(myHero, enemy, pred)
				Ability.CastPosition(BurrowStrike, predPos) return
			end
		end
	
		if enemy and not NPC.IsEntityInRange(myHero, enemy, BurrowRange) then
        	if Blink and Menu.IsEnabled(Sandking.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange) then
            	Ability.CastPosition(Blink, mousePos) return
			end
    	end
	
		if Hood and Menu.IsEnabled(Sandking.optionEnableHood) and Ability.IsReady(Hood) and Ability.IsCastable(Hood, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, BurrowRange) then
				Ability.CastNoTarget(Hood) return
			end
		end
	
		if Pipe and Menu.IsEnabled(Sandking.optionEnablePipe) and Ability.IsReady(Pipe) and Ability.IsCastable(Pipe, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, BurrowRange) then
				Ability.CastNoTarget(Pipe) return
			end
		end
	
		if Veil and Menu.IsEnabled(Sandking.optionEnableVeil) and Ability.IsReady(Veil) and Ability.IsCastable(Veil, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, 1000) then
				Ability.CastPosition(Veil, enemyPos) return
			end
		end
	
		if Shivas and Menu.IsEnabled(Sandking.optionEnableShivas) and Ability.IsReady(Shivas) and Ability.IsCastable(Shivas, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, 450) then
				Ability.CastNoTarget(Shivas) return
			end
		end
	
		if Sandstorm and Menu.IsEnabled(Sandking.optionEnableSandstorm) and Ability.IsCastable (Sandstorm, mana) then
			if NPC.HasModifier(enemy, "modifier_sandking_impale") then
				Ability.CastNoTarget (Sandstorm) return
			end
		end
  		if Ability.IsInAbilityPhase(Sandstorm) then return end
  		if Ability.IsChannelling(Sandstorm) then return end
	end
	
	Sandking.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
end
	
function Sandking.Combo2()
if not Menu.IsKeyDown(Sandking.optionKey2) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_sand_king" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local enemyPos = Entity.GetAbsOrigin(enemy)
    local myPos = Entity.GetAbsOrigin(myHero)
	local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not enemy then return end
	
	--Ability Calls--
    local Epicenter = NPC.GetAbility(myHero, "sandking_epicenter")
    local BurrowStrike = NPC.GetAbility(myHero, "sandking_burrowstrike")
    local Sandstorm = NPC.GetAbility(myHero, "sandking_sand_storm")
    
    --Item Calls--
    local Aghs = NPC.GetItem(myHero, "item_ultimate_scepter", true)
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local BKB = NPC.GetItem(myHero, "item_black_king_bar", true)
    local Hood = NPC.GetItem(myHero, "item_hood_of_defiance", true)
    local Pipe = NPC.GetItem(myHero, "item_pipe", true)
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Veil  = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local Shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
    
    --Special Calls--
    local BurrowSpeed = 2000
    
    --Ability Ranges--
    local BurrowRange = Ability.GetCastRange(BurrowStrike)
    local EpicenterRadius = 275
    
    --Item Ranges--
	local BlinkRange = 1200
    
	--Lens Bonus Range--
	if Lens then
		BlinkRange = BlinkRange + 250
    	BurrowRange = BurrowRange + 250
    end
    
	--Lens Bonus Range--
	if Lens then
    	BurrowRange = BurrowRange + 250
    end
    
    --Aghs Bonus Range--
    if Aghs then
    	BurrowRange = BurrowRange + BurrowRange
    	BurrowSpeed = BurrowSpeed + 1000
	end
	
	if Menu.IsEnabled(Sandking.optionEnable) then
	
	if BKB and Menu.IsEnabled(Sandking.BKBEnable) and Ability.IsReady(BKB) and Ability.IsCastable(BKB, mana) then
		if NPC.IsPositionInRange(myHero, enemyPos, BlinkRange) then
			Ability.CastNoTarget(BKB) return
		end
	end
	
	if Epicenter and Menu.IsEnabled(Sandking.optionEnableUlt) and NPC.IsPositionInRange(myHero, enemyPos, BlinkRange) and Ability.IsCastable (Epicenter, mana) then Ability.CastNoTarget (Epicenter) return end
  	if Ability.IsInAbilityPhase(Epicenter) then return end
  	if Ability.IsChannelling(Epicenter) then return end
	
	if enemy and not NPC.IsEntityInRange(myHero, enemy, BurrowRange) then
        if Blink and Menu.IsEnabled(Sandking.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange) then
        	if Menu.GetValue(Sandking.optionBlinkStyle) == 0 then
            	Ability.CastPosition(Blink, mousePos) return 
				else
				local BestPos = Sandking.getBestPosition(Heroes.InRadius(enemyPos, EpicenterRadius * 2, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY), EpicenterRadius)
					if BestPos ~= nil then
					Ability.CastPosition(Blink, BestPos) return 
				end
			end
		end
    end
	
	if Hood and Menu.IsEnabled(Sandking.optionEnableHood) and Ability.IsReady(Hood) and Ability.IsCastable(Hood, mana) then
		if NPC.IsPositionInRange(myHero, enemyPos, BurrowRange) then
			Ability.CastNoTarget(Hood) return
		end
	end
	
	if Pipe and Menu.IsEnabled(Sandking.optionEnablePipe) and Ability.IsReady(Pipe) and Ability.IsCastable(Pipe, mana) then
		if NPC.IsPositionInRange(myHero, enemyPos, BurrowRange) then
			Ability.CastNoTarget(Pipe) return
		end
	end
	
	if BKB and Menu.IsEnabled(Sandking.BKBEnable1) and Ability.IsReady(BKB) and Ability.IsCastable(BKB, mana) then
		if NPC.IsPositionInRange(myHero, enemyPos, BlinkRange) then
			Ability.CastNoTarget(BKB) return
		end
	end
	
	if Veil and Menu.IsEnabled(Sandking.optionEnableVeil) and Ability.IsReady(Veil) and Ability.IsCastable(Veil, mana) then
		if NPC.IsPositionInRange(myHero, enemyPos, 1000) then
			Ability.CastPosition(Veil, enemyPos) return
		end
	end
	
	if Shivas and Menu.IsEnabled(Sandking.optionEnableShivas) and Ability.IsReady(Shivas) and Ability.IsCastable(Shivas, mana) then
		if NPC.IsPositionInRange(myHero, enemyPos, 450) then
			Ability.CastNoTarget(Shivas) return
		end
	end
	
	if BurrowStrike and Menu.IsEnabled(Sandking.optionEnableBurrowStrike) and Ability.IsReady(BurrowStrike) and Ability.IsCastable(BurrowStrike, mana) then
		if NPC.IsPositionInRange(myHero, enemyPos, BurrowRange) then
			local pred = Ability.GetCastPoint(BurrowStrike) + (Entity.GetAbsOrigin(enemy):__sub(Entity.GetAbsOrigin(myHero)):Length2D() / BurrowSpeed) + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)
			local predPos = Sandking.castLinearPrediction(myHero, enemy, pred)
			Ability.CastPosition(BurrowStrike, predPos) return
		end
	end
	
	if Sandstorm and Menu.IsEnabled(Sandking.optionEnableSandstorm) and Ability.IsCastable (Sandstorm, mana) then
		if NPC.HasModifier(enemy, "modifier_sandking_impale") then
			Ability.CastNoTarget (Sandstorm) return
		end
	end
  	if Ability.IsInAbilityPhase(Sandstorm) then return end
  	if Ability.IsChannelling(Sandstorm) then return end
	end
end
	
return Sandking
