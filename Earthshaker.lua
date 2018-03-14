local Earthshaker = {}  

Earthshaker.optionEnable = Menu.AddOption({ "Hero Specific","Earthshaker" }, "Enabled", "")
Earthshaker.optionKey = Menu.AddKeyOption({ "Hero Specific","Earthshaker" }, "Echo Combo Key", Enum.ButtonCode.KEY_D)
Earthshaker.optionEnableGlimmer = Menu.AddOption({ "Hero Specific","Earthshaker","Toggle Items"},"Use Glimmer Cape","")
Earthshaker.optionEnableShadow = Menu.AddOption({ "Hero Specific","Earthshaker","Toggle Items"},"Use Shadow Blade","")
Earthshaker.optionEnableSilverEdge = Menu.AddOption({ "Hero Specific","Earthshaker","Toggle Items"},"Use Silver Edge","")
Earthshaker.optionEnableRefresher = Menu.AddOption({ "Hero Specific","Earthshaker","Toggle Items"},"Use Refresher Orb","")

function Earthshaker.OnUpdate()
   if not Menu.IsEnabled(Earthshaker.optionEnable) then return true end
   if not Menu.IsKeyDown(Earthshaker.optionKey) then return end
   Earthshaker.Combo()
end

function Earthshaker.Combo()
   
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_earthshaker" then return end 
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local myMana = NPC.GetMana(myHero)  
    if not hero then return end
	local heroPos = Entity.GetAbsOrigin(hero)
	local mousePos = Input.GetWorldCursorPos()
	
	local Totem = NPC.GetAbility(myHero, "earthshaker_enchant_totem")
	local Echo = NPC.GetAbility(myHero, "earthshaker_echo_slam")
	
    local Blink = NPC.GetItem(myHero, "item_blink", true)
    local Discord = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local Shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
	local Glimmer = NPC.GetItem(myHero, "item_glimmer_cape", true)
	local Shadow = NPC.GetItem(myHero, "item_invis_sword", true)
	local SilverEdge = NPC.GetItem(myHero, "item_silver_edge", true)
	local Refresher = NPC.GetItem(myHero, "item_refresher", true)
	
	if Ability.IsCastable(Echo, myMana) and Blink and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200,0) then
	
	if not NPC.IsPositionInRange(myHero,Entity.GetAbsOrigin(hero), 0 , 275) then 
	if Blink and Ability.IsCastable(Blink, myMana) and hero ~= nil and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200,0) then Ability.CastPosition(Blink,mousePos) return end
	end
	
	if Discord and Ability.IsCastable(Discord, myMana) and hero ~= nil and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1000,0) then Ability.CastPosition(Discord,heroPos) return end
	
	if Shivas and Ability.IsCastable(Shivas, myMana) and hero ~= nil and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),900,0) then Ability.CastNoTarget(Shivas) return end
	
	if Echo and Ability.IsCastable(Echo, myMana) and hero ~= nil and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),600,0) then Ability.CastNoTarget(Echo) end
	
	if Totem and Ability.IsCastable(Totem, myMana) and hero ~= nil and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),300,0) then Ability.CastNoTarget(Totem) end
	
	if Refresher and Menu.IsEnabled(Earthshaker.optionEnableRefresher) and Ability.IsCastable(Refresher, myMana) and hero ~= nil and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),275,0) then Ability.CastNoTarget(Refresher) return end
	
	if Glimmer and Menu.IsEnabled(Earthshaker.optionEnableGlimmer) and Ability.IsCastable(Glimmer, myMana) and hero ~= nil and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),800,0) then Ability.CastTarget(Glimmer, myHero) return end
	
	if Shadow and Menu.IsEnabled(Earthshaker.optionEnableShadow) and Ability.IsCastable(Shadow, myMana) and hero ~= nil and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),275,0) then Ability.CastNoTarget(Shadow) return end
	
	if SilverEdge and Menu.IsEnabled(Earthshaker.optionEnableSilverEdge) and Ability.IsCastable(SilverEdge, myMana) and hero ~= nil and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),275,0) then Ability.CastNoTarget(SilverEdge) return end
	end
	
	if not NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(hero),1200,0) and Blink then return 
	end
end

return Earthshaker