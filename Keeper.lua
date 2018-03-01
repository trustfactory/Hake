local Keeper = {}

Keeper.optionKey = Menu.AddKeyOption({"Hero Specific","Keeper"},"Combo Key",Enum.ButtonCode.KEY_D)
Keeper.optionEnable = Menu.AddOption({"Hero Specific","Keeper"},"Enabled","Enable Or Disable Keeper Combo Script")

function Keeper.OnUpdate()
    if not Menu.IsEnabled(Keeper.optionEnable) then return true end
	if Menu.IsKeyDown(Keeper.optionKey)then
    Keeper.Combo()
	end
end	


function Keeper.Combo()
if not Menu.IsKeyDown(Keeper.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_keeper_of_the_light" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local heroPos = Entity.GetAbsOrigin(hero)
	local mana = NPC.GetMana(myHero)
	
	if not hero then return end
	
    local Leak = NPC.GetAbility(myHero, "keeper_of_the_light_mana_leak")
    local ForceStaff  = NPC.GetItem(myHero, "item_force_staff", true)
	
	if Menu.IsEnabled(Keeper.optionEnable) then
		     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and Leak and Ability.IsCastable(Leak, mana) then Ability.CastTarget(Leak, hero) return 
	end
		     
	if not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
	and ForceStaff and Ability.IsCastable(ForceStaff, mana) then Ability.CastTarget(ForceStaff, hero) return 
	end 
end
end
	
return Keeper