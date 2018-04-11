local Oracle = {}

Oracle.optionKey = Menu.AddKeyOption({"Hero Specific","Oracle"}, "Non-Ult Healing Key", Enum.ButtonCode.KEY_D)
Oracle.optionKey2 = Menu.AddKeyOption({"Hero Specific","Oracle"}, "Ult Healing Key", Enum.ButtonCode.KEY_F)
Oracle.optionEnable = Menu.AddOption({"Hero Specific","Oracle"}, "Enabled", "Enable Or Disable Oracle Combo Script")

function Oracle.OnUpdate()
    if not Menu.IsEnabled(Oracle.optionEnable) then return true end
	if Menu.IsKeyDown(Oracle.optionKey)then
    Oracle.Combo()
	end
	
	if not Menu.IsEnabled(Oracle.optionEnable) then return true end
	if Menu.IsKeyDown(Oracle.optionKey2)then
    Oracle.Combo2()
	end
end	


function Oracle.Combo()
if not Menu.IsKeyDown(Oracle.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_oracle" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_FRIEND)
    local mana = NPC.GetMana(myHero)
	
	if not hero then return end
	
    local edict = NPC.GetAbility(myHero, "oracle_fates_edict")
    local flames = NPC.GetAbility(myHero, "oracle_purifying_flames")
	
	if Menu.IsEnabled(Oracle.optionEnable) then
		     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and edict and Ability.IsCastable(edict, mana) then Ability.CastTarget(edict, hero) return 
	end
			     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and flames and Ability.IsCastable(flames, mana) and NPC.HasModifier(hero, "modifier_oracle_fates_edict") then Ability.CastTarget(flames, hero) return end
	end
	Player.PrepareUnitOrders(Players.GetLocal(), 4, hero, Vector(0,0,0), hero, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero) 
end

function Oracle.Combo2()
if not Menu.IsKeyDown(Oracle.optionKey2) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_oracle" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_FRIEND)
    local mana = NPC.GetMana(myHero)
	
	if not hero then return end
	
    local promise = NPC.GetAbility(myHero, "oracle_false_promise")
    local flames = NPC.GetAbility(myHero, "oracle_purifying_flames")
	
	if Menu.IsEnabled(Oracle.optionEnable) then
		     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and promise and Ability.IsCastable(promise, mana) then Ability.CastTarget(promise, hero) return 
	end
			     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and flames and Ability.IsCastable(flames, mana) and NPC.HasModifier(hero, "modifier_oracle_false_promise") then Ability.CastTarget(flames, hero) return end
	end
	Player.PrepareUnitOrders(Players.GetLocal(), 4, hero, Vector(0,0,0), hero, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
end
	
return Oracle
