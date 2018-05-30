local Utility = require("Utility")
local Batrider = {}  

Batrider.optionEnable = Menu.AddOption({"Hero Specific","Batrider"},"1. Enabled","Basic Combo is (Basic attacks + Q + Items + will cast E if target is in E Range), or Ult Combo")
Batrider.optionAutoNapalm = Menu.AddOption({"Hero Specific", "Batrider"},"2. Auto Napalm", "Auto cast Napalm on enemy nearest cursor in range")
Batrider.optionToggleKey = Menu.AddKeyOption({"Hero Specific","Batrider"},"3. Napalm Toggle Key", Enum.ButtonCode.KEY_S)
Batrider.optionKey = Menu.AddKeyOption({"Hero Specific","Batrider"},"4. Basic Combo Key",Enum.ButtonCode.KEY_D)
Batrider.optionKey2 = Menu.AddKeyOption({"Hero Specific","Batrider"},"5. Ult Combo Key",Enum.ButtonCode.KEY_F)
Batrider.optionBlink = Menu.AddOption({"Hero Specific", "Batrider"}, "6. Use Blink to Initiate {{Batrider}}", "Blink to Nearest Enemy to Cursor")
--Skills Toggle Menu--
Batrider.optionEnableNapalm = Menu.AddOption({"Hero Specific","Batrider","7. Skills"},"1. Use Sticky Napalm","Enable Or Disable")
Batrider.optionEnableFirefly = Menu.AddOption({"Hero Specific","Batrider","7. Skills"},"2. Use Firefly","Enable Or Disable")
Batrider.optionEnableUlt = Menu.AddOption({"Hero Specific","Batrider","7. Skills"},"3. Use Flaming Lasso","Enable Or Disable")
--Items Toggle Menu--
Batrider.optionEnableAtos = Menu.AddOption({"Hero Specific","Batrider","8. Items"},"1. Use Atos","Turn On/Off Rod of Atos in Combo for secondary Linkens Breaker if no Euls")
Batrider.optionEnableEuls = Menu.AddOption({"Hero Specific","Batrider","8. Items"},"2. Use Euls for Linkens Breaker","Turn On/Off Euls, only coded to cast if target has Linkens, acts as a pure Linkens Breaker")
--Local calls--
local AutoNapalmMode = false
local Font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
---------------
Batrider.lastAttackTime = 0
Batrider.lastAttackTime2 = 0
Batrider.LastTarget = nil

function Batrider.ResetGlobalVariables()
    Batrider.lastAttackTime = 0
	Batrider.lastAttackTime2 = 0
	Batrider.LastTarget = nil
end

function Batrider.isHeroChannelling(myHero)

	if not myHero then return true end

	if NPC.IsChannellingAbility(myHero) then return true end
	if NPC.HasModifier(myHero, "modifier_teleporting") then return true end

	return false
end

function Batrider.heroCanCastItems(myHero)

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

function Batrider.IsInAbilityPhase(myHero)

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

function Batrider.Debugger(time, npc, ability, order)

	if not Menu.IsEnabled(Batrider.optionEnable) then return end
	Log.Write(tostring(time) .. " " .. tostring(NPC.GetUnitName(npc)) .. " " .. tostring(ability) .. " " .. tostring(order))
end

function Batrider.GenericMainAttack(myHero, attackType, target, position)
	
	if not myHero then return end
	if not target and not position then return end

	if Batrider.isHeroChannelling(myHero) == true then return end
	if Batrider.heroCanCastItems(myHero) == false then return end
	if Batrider.IsInAbilityPhase(myHero) == true then return end

	if Menu.IsEnabled(Batrider.optionEnable) then
		if target ~= nil then
			Batrider.GenericAttackIssuer(attackType, target, position, myHero)
		end
	else
		Batrider.GenericAttackIssuer(attackType, target, position, myHero)
	end
end

function Batrider.GenericAttackIssuer(attackType, target, position, npc)

	if not npc then return end
	if not target and not position then return end
	if os.clock() - Batrider.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= Batrider.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Batrider.LastTarget = target
				Batrider.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= Batrider.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					Batrider.LastTarget = position:__tostring()
					Batrider.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= Batrider.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Batrider.LastTarget = position:__tostring()
				Batrider.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == Batrider.LastTarget then
			if not NPC.IsAttacking(npc) then
				Batrider.LastTarget = nil
				Batrider.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == Batrider.LastTarget then
			if not NPC.IsRunning(npc) then
				Batrider.LastTarget = nil
				Batrider.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

function Batrider.getBestPosition(unitsAround, radius)

	if not unitsAround or #unitsAround < 1 then
		return 
	end

	local countEnemies = #unitsAround

	if countEnemies == 1 then 
		return Entity.GetAbsOrigin(unitsAround[1]) 
	end

	return Batrider.getMidPoint(unitsAround)

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

function Batrider.getMidPoint(entityList)

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

function Batrider.AmIFacingPos(myHero, pos, allowedDeviation)

	if not myHero then return false end

	local myPos = Entity.GetAbsOrigin(myHero)
	local myRotation = Entity.GetRotation(myHero):GetForward():Normalized()

	local baseVec = (pos - myPos):Normalized()

	local tempProcessing = baseVec:Dot2D(myRotation) / (baseVec:Length2D() * myRotation:Length2D())
		if tempProcessing > 1 then
			tempProcessing = 1
		end	

	local checkAngleRad = math.acos(tempProcessing)
	local checkAngle = (180 / math.pi) * checkAngleRad

	if checkAngle < allowedDeviation then
		return true
	end

	return false

end

function Batrider.IsSuitableToCastSpell(myHero)
    if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return false end
    if NPC.IsChannellingAbility(myHero) then return false end

    return true
end

function Batrider.OnUpdate()
    if not Menu.IsEnabled(Batrider.optionEnable) then return true end
	if Menu.IsKeyDown(Batrider.optionKey)then
    Batrider.Combo()
	end
	
	if Menu.IsKeyDown(Batrider.optionKey2)then
    Batrider.UltCombo()
	end
	
	if not Engine.IsInGame() then
	Batrider.ResetGlobalVariables()
	end
	
	if Menu.IsKeyDownOnce(Batrider.optionToggleKey) then
        AutoNapalmMode = not AutoNapalmMode
    end
    
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_batrider" then return end
    
    if Menu.IsEnabled(Batrider.optionAutoNapalm) and AutoNapalmMode then
        Batrider.AutoNapalm()
    end
end

function Batrider.Combo()
   
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_batrider" then return end 
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local mana = NPC.GetMana(myHero)  
    if not enemy then return end
	local enemyPos = Entity.GetAbsOrigin(enemy)
	local mousePos = Input.GetWorldCursorPos()
	local myPos = Entity.GetAbsOrigin(myHero)
	
--Ability Calls--	
	local Firefly = NPC.GetAbility(myHero, "batrider_firefly")
	local Napalm = NPC.GetAbility(myHero, "batrider_sticky_napalm")
	
--Ability Ranges--
  	local NapalmRange = 700
  	local FireflyRadius = 200
		
--Item Calls--
	local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
	local Atos = NPC.GetItem(myHero, "item_rod_of_atos", true)
	local Euls  = NPC.GetItem(myHero, "item_cyclone", true)
	
--Item Ranges--
	local AtosRange = 1150
	local EulsRange = 575
	
--Lens Bonus Range-- 	
   
    if Lens then
    	NapalmRange = NapalmRange + 250
    	AtosRange = AtosRange + 250
    	EulsRange = EulsRange +250
    end
  	
  	if Menu.IsEnabled(Batrider.optionEnable) then
		
		if not Entity.IsDormant(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and NPC.IsLinkensProtected(enemy) then
			if Euls and Ability.IsReady(Euls) and Menu.IsEnabled(Batrider.optionEnableEuls) then
				if Ability.IsCastable(Euls, mana) and NPC.IsPositionInRange(myHero, enemyPos, EulsRange) then 
					Ability.CastTarget(Euls, enemy) return
				end
			end
		end
		
		if not Entity.IsDormant(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
			if Atos and Ability.IsReady(Atos) and Menu.IsEnabled(Batrider.optionEnableAtos) then
				if Ability.IsCastable(Atos, mana) and NPC.IsPositionInRange(myHero, enemyPos, AtosRange) then 
					Ability.CastTarget(Atos, enemy) return
				end
			end
		end

		
		if not Entity.IsDormant(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
			if Napalm and Ability.IsReady(Napalm) and Menu.IsEnabled(Batrider.optionEnableNapalm) then
				if Ability.IsCastable(Napalm, mana) and NPC.IsPositionInRange(myHero, enemyPos, NapalmRange) then 
					Ability.CastPosition(Napalm, enemyPos) return
				end
			end
		end
		
		if Batrider.IsSuitableToCastSpell(myHero) then
			if Firefly and Ability.IsReady(Firefly) and Menu.IsEnabled(Batrider.optionEnableFirefly) then
				if Ability.IsCastable(Firefly, mana) and NPC.IsPositionInRange(myHero, enemyPos, FireflyRadius) then 
					Ability.CastNoTarget(Firefly) return
				end
			end
		end
		
		Batrider.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil)
		return
	end
end

function Batrider.UltCombo()
   
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_batrider" then return end 
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local mana = NPC.GetMana(myHero)  
    if not enemy then return end
	local enemyPos = Entity.GetAbsOrigin(enemy)
	local mousePos = Input.GetWorldCursorPos()
	local myPos = Entity.GetAbsOrigin(myHero)
	
--Ability Calls--	
	local Firefly = NPC.GetAbility(myHero, "batrider_firefly")
	local Napalm = NPC.GetAbility(myHero, "batrider_sticky_napalm")
	local Ult = NPC.GetAbility(myHero, "batrider_flaming_lasso")
	
--Item Calls--
	local Atos = NPC.GetItem(myHero, "item_rod_of_atos", true)
    local Blink = NPC.GetItem(myHero, "item_blink", true)
    local Euls  = NPC.GetItem(myHero, "item_cyclone", true)
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
	
--Ability Ranges--
  	local NapalmRange = 700
  	local FireflyRadius = 200
  	local UltRange = 100
  	
--Item Ranges--
	local AtosRange = 1150
	local BlinkRange = 1200
	local EulsRange = 575
		
--Lens Bonus Range-- 	
   
    if Lens then
    	NapalmRange = NapalmRange + 250
    	UltRange = UltRange + 250
    	AtosRange = AtosRange + 250
    	BlinkRange = BlinkRange + 250
    	EulsRange = EulsRange +250
    end
  	
  	if Menu.IsEnabled(Batrider.optionEnable) then
		
		if not Entity.IsDormant(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
			if Atos and Ability.IsReady(Atos) and Menu.IsEnabled(Batrider.optionEnableAtos) then
				if Ability.IsCastable(Atos, mana) and NPC.IsPositionInRange(myHero, enemyPos, AtosRange) then 
					Ability.CastTarget(Atos, enemy) return
				end
			end
		end
		
		if not Entity.IsDormant(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and NPC.IsLinkensProtected(enemy) then
			if Euls and Ability.IsReady(Euls) and Menu.IsEnabled(Batrider.optionEnableEuls) then
				if Ability.IsCastable(Euls, mana) and NPC.IsPositionInRange(myHero, enemyPos, EulsRange) then 
					Ability.CastTarget(Euls, enemy) return
				end
			end
		end
		
		if enemy and Batrider.IsSuitableToCastSpell(myHero) and not Entity.IsDormant(enemy) and not NPC.IsLinkensProtected(enemy) then
			if not NPC.IsEntityInRange(myHero, enemy, 600) then
    			if Blink and Menu.IsEnabled(Batrider.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange - UltRange) then
					local distance = (enemyPos - myPos):Length2D()
					if distance > BlinkRange then
						distance = BlinkRange
					end
					Ability.CastPosition(Blink, myPos + (enemyPos - myPos):Normalized():Scaled(distance + 55))
					return
				end
    		end
    	end
	
		if not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.IsLinkensProtected(enemy) then
			if Ult and Ability.IsReady(Ult) and Menu.IsEnabled(Batrider.optionEnableUlt) then
				if Ability.IsCastable(Ult, mana) and NPC.IsPositionInRange(myHero, enemyPos, UltRange) then 
					Ability.CastTarget(Ult, enemy) return
				end
			end
		end
	
		if Batrider.IsSuitableToCastSpell(myHero) and Firefly and Ability.IsReady(Firefly) and Menu.IsEnabled(Batrider.optionEnableFirefly) then
			if Ability.IsCastable(Firefly, mana) and NPC.IsPositionInRange(myHero, enemyPos, FireflyRadius)
				then Ability.CastNoTarget(Firefly) return
			end
		end
		
		
		if not Entity.IsDormant(enemy) and Napalm and Ability.IsReady(Napalm) and Menu.IsEnabled(Batrider.optionEnableNapalm) then
			if Ability.IsCastable(Napalm, mana) and NPC.IsPositionInRange(myHero, enemyPos, NapalmRange) and NPC.HasModifier(enemy, "modifier_batrider_flaming_lasso") then
				Ability.CastPosition(Napalm, myPos) return
			end
		end
		
		Batrider.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION", myHero, mousePos, nil) return
	end
end

function Batrider.OnDraw()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_batrider" then return end
    if not AutoNapalmMode then return end

    --Draws text when AutoNapalmMode is toggled On--
    local pos = Entity.GetAbsOrigin(myHero)
    local x, y, visible = Renderer.WorldToScreen(pos)
    Renderer.SetDrawColor(0, 255, 0, 255)
    Renderer.DrawTextCentered(Font, x, y, "Auto", 1)
end

function Batrider.AutoNapalm()
	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_batrider" then return end
	local Napalm = NPC.GetAbility(myHero, "batrider_sticky_napalm")
    if not Napalm or not Ability.IsCastable(Napalm, NPC.GetMana(myHero)) then return end

    local range = 700
    local enemies = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
    for i, npc in ipairs(enemies) do
        if not NPC.IsIllusion(npc) and not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
            Ability.CastPosition(Napalm,  Entity.GetAbsOrigin(npc)); return
        end
    end
end

return Batrider