local Keeper = {}

Keeper.optionKey = Menu.AddKeyOption({"Hero Specific","Keeper"},"Combo Key",Enum.ButtonCode.KEY_D)
Keeper.optionEnable = Menu.AddOption({"Hero Specific","Keeper"},"Enabled","Enable Or Disable Keeper Combo Script")

-- global Variables
Keeper.lastAttackTime = 0
Keeper.lastAttackTime2 = 0
Keeper.LastTarget = nil

function Keeper.ResetGlobalVariables()
    Keeper.lastAttackTime = 0
	Keeper.lastAttackTime2 = 0
	Keeper.LastTarget = nil
end

function Keeper.isHeroChannelling(myHero)

	if not myHero then return true end

	if NPC.IsChannellingAbility(myHero) then return true end
	if NPC.HasModifier(myHero, "modifier_teleporting") then return true end

	return false
end

function Keeper.heroCanCastItems(myHero)

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

function Keeper.IsInAbilityPhase(myHero)

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

function Keeper.Debugger(time, npc, ability, order)

	if not Menu.IsEnabled(Keeper.optionEnable) then return end
	Log.Write(tostring(time) .. " " .. tostring(NPC.GetUnitName(npc)) .. " " .. tostring(ability) .. " " .. tostring(order))
end

function Keeper.GenericMainAttack(myHero, attackType, target, position)
	
	if not myHero then return end
	if not target and not position then return end

	if Keeper.isHeroChannelling(myHero) == true then return end
	if Keeper.heroCanCastItems(myHero) == false then return end
	if Keeper.IsInAbilityPhase(myHero) == true then return end

	if Menu.IsEnabled(Keeper.optionEnable) then
		if target ~= nil then
			Keeper.GenericAttackIssuer(attackType, target, position, myHero)
		end
	else
		Keeper.GenericAttackIssuer(attackType, target, position, myHero)
	end
end

function Keeper.GenericAttackIssuer(attackType, target, position, npc)

	if not npc then return end
	if not target and not position then return end
	if os.clock() - Keeper.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= Keeper.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Keeper.LastTarget = target
				Keeper.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= Keeper.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					Keeper.LastTarget = position:__tostring()
					Keeper.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= Keeper.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Keeper.LastTarget = position:__tostring()
				Keeper.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == Keeper.LastTarget then
			if not NPC.IsAttacking(npc) then
				Keeper.LastTarget = nil
				Keeper.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == Keeper.LastTarget then
			if not NPC.IsRunning(npc) then
				Keeper.LastTarget = nil
				Keeper.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

function Keeper.OnUpdate()
    if not Menu.IsEnabled(Keeper.optionEnable) then return true end
	if Menu.IsKeyDown(Keeper.optionKey)then
    Keeper.Combo()
	end
	
	if not Engine.IsInGame() then
	Keeper.ResetGlobalVariables()
	end
end	


function Keeper.Combo()
if not Menu.IsKeyDown(Keeper.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_keeper_of_the_light" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
	if not enemy then return end
	
	--Ability Calls--
    local Leak = NPC.GetAbility(myHero, "keeper_of_the_light_mana_leak")
    
    --Item Calls--
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local ForceStaff  = NPC.GetItem(myHero, "item_force_staff", true)
    
    --Ability Ranges--
    local LeakRange = Ability.GetCastRange(Leak)
    
    --Item Ranges--
  	local ForceRange = 750
  	
  	--Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_cast_range_350")
  	
  	if Lens then
    		LeakRange = LeakRange + 250
    		ForceRange = ForceRange + 250
    end
	
	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
			LeakRange = LeakRange + 350
    		ForceRange = ForceRange + 350
  	end		
	
	if Menu.IsEnabled(Keeper.optionEnable) then
		     
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Leak and Ability.IsReady(Leak) and Ability.IsCastable(Leak, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), LeakRange) then Ability.CastTarget(Leak, enemy) Keeper.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return 
	end
			     
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and
	ForceStaff and Ability.IsCastable(ForceStaff, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ForceRange) and NPC.HasModifier(enemy, "modifier_keeper_of_the_light_mana_leak") then Ability.CastTarget(ForceStaff, enemy) Keeper.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
	end
	
	Keeper.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil)
		return
	end 
end
	
return Keeper
