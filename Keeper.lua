local Keeper = {}

Keeper.optionEnable = Menu.AddOption({"Hero Specific","Keeper"},"1. Enabled","Enable Or Disable Keeper Combo Script")
Keeper.ToggleKey = Menu.AddKeyOption({"Hero Specific", "Keeper"}, "2. Auto Mode Toggle Key", Enum.ButtonCode.KEY_S)
Keeper.optionEnableSelfChakra = Menu.AddOption({"Hero Specific", "Keeper"}, "3. Enable Self-Chakra on %", "Enable or Disable")
Keeper.ManaRestorePoint = Menu.AddOption({"Hero Specific", "Keeper", "3.1 Set Threshold %"}, "Threshold My Mana", "Set threshold for KoTL Auto-Mana Restore", 5, 90, 5)
Keeper.optionKey = Menu.AddKeyOption({"Hero Specific","Keeper"},"4. Combo Key",Enum.ButtonCode.KEY_D)
Keeper.FontLarge = Renderer.LoadFont("Calibri", 24, Enum.FontWeight.EXTRABOLD)
--Skills Toggle Menu--
Keeper.optionEnableLeak = Menu.AddOption({"Hero Specific","Keeper","5. Skills"},"1. Use Mana Leak","Enable Or Disable")
--Items Toggle Menu--
Keeper.optionEnableAtos = Menu.AddOption({ "Hero Specific","Keeper","6. Items"},"1. Use Atos","Enable Or Disable")
Keeper.optionEnableDagon = Menu.AddOption({ "Hero Specific","Keeper","6. Items"},"2. Use Dagon","Enable Or Disable")
Keeper.optionEnableDiffusal = Menu.AddOption({ "Hero Specific","Keeper","6. Items"},"3. Use Diffusal","Enable Or Disable")
Keeper.optionEnableForce = Menu.AddOption({ "Hero Specific","Keeper","6. Items"},"4. Use Force Staff","Enable Or Disable")
Keeper.optionEnableNullifier = Menu.AddOption({ "Hero Specific","Keeper","6. Items"},"5. Use Nullifier","Enable Or Disable")

local AutoMode = false

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

function Keeper.OnDraw()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_keeper_of_the_light" then return end
    if not AutoMode then return end

    --Displays when Auto Mode is toggled On--
    local pos = Entity.GetAbsOrigin(myHero)
    local x, y, visible = Renderer.WorldToScreen(pos)
    Renderer.SetDrawColor(0, 255, 0, 255)
    Renderer.DrawTextCentered(Keeper.FontLarge, x, y, "Auto-Chakra", 1)
end

function Keeper.OnUpdate()
    if not Menu.IsEnabled(Keeper.optionEnable) then return true end
	if Menu.IsKeyDown(Keeper.optionKey)then
    Keeper.Combo()
	end
	
	if Menu.IsKeyDownOnce(Keeper.ToggleKey) then
    	AutoMode = not AutoMode
	end

	if Menu.IsEnabled(Keeper.optionEnableSelfChakra) and AutoMode then
    	Keeper.SelfChakra()
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
    local Atos = NPC.GetItem(myHero, "item_rod_of_atos", true)
    local Diffusal = NPC.GetItem(myHero, "item_diffusal_blade", true)
    local ForceStaff  = NPC.GetItem(myHero, "item_force_staff", true)
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local Nullifier = NPC.GetItem(myHero, "item_nullifier", true)
    
    local Dagon = NPC.GetItem(myHero, "item_dagon", true)
	if not Dagon then
		for i = 2, 5 do
			Dagon = NPC.GetItem(myHero, "item_dagon_" .. i, true)
			if Dagon then break end
		end
	end
    
    --Ability Ranges--
    local LeakRange = Ability.GetCastRange(Leak)
    
    --Item Ranges--
    local AtosRange = 1150
    local DiffusalRange = 600
  	local ForceRange = 750
  	local NullifierRange = 600
  	
  	--Talent Tree Bonus Range-- 	
  	local TalentBonusRange = NPC.GetAbility(myHero, "special_bonus_cast_range_350")
  	
  	if Lens then
  		AtosRange = AtosRange + 250
  		DiffusalRange = DiffusalRange + 250
  		ForceRange = ForceRange + 250
    	LeakRange = LeakRange + 250
    	NullifierRange = NullifierRange + 250
    end
	
	if TalentBonusRange and Ability.GetLevel(TalentBonusRange) > 0 then
		AtosRange = AtosRange + 350
		DiffusalRange = DiffusalRange + 350
		ForceRange = ForceRange + 350
		LeakRange = LeakRange + 350
		NullifierRange = NullifierRange + 350	
  	end
	  
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED) and Menu.IsEnabled(Keeper.optionEnableAtos) and not Entity.IsDormant(enemy) then
		if Atos and Ability.IsCastable(Atos, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), AtosRange) then
			Ability.CastTarget(Atos, enemy) return
		end
	end		
		     
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and Menu.IsEnabled(Keeper.optionEnableLeak) and not Entity.IsDormant(enemy) then
		if Leak and Ability.IsReady(Leak) and Ability.IsCastable(Leak, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), LeakRange) then
				Ability.CastTarget(Leak, enemy) return 
			end
		end
	end
			     
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and NPC.HasModifier(enemy, "modifier_keeper_of_the_light_mana_leak") and Menu.IsEnabled(Keeper.optionEnableForce) and not Entity.IsDormant(enemy) then
		if ForceStaff and Ability.IsCastable(ForceStaff, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ForceRange) then
			Ability.CastTarget(ForceStaff, enemy) return
		end
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and Menu.IsEnabled(Keeper.optionEnableDagon) and not NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") and not NPC.HasModifier(enemy, "modifier_sheepstick_debuff") and not Entity.IsDormant(enemy) then
		if Dagon and Ability.IsCastable(Dagon, mana) then
			Ability.CastTarget(Dagon, enemy) return
		end
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and Menu.IsEnabled(Keeper.optionEnableDiffusal) and not NPC.HasModifier(enemy, "modifier_item_diffusal_blade_slow") and not Entity.IsDormant(enemy) then
		if Diffusal and Ability.IsCastable(Diffusal, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), DiffusalRange) then
			Ability.CastTarget(Diffusal, enemy) return
		end
	end
	
	if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and Menu.IsEnabled(Keeper.optionEnableNullifier) and not NPC.HasModifier(enemy, "modifier_item_nullifier_mute") and not Entity.IsDormant(enemy) then
		if Nullifier and Ability.IsCastable(Nullifier, mana) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), NullifierRange) then
			Ability.CastTarget(Nullifier, enemy) return
		end
	end
	
	Keeper.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
end

function Keeper.SelfChakra()
	if not Menu.IsEnabled(Keeper.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_keeper_of_the_light" then return end
	local mana = NPC.GetMana(myHero)
	
	if not myHero then return end  
	
	--Ability Call--
	local Chakra = NPC.GetAbility(myHero, "keeper_of_the_light_chakra_magic")
	local Illuminate = NPC.GetAbility(myHero, "keeper_of_the_light_illuminate")
	
	if Menu.IsEnabled(Keeper.optionEnableSelfChakra) and not NPC.IsIllusion(myHero) and Keeper.heroCanCastItems(myHero) then
		if Chakra and Ability.IsReady(Chakra) and Ability.IsCastable(Chakra, mana) and not Ability.IsChannelling(Illuminate) then
			local MyManaPercentage = (NPC.GetMana(myHero) / NPC.GetMaxMana(myHero)) * 100
			if MyManaPercentage <= Menu.GetValue(Keeper.ManaRestorePoint) then
		        Ability.CastTarget(Chakra, myHero) return
		    end
		end
	end
end
	
return Keeper
