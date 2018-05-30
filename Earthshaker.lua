local Earthshaker = {}

Earthshaker.optionEnable = Menu.AddOption({"Hero Specific","Earthshaker"},"1. Enabled","Enable Or Disable Earthshaker Script")
Earthshaker.optionKey = Menu.AddKeyOption({"Hero Specific","Earthshaker"},"2. Non-Ult Combo Key",Enum.ButtonCode.KEY_D)
Earthshaker.optionKey2 = Menu.AddKeyOption({"Hero Specific","Earthshaker"},"3. Ult Combo Key",Enum.ButtonCode.KEY_F)
Earthshaker.optionBlink = Menu.AddOption({"Hero Specific", "Earthshaker"}, "4. Use Blink to Initiate {{Earthshaker}}", "Use Blink Dagger to initiate")
Earthshaker.optionBlinkStyle = Menu.AddOption({"Hero Specific", "Earthshaker"}, "5. Blink Style for Ult {{Earthshaker}}", "Blink to Cursor or Blink to Best Position", 0, 1, 1)
--Skills Toggle Menu--
Earthshaker.optionEnableFissure = Menu.AddOption({ "Hero Specific","Earthshaker","6. Skills"},"1. Use Fissure","Enable Or Disable")
Earthshaker.optionEnableTotem = Menu.AddOption({ "Hero Specific","Earthshaker","6. Skills"},"2. Use Totem","Enable Or Disable")
Earthshaker.optionEnableEcho = Menu.AddOption({ "Hero Specific","Earthshaker","6. Skills"},"3. Use Echo Slam","Enable Or Disable")
--Items Toggle Menu--
Earthshaker.optionEnableDiscord = Menu.AddOption({ "Hero Specific","Earthshaker","7. Items"},"1. Use Discord","Enable Or Disable")
Earthshaker.optionEnableShadow = Menu.AddOption({ "Hero Specific","Earthshaker","7. Items"},"2. Use Shadow Blade","Enable Or Disable")
Earthshaker.optionEnableSilverEdge = Menu.AddOption({ "Hero Specific","Earthshaker","7. Items"},"3. Use Silver Edge","Enable Or Disable")
Earthshaker.optionEnableShivas = Menu.AddOption({ "Hero Specific","Earthshaker","7. Items"},"4. Use Shivas","Enable Or Disable")
Earthshaker.optionEnableRefresher = Menu.AddOption({ "Hero Specific","Earthshaker","7. Items"},"5. Use Refresher Orb","Enable Or Disable")

Menu.SetValueName(Earthshaker.optionBlinkStyle, 0, 'Blink to Cursor')
Menu.SetValueName(Earthshaker.optionBlinkStyle, 1, 'Blink to Best Position')

Earthshaker.lastAttackTime = 0
Earthshaker.lastAttackTime2 = 0
Earthshaker.LastTarget = nil

function Earthshaker.ResetGlobalVariables()
	Earthshaker.lastAttackTime = 0
	Earthshaker.lastAttackTime2 = 0
	Earthshaker.LastTarget = nil
end

function Earthshaker.CanCastSpellOn(npc)
	if Entity.IsDormant(npc) or not Entity.IsAlive(npc) then return false end
	if NPC.IsStructure(npc) or not NPC.IsKillable(npc) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end
	
	return true
end

function Earthshaker.isHeroChannelling(myHero)

	if not myHero then return true end

	if NPC.IsChannellingAbility(myHero) then return true end
	if NPC.HasModifier(myHero, "modifier_teleporting") then return true end
	return false
end

function Earthshaker.heroCanCastItems(myHero)

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

function Earthshaker.IsInAbilityPhase(myHero)

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

function Earthshaker.Debugger(time, npc, ability, order)

	if not Menu.IsEnabled(Earthshaker.optionEnable) then return end
	Log.Write(tostring(time) .. " " .. tostring(NPC.GetUnitName(npc)) .. " " .. tostring(ability) .. " " .. tostring(order))
end

function Earthshaker.GenericMainAttack(myHero, attackType, target, position)
	
	if not myHero then return end
	if not target and not position then return end

	if Earthshaker.isHeroChannelling(myHero) == true then return end
	if Earthshaker.heroCanCastItems(myHero) == false then return end
	if Earthshaker.IsInAbilityPhase(myHero) == true then return end

	if Menu.IsEnabled(Earthshaker.optionEnable) then
		if target ~= nil then
			Earthshaker.GenericAttackIssuer(attackType, target, position, myHero)
		end
	else
		Earthshaker.GenericAttackIssuer(attackType, target, position, myHero)
	end
end

function Earthshaker.GenericAttackIssuer(attackType, target, position, npc)

	if not npc then return end
	if not target and not position then return end
	if os.clock() - Earthshaker.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= Earthshaker.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Earthshaker.LastTarget = target
				Earthshaker.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= Earthshaker.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					Earthshaker.LastTarget = position:__tostring()
					Earthshaker.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= Earthshaker.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Earthshaker.LastTarget = position:__tostring()
				Earthshaker.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == Earthshaker.LastTarget then
			if not NPC.IsAttacking(npc) then
				Earthshaker.LastTarget = nil
				Earthshaker.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == Earthshaker.LastTarget then
			if not NPC.IsRunning(npc) then
				Earthshaker.LastTarget = nil
				Earthshaker.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

function Earthshaker.getBestPosition(unitsAround, radius)

	if not unitsAround or #unitsAround < 1 then
		return 
	end

	local countEnemies = #unitsAround

	if countEnemies == 1 then 
		return Entity.GetAbsOrigin(unitsAround[1]) 
	end

	return Earthshaker.getMidPoint(unitsAround)

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

function Earthshaker.getMidPoint(entityList)

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

function Earthshaker.GetMoveSpeed(enemy)

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

function Earthshaker.castLinearPrediction(myHero, enemy, adjustmentVariable)

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
		else return enemyOrigin:__add(enemyRotation:Normalized():Scaled(Earthshaker.GetMoveSpeed(enemy) * adjustmentVariable * (1 - cosGamma)))
		end
	end
end

function Earthshaker.OnUpdate()
    if not Menu.IsEnabled(Earthshaker.optionEnable) then return true end
	if Menu.IsKeyDown(Earthshaker.optionKey)then
    Earthshaker.Combo()
    end
    
    if not Menu.IsEnabled(Earthshaker.optionEnable) then return true end
	if Menu.IsKeyDown(Earthshaker.optionKey2)then
    Earthshaker.Combo2()
	end
end

function Earthshaker.Combo()
if not Menu.IsKeyDown(Earthshaker.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_earthshaker" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if not enemy then return end
    local enemyPos = Entity.GetAbsOrigin(enemy)
    local myPos = Entity.GetAbsOrigin(myHero)
	local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	--Ability Calls--
	local Fissure = NPC.GetAbility(myHero, "earthshaker_fissure")
    local Totem = NPC.GetAbility(myHero, "earthshaker_enchant_totem")
    
    --Item Calls--
    local Blink = NPC.GetItem(myHero, "item_blink", true)
    local Discord = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local Shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
	local Shadow = NPC.GetItem(myHero, "item_invis_sword", true)
	local SilverEdge = NPC.GetItem(myHero, "item_silver_edge", true)
    
    --Ability Ranges--
    local FissureRange = 1400
    local TotemRange = 300
    
    --Item Ranges--
	local BlinkRange = 1200
	local DiscordRange = 1000
	local ShivasRadius = 900
    
    --Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_unique_earthshaker_3")
  	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
    	FissureRange = FissureRange + 400
  	end	
	
	if not NPC.IsEntityInRange(myHero, enemy, 3000) then return end
	if Menu.IsKeyDown(Earthshaker.optionKey) then
	
		if enemy and not NPC.IsEntityInRange(myHero, enemy, TotemRange) then
        	if Blink and Menu.IsEnabled(Earthshaker.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange) then
            	Ability.CastPosition(Blink, mousePos) return
			end
    	end
	
		if Totem and Menu.IsEnabled(Earthshaker.optionEnableTotem) and Ability.IsReady(Totem) and Ability.IsCastable(Totem, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, TotemRange) then
				Ability.CastNoTarget(Totem) return
			end
		end
	
		if Discord and Menu.IsEnabled(Earthshaker.optionEnableDiscord) and Ability.IsReady(Discord) and Ability.IsCastable(Discord, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, 500) then
				Ability.CastPosition(Discord, enemyPos) return
			end
		end
	
		if Shadow and Menu.IsEnabled(Earthshaker.optionEnableShadow) and Ability.IsReady(Shadow) and Ability.IsCastable(Shadow, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, TotemRange) then
				Ability.CastNoTarget(Shadow) return
			end
		end
	
		if SilverEdge and Menu.IsEnabled(Earthshaker.optionEnableSilverEdge) and Ability.IsReady(SilverEdge) and Ability.IsCastable(SilverEdge, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, TotemRange) then
				Ability.CastNoTarget(SilverEdge) return
			end
		end
		
		if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), NPC.GetAttackRange(myHero)) then
			if NPC.HasItem(myHero, "item_invis_sword", true) or NPC.HasItem(myHero, "item_silver_edge", true) then
				if Shadow and Ability.IsReady(Shadow) or SilverEdge and Ability.IsReady(SilverEdge) then
					if NPC.HasModifier(myHero, "modifier_item_invisibility_edge_windwalk") or NPC.HasModifier(myHero, "modifier_item_silver_edge_windwalk") then
						Earthshaker.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
					end
				end
			end
		end
	
		if Shivas and Menu.IsEnabled(Earthshaker.optionEnableShivas) and Ability.IsReady(Shivas) and Ability.IsCastable(Shivas, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, 450) then
				Ability.CastNoTarget(Shivas) return
			end
		end
		
		if Fissure and Menu.IsEnabled(Earthshaker.optionEnableFissure) and Ability.IsReady(Fissure) and Ability.IsCastable(Fissure, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, FissureRange, 0) then
				if NPC.IsAttacking(myHero) and not NPC.HasModifier(myHero, "modifier_item_invisibility_edge_windwalk") and not NPC.HasModifier(myHero, "modifier_item_silver_edge_windwalk") then
					Ability.CastPosition(Fissure, enemyPos) return
				end
			end
		end	
		Earthshaker.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
	end
end
	
function Earthshaker.Combo2()
if not Menu.IsKeyDown(Earthshaker.optionKey2) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_earthshaker" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if not enemy then return end
    local enemyPos = Entity.GetAbsOrigin(enemy)
    local myPos = Entity.GetAbsOrigin(myHero)
	local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	--Ability Calls--
    local Totem = NPC.GetAbility(myHero, "earthshaker_enchant_totem")
    local Echo = NPC.GetAbility(myHero, "earthshaker_echo_slam")
    
    --Item Calls--
    local Blink = NPC.GetItem(myHero, "item_blink", true)
    local Discord = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local Shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
	local Shadow = NPC.GetItem(myHero, "item_invis_sword", true)
	local SilverEdge = NPC.GetItem(myHero, "item_silver_edge", true)
	local Refresher = NPC.GetItem(myHero, "item_refresher", true)
    
    --Ability Ranges--
    local TotemRange = 300
    local EchoRadius = 600
    
    --Item Ranges--
	local BlinkRange = 1200
    local DiscordRange = 1000
	local ShivasRadius = 900
	
	if not NPC.IsEntityInRange(myHero, enemy, 3000) then return end
	if Menu.IsKeyDown(Earthshaker.optionKey2) then
	
		if enemy and not NPC.IsEntityInRange(myHero, enemy, BlinkRange - EchoRadius) then
        	if Blink and Menu.IsEnabled(Earthshaker.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange) then
        		if Menu.GetValue(Earthshaker.optionBlinkStyle) == 0 then
            		Ability.CastPosition(Blink, mousePos) return 
					else
					local BestPos = Earthshaker.getBestPosition(Heroes.InRadius(enemyPos, EchoRadius * 2, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY), EchoRadius)
						if BestPos ~= nil then
						Ability.CastPosition(Blink, BestPos) return 
					end
				end
			end
   		end
	
		if Echo and Menu.IsEnabled(Earthshaker.optionEnableEcho) and Ability.IsReady(Echo) and Ability.IsCastable(Echo, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, EchoRadius, 0) then
				Ability.CastNoTarget(Echo) return
			end
		end
	
		if Discord and Menu.IsEnabled(Earthshaker.optionEnableDiscord) and Ability.IsReady(Discord) and Ability.IsCastable(Discord, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, 500) then
				Ability.CastPosition(Discord, enemyPos) return
			end
		end
	
		if Totem and Menu.IsEnabled(Earthshaker.optionEnableTotem) and Ability.IsReady(Totem) and Ability.IsCastable(Totem, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, TotemRange, 0) then
				if Ability.SecondsSinceLastUse(Echo) > -1 and Ability.SecondsSinceLastUse(Echo) <= 0.4 then
					Ability.CastNoTarget(Totem) return
				end
			end
		end
	
		if Shadow and Menu.IsEnabled(Earthshaker.optionEnableShadow) and Ability.IsReady(Shadow) and Ability.IsCastable(Shadow, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, TotemRange) then
				Ability.CastNoTarget(Shadow) return
			end
		end
	
		if SilverEdge and Menu.IsEnabled(Earthshaker.optionEnableSilverEdge) and Ability.IsReady(SilverEdge) and Ability.IsCastable(SilverEdge, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, TotemRange) then
				Ability.CastNoTarget(SilverEdge) return
			end
		end
		
		if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), NPC.GetAttackRange(myHero)) then
			if NPC.HasItem(myHero, "item_invis_sword", true) or NPC.HasItem(myHero, "item_silver_edge", true) then
				if Shadow and Ability.IsReady(Shadow) or SilverEdge and Ability.IsReady(SilverEdge) then
					if NPC.HasModifier(myHero, "modifier_item_invisibility_edge_windwalk") or NPC.HasModifier(myHero, "modifier_item_silver_edge_windwalk") then
						Earthshaker.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
					end
				end
			end
		end
	
		if Shivas and Menu.IsEnabled(Earthshaker.optionEnableShivas) and Ability.IsReady(Shivas) and Ability.IsCastable(Shivas, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, 450, 0) then
				Ability.CastNoTarget(Shivas) return
			end
		end
	
		if Refresher and Menu.IsEnabled(Earthshaker.optionEnableRefresher) and Ability.IsReady(Refresher) and Ability.IsCastable(Refresher, mana) then
			if NPC.IsPositionInRange(myHero, enemyPos, EchoRadius, 0) then
				if Ability.SecondsSinceLastUse(Echo) > 0 then
		    		Ability.CastNoTarget(Refresher) return
		    	end
			end
		end
		
	    if not NPC.IsEntityInRange(myHero, enemy, BlinkRange - EchoRadius) then 
		    Earthshaker.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION", enemy, mousePos) return
	    end
	end
end
	
return Earthshaker
