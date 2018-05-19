local Utility = require("Utility")
local BellyDancerVenomancer = {}  

BellyDancerVenomancer.optionEnable = Menu.AddOption({"Hero Specific","Venomancer"},"1. Enabled","Enable Or Disable Veno Combo Script")
BellyDancerVenomancer.optionKey = Menu.AddKeyOption({"Hero Specific","Venomancer"},"2. Ult Combo Key",Enum.ButtonCode.KEY_D)
BellyDancerVenomancer.optionBlink = Menu.AddOption({"Hero Specific", "Venomancer"}, "3. Use Blink to Initiate {{Venomancer}}", "")
BellyDancerVenomancer.optionBlinkRange = Menu.AddOption({"Hero Specific", "Venomancer"}, "4. Safe Blink Range {{Venomancer}}", "If using Pike then set at 375, if have Lens (+250), if have Cast Range Talent (+200), if both then add 450 to set range", 200, 850, 25)
BellyDancerVenomancer.optionBlinkStyle = Menu.AddOption({"Hero Specific", "Venomancer"}, "5. Blink Style {{Venomancer}}", "Cursor Mode uses Pike and not Glimmer, Best Position Mode uses Glimmer and not Pike", 0, 1, 1)
--Skills Toggle Menu--
BellyDancerVenomancer.optionEnableGale = Menu.AddOption({"Hero Specific","Venomancer","6. Skills"},"1. Use Venomous Gale","Enable Or Disable")
BellyDancerVenomancer.optionEnablePlague = Menu.AddOption({"Hero Specific","Venomancer","6. Skills"},"2. Use Plague Ward","Enable Or Disable")
BellyDancerVenomancer.optionEnableUlt = Menu.AddOption({"Hero Specific","Venomancer","6. Skills"},"3. Use Poison Nova","Enable Or Disable")
--Items Toggle Menu--
BellyDancerVenomancer.optionEnableDiscord = Menu.AddOption({"Hero Specific","Venomancer","7. Items"},"2. Use Discord","Turn On/Off Discord in Combo")
BellyDancerVenomancer.optionEnableGlimmer = Menu.AddOption({"Hero Specific","Venomancer","7. Items"},"3. Use Glimmer","Turn On/Off Glimmer in Combo")
BellyDancerVenomancer.optionEnablePike = Menu.AddOption({"Hero Specific", "Venomancer","7. Items"},"5. Use Pike After Combo","Turn On/Off Pike in Combo")
BellyDancerVenomancer.optionEnableOrchid = Menu.AddOption({"Hero Specific","Venomancer","7. Items"},"4. Use Orchid","Turn On/Off Orchid in Combo")
BellyDancerVenomancer.optionEnableThorn = Menu.AddOption({"Hero Specific","Venomancer","7. Items"},"1. Use Bloodthorn","Turn On/Off Bloodthorn in Combo")

BellyDancerVenomancer.lastAttackTime = 0
BellyDancerVenomancer.lastAttackTime2 = 0
BellyDancerVenomancer.LastTarget = nil

function BellyDancerVenomancer.ResetGlobalVariables()
    BellyDancerVenomancer.lastAttackTime = 0
	BellyDancerVenomancer.lastAttackTime2 = 0
	BellyDancerVenomancer.LastTarget = nil
end

Menu.SetValueName(BellyDancerVenomancer.optionBlinkStyle, 0, 'Blink to Enemy Near Cursor')
Menu.SetValueName(BellyDancerVenomancer.optionBlinkStyle, 1, 'Blink to Best Position')

function BellyDancerVenomancer.isHeroChannelling(myHero)

	if not myHero then return true end

	if NPC.IsChannellingAbility(myHero) then return true end
	if NPC.HasModifier(myHero, "modifier_teleporting") then return true end

	return false
end

function BellyDancerVenomancer.heroCanCastItems(myHero)

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

function BellyDancerVenomancer.IsInAbilityPhase(myHero)

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

function BellyDancerVenomancer.Debugger(time, npc, ability, order)

	if not Menu.IsEnabled(BellyDancerVenomancer.optionEnable) then return end
	Log.Write(tostring(time) .. " " .. tostring(NPC.GetUnitName(npc)) .. " " .. tostring(ability) .. " " .. tostring(order))
end

function BellyDancerVenomancer.GenericMainAttack(myHero, attackType, target, position)
	
	if not myHero then return end
	if not target and not position then return end

	if BellyDancerVenomancer.isHeroChannelling(myHero) == true then return end
	if BellyDancerVenomancer.heroCanCastItems(myHero) == false then return end
	if BellyDancerVenomancer.IsInAbilityPhase(myHero) == true then return end

	if Menu.IsEnabled(BellyDancerVenomancer.optionEnable) then
		if target ~= nil then
			BellyDancerVenomancer.GenericAttackIssuer(attackType, target, position, myHero)
		end
	else
		BellyDancerVenomancer.GenericAttackIssuer(attackType, target, position, myHero)
	end
end

function BellyDancerVenomancer.GenericAttackIssuer(attackType, target, position, npc)

	if not npc then return end
	if not target and not position then return end
	if os.clock() - BellyDancerVenomancer.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= BellyDancerVenomancer.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				BellyDancerVenomancer.LastTarget = target
				BellyDancerVenomancer.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= BellyDancerVenomancer.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					BellyDancerVenomancer.LastTarget = position:__tostring()
					BellyDancerVenomancer.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= BellyDancerVenomancer.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				BellyDancerVenomancer.LastTarget = position:__tostring()
				BellyDancerVenomancer.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == BellyDancerVenomancer.LastTarget then
			if not NPC.IsAttacking(npc) then
				BellyDancerVenomancer.LastTarget = nil
				BellyDancerVenomancer.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == BellyDancerVenomancer.LastTarget then
			if not NPC.IsRunning(npc) then
				BellyDancerVenomancer.LastTarget = nil
				BellyDancerVenomancer.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

function BellyDancerVenomancer.getBestPosition(unitsAround, radius)

	if not unitsAround or #unitsAround < 1 then
		return 
	end

	local countEnemies = #unitsAround

	if countEnemies == 1 then 
		return Entity.GetAbsOrigin(unitsAround[1]) 
	end

	return BellyDancerVenomancer.getMidPoint(unitsAround)

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

function BellyDancerVenomancer.getMidPoint(entityList)

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

function BellyDancerVenomancer.OnUpdate()
    if not Menu.IsEnabled(BellyDancerVenomancer.optionEnable) then return true end
	if Menu.IsKeyDown(BellyDancerVenomancer.optionKey)then
    BellyDancerVenomancer.Combo()
	end
	
	if not Engine.IsInGame() then
	BellyDancerVenomancer.ResetGlobalVariables()
	end
end

function BellyDancerVenomancer.Combo()
   
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_venomancer" then return end 
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local mana = NPC.GetMana(myHero)  
    if not enemy then return end
	local enemyPos = Entity.GetAbsOrigin(enemy)
	local mousePos = Input.GetWorldCursorPos()
	
--Ability Calls--	
	local Gale = NPC.GetAbility(myHero, "venomancer_venomous_gale")
	local PlagueWard = NPC.GetAbility(myHero, "venomancer_plague_ward")
	local Nova = NPC.GetAbility(myHero, "venomancer_poison_nova")
	
--Item Calls--	
    local Blink = NPC.GetItem(myHero, "item_blink", true)
    local Discord = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
	local Pike = NPC.GetItem(myHero, "item_hurricane_pike", true)
	local Thorn = NPC.GetItem(myHero, "item_bloodthorn", true)
	local Glimmer = NPC.GetItem(myHero, "item_glimmer_cape", true)
	
--Ability Ranges--
    local GaleRange = 800
  	local NovaRange = 540
  	local PlagueRange = 850
  	
--Item Ranges--
	local BlinkRange = 1200
	local DiscordRange = 1000
	local PikeRange = 400
	local ThornRange = 900
		
--Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_cast_range_200")
    
    if Lens then
    	GaleRange = GaleRange + 250
    	NovaRange = NovaRange + 250
    	PlagueRange = PlagueRange + 250
    	BlinkRange = BlinkRange + 250
    	DiscordRange = DiscordRange + 250
    	PikeRange = PikeRange + 250
    	ThornRange = ThornRange + 250
    end
	
	if BonusTalentRange and Ability.GetLevel(BonusTalentRange) > 0 then
    	GaleRange = GaleRange + 200
    	NovaRange = NovaRange + 200
    	PlagueRange = PlagueRange + 250
    	BlinkRange = BlinkRange + 200
    	DiscordRange = DiscordRange + 200
    	PikeRange = PikeRange + 200
    	ThornRange = ThornRange + 200
  	end		
  	
  	local NovaRadius = 830
	if NPC.HasAbility(myHero, "special_bonus_unique_venomancer_6") then
		if Ability.GetLevel(NPC.GetAbility(myHero, "special_bonus_unique_venomancer_6")) > 0 then
		NovaRadius = 1630
		end
	end
  	
  	if Menu.IsEnabled(BellyDancerVenomancer.optionEnable) then
	
		if enemy and not NPC.IsIllusion(enemy) and not Entity.IsDormant(enemy) then
        	if Blink and Menu.IsEnabled(BellyDancerVenomancer.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange) then
        		if Menu.GetValue(BellyDancerVenomancer.optionBlinkStyle) == 0 then
            	Ability.CastPosition(Blink, (Entity.GetAbsOrigin(enemy) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Normalized():Scaled(Menu.GetValue(BellyDancerVenomancer.optionBlinkRange)))) return 
				else
				local BestPos = BellyDancerVenomancer.getBestPosition(Heroes.InRadius(Entity.GetAbsOrigin(enemy), NovaRadius * 2, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY), NovaRadius)
					if BestPos ~= nil then
					Ability.CastPosition(Blink, BestPos) return 
					end
				end
			end
    	end
	
		if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and
		Discord and Ability.IsReady(Discord) and Menu.IsEnabled(BellyDancerVenomancer.optionEnableDiscord) and Ability.IsCastable(Discord, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), DiscordRange) then Ability.CastPosition(Discord, enemyPos) return end
	
		if not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and
		Nova and Ability.IsReady(Nova) and Menu.IsEnabled(BellyDancerVenomancer.optionEnableUlt) and Ability.IsCastable(Nova, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), NovaRange) then Ability.CastNoTarget(Nova) return end
	
		if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and
		Gale and Ability.IsReady(Gale) and Menu.IsEnabled(BellyDancerVenomancer.optionEnableGale) and Ability.IsCastable(Gale, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), GaleRange) then Ability.CastPosition(Gale, enemyPos) return end
	
		if not Entity.IsDormant(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and
		PlagueWard and Ability.IsReady(PlagueWard) and Menu.IsEnabled(BellyDancerVenomancer.optionEnablePlague) and Ability.IsCastable(PlagueWard, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), PlagueRange) then Ability.CastPosition(PlagueWard, enemyPos) return end
	
		if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and
		Thorn and Ability.IsReady(Thorn) and Menu.IsEnabled(BellyDancerVenomancer.optionEnableThorn) and Ability.IsCastable(Thorn, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ThornRange) then Ability.CastTarget(Thorn, enemy) return end
	
		if Utility.CanCastSpellOn(enemy) and not NPC.IsIllusion(enemy) and Menu.GetValue(BellyDancerVenomancer.optionBlinkStyle) == 0 then
			if Pike and Ability.IsReady(Pike) and Menu.IsEnabled(BellyDancerVenomancer.optionEnablePike) and Ability.IsCastable(Pike, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), PikeRange) and Ability.SecondsSinceLastUse(Gale) > 0 then Ability.CastTarget(Pike, enemy) return end
		end
	
		if not NPC.IsIllusion(myHero) and not NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and Menu.GetValue(BellyDancerVenomancer.optionBlinkStyle) == 1 then
			if Glimmer and Ability.IsReady(Glimmer) and Menu.IsEnabled(BellyDancerVenomancer.optionEnableGlimmer) and Ability.IsCastable(Glimmer, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), Ability.GetCastRange(Glimmer)) then Ability.CastTarget(Glimmer, myHero) return end
		end

		if Menu.GetValue(BellyDancerVenomancer.optionBlinkStyle) == 0 then BellyDancerVenomancer.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
		end
			
		if Menu.GetValue(BellyDancerVenomancer.optionBlinkStyle) == 1 then BellyDancerVenomancer.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION", enemy, mousePos, nil) return
		end
	end
end

return BellyDancerVenomancer