-- Features:
-- 1. Show economic status of every player in game (like spectator mode). It is based on the total value of items that players have in inventory.
-- 2. Show economic difference between two teams.

-- ===========================================

local EconPanel = {}

EconPanel.optionEnable = Menu.AddOption({ "Awareness", "Econ Panel" }, "Enable Econ Panel", "Shows Hero Ranking of Total Item Worth")
EconPanel.key = Menu.AddKeyOption({ "Awareness", "Econ Panel" }, "Turn On/Off Key", Enum.ButtonCode.KEY_L)
EconPanel.font = Renderer.LoadFont("Tahoma", 16, Enum.FontWeight.EXTRABOLD)
EconPanel.isOpen = true
EconPanel.heroIconPath = "resource/flash3/images/heroes/"
handlers = {}

EconPanel.item2price = {}
EconPanel.item2price["item_aegis"] = 0 --"Aegis of the Immortal"
EconPanel.item2price["item_courier"] = 50 -- "Animal Courier"
EconPanel.item2price["item_boots_of_elves"] = 450 -- "Band of Elvenskin"
EconPanel.item2price["item_belt_of_strength"] = 450 -- "Belt of Strength"
EconPanel.item2price["item_blade_of_alacrity"] = 1000 -- "Blade of Alacrity"
EconPanel.item2price["item_blades_of_attack"] = 420 -- "Blades of Attack"
EconPanel.item2price["item_blight_stone"] = 300 -- "Blight Stone"
EconPanel.item2price["item_blink"] = 2250 -- "Blink Dagger"
EconPanel.item2price["item_boots"] = 500 -- "Boots of Speed"
EconPanel.item2price["item_bottle"] = 650 -- "Bottle"
EconPanel.item2price["item_broadsword"] = 1200 -- "Broadsword"
EconPanel.item2price["item_chainmail"] = 550 -- "Chainmail"
EconPanel.item2price["item_cheese"] = 0 -- "Cheese"
EconPanel.item2price["item_circlet"] = 165 -- "Circlet"
EconPanel.item2price["item_clarity"] = 50 -- "Clarity"
EconPanel.item2price["item_claymore"] = 1400 -- "Claymore"
EconPanel.item2price["item_cloak"] = 550 -- "Cloak"
EconPanel.item2price["item_demon_edge"] = 2200 -- "Demon Edge"
EconPanel.item2price["item_dust"] = 180 -- "Dust of Appearance"
EconPanel.item2price["item_eagle"] = 3200 -- "Eaglesong"
EconPanel.item2price["item_enchanted_mango"] = 100 -- "Enchanted Mango"
EconPanel.item2price["item_energy_booster"] = 900 -- "Energy Booster"
EconPanel.item2price["item_faerie_fire"] = 75 -- "Faerie Fire"
EconPanel.item2price["item_gauntlets"] = 135 -- "Gauntlets of Strength"
EconPanel.item2price["item_gem"] = 900 -- "Gem of True Sight"
EconPanel.item2price["item_ghost"] = 1500 -- "Ghost Scepter"
EconPanel.item2price["item_gloves"] = 500 -- "Gloves of Haste"
EconPanel.item2price["item_flask"] = 110 -- "Healing Salve"
EconPanel.item2price["item_helm_of_iron_will"] = 900 -- "Helm of Iron Will"
EconPanel.item2price["item_hyperstone"] = 2000 -- "Hyperstone"
EconPanel.item2price["item_infused_raindrop"] = 225 -- "Infused Raindrop"
EconPanel.item2price["item_branches"] = 50 -- "Iron Branch"
EconPanel.item2price["item_javelin"] = 1100 -- "Javelin"
EconPanel.item2price["item_magic_stick"] = 200 -- "Magic Stick"
EconPanel.item2price["item_mantle"] = 135 -- "Mantle of Intelligence"
EconPanel.item2price["item_mithril_hammer"] = 1600 -- "Mithril Hammer"
EconPanel.item2price["item_lifesteal"] = 1100 -- "Morbid Mask"
EconPanel.item2price["item_mystic_staff"] = 2700 -- "Mystic Staff"
EconPanel.item2price["item_ward_observer"] = 80 -- "Observer Ward"
EconPanel.item2price["item_ogre_axe"] = 1000 -- "Ogre Axe"
EconPanel.item2price["item_orb_of_venom"] = 275 -- "Orb of Venom"
EconPanel.item2price["item_platemail"] = 1400 -- "Platemail"
EconPanel.item2price["item_point_booster"] = 1200 -- "Point Booster"
EconPanel.item2price["item_quarterstaff"] = 875 -- "Quarterstaff"
EconPanel.item2price["item_quelling_blade"] = 200 -- "Quelling Blade"
EconPanel.item2price["item_reaver"] = 3000 -- "Reaver"
EconPanel.item2price["item_ring_of_health"] = 850 -- "Ring of Health"
EconPanel.item2price["item_ring_of_protection"] = 175 -- "Ring of Protection"
EconPanel.item2price["item_ring_of_regen"] = 300 -- "Ring of Regen"
EconPanel.item2price["item_robe"] = 450 -- "Robe of the Magi"
EconPanel.item2price["item_relic"] = 3800 -- "Sacred Relic"
EconPanel.item2price["item_sobi_mask"] = 325 -- "Sage's Mask"
EconPanel.item2price["item_ward_sentry"] = 100 -- "Sentry Ward"
EconPanel.item2price["item_shadow_amulet"] = 1300 -- "Shadow Amulet"
EconPanel.item2price["item_slippers"] = 135 -- "Slippers of Agility"
EconPanel.item2price["item_smoke_of_deceit"] = 50 -- "Smoke of Deceit"
EconPanel.item2price["item_staff_of_wizardry"] = 1000 -- "Staff of Wizardry"
EconPanel.item2price["item_stout_shield"] = 200 -- "Stout Shield"
EconPanel.item2price["item_talisman_of_evasion"] = 1450 -- "Talisman of Evasion"
EconPanel.item2price["item_tango"] = 90 -- "Tango"
EconPanel.item2price["item_tango_single"] = 0 -- "Tango (Shared)"
EconPanel.item2price["item_tome_of_knowledge"] = 150 -- "Tome of Knowledge"
EconPanel.item2price["item_tpscroll"] = 50 -- "Town Portal Scroll"
EconPanel.item2price["item_ultimate_orb"] = 2150 -- "Ultimate Orb"
EconPanel.item2price["item_vitality_booster"] = 1100 -- "Vitality Booster"
EconPanel.item2price["item_void_stone"] = 850 -- "Void Stone"
EconPanel.item2price["item_wind_lace"] = 250 -- "Wind Lace"
EconPanel.item2price["item_abyssal_blade"] = 6400 -- "Abyssal Blade"
EconPanel.item2price["item_aether_lens"] = 2350 -- "Aether Lens"
EconPanel.item2price["item_ultimate_scepter"] = 4200 -- "Aghanim's Scepter"
EconPanel.item2price["item_arcane_boots"] = 1300 -- "Arcane Boots"
EconPanel.item2price["item_armlet"] = 2370 -- "Armlet of Mordiggian"
EconPanel.item2price["item_assault"] = 5250 -- "Assault Cuirass"
EconPanel.item2price["item_bfury"] = 4100 -- "Battle Fury"
EconPanel.item2price["item_black_king_bar"] = 3975 -- "Black King Bar"
EconPanel.item2price["item_blade_mail"] = 2200 -- "Blade Mail"
EconPanel.item2price["item_bloodstone"] = 4900 -- "Bloodstone"
EconPanel.item2price["item_bloodthorn"] = 7195 -- "Bloodthorn"
EconPanel.item2price["item_travel_boots"] = 2400 -- "Boots of Trave 1"
EconPanel.item2price["item_travel_boots_2"] = 4400 -- "Boots of Trave 2"
EconPanel.item2price["item_bracer"] = 465 -- "Bracer"
EconPanel.item2price["item_buckler"] = 800 -- "Buckler"
EconPanel.item2price["item_butterfly"] = 5525 -- "Butterfly"
EconPanel.item2price["item_crimson_guard"] = 3550 -- "Crimson Guard"
EconPanel.item2price["item_lesser_crit"] = 2120 -- "Crystalys"
EconPanel.item2price["item_greater_crit"] = 5320 -- "Daedalus"
EconPanel.item2price["item_dagon"] = 2715 -- "Dagon 1"
EconPanel.item2price["item_dagon_2"] = 3965 -- "Dagon 2"
EconPanel.item2price["item_dagon_3"] = 5215 -- "Dagon 3"
EconPanel.item2price["item_dagon_4"] = 6465 -- "Dagon 4"
EconPanel.item2price["item_dagon_5"] = 7715 -- "Dagon 5"
EconPanel.item2price["item_desolator"] = 3500 -- "Desolator"
EconPanel.item2price["item_diffusal_blade"] = 3150 -- "Diffusal Blade"
EconPanel.item2price["item_dragon_lance"] = 1900 -- "Dragon Lance"
EconPanel.item2price["item_ancient_janggo"] = 1615 -- "Drum of Endurance"
EconPanel.item2price["item_echo_sabre"] = 2650 -- "Echo Sabre"
EconPanel.item2price["item_ethereal_blade"] = 4700 -- "Ethereal Blade"
EconPanel.item2price["item_cyclone"] = 2750 -- "Eul's Scepter of Divinity"
EconPanel.item2price["item_skadi"] = 5500 -- "Eye of Skadi"
EconPanel.item2price["item_force_staff"] = 2250 -- "Force Staff"
EconPanel.item2price["item_glimmer_cape"] = 1850 -- "Glimmer Cape"
EconPanel.item2price["item_guardian_greaves"] = 5350 -- "Guardian Greaves"
EconPanel.item2price["item_hand_of_midas"] = 2150 -- "Hand of Midas"
EconPanel.item2price["item_headdress"] = 650 -- "Headdress"
EconPanel.item2price["item_heart"] = 5200 -- "Heart of Tarrasque"
EconPanel.item2price["item_heavens_halberd"] = 3400 -- "Heaven's Halberd"
EconPanel.item2price["item_helm_of_the_dominator"] = 2000 -- "Helm of the Dominator"
EconPanel.item2price["item_hood_of_defiance"] = 1700 -- "Hood of Defiance"
EconPanel.item2price["item_hurricane_pike"] = 4615 -- "Hurricane Pike"
EconPanel.item2price["item_sphere"] = 5050 -- "Linken's Sphere"
EconPanel.item2price["item_lotus_orb"] = 4000 -- "Lotus Orb"
EconPanel.item2price["item_maelstrom"] = 2800 -- "Maelstrom"
EconPanel.item2price["item_magic_wand"] = 400 -- "Magic Wand"
EconPanel.item2price["item_manta"] = 5000 -- "Manta Style"
EconPanel.item2price["item_mask_of_madness"] = 1975 -- "Mask of Madness"
EconPanel.item2price["item_medallion_of_courage"] = 1175 -- "Medallion of Courage"
EconPanel.item2price["item_mekansm"] = 2350 -- "Mekansm"
EconPanel.item2price["item_mjollnir"] = 5700 -- "Mjollnir"
EconPanel.item2price["item_monkey_king_bar"] = 4200 -- "Monkey King Bar"
EconPanel.item2price["item_moon_shard"] = 4000 -- "Moon Shard"
EconPanel.item2price["item_necronomicon"] = 2400 -- "Necronomicon 1"
EconPanel.item2price["item_necronomicon_2"] = 3850 -- "Necronomicon 2"
EconPanel.item2price["item_necronomicon_3"] = 5050 -- "Necronomicon 3"
EconPanel.item2price["item_null_talisman"] = 465 -- "Null Talisman"
EconPanel.item2price["item_oblivion_staff"] = 1650 -- "Oblivion Staff"
EconPanel.item2price["item_ward_dispenser"] = 165 -- "Observer and Sentry Wards"
EconPanel.item2price["item_octarine_core"] = 5900 -- "Octarine Core"
EconPanel.item2price["item_orchid"] = 4075 -- "Orchid Malevolence"
EconPanel.item2price["item_pers"] = 1700 -- "Perseverance"
EconPanel.item2price["item_phase_boots"] = 1240 -- "Phase Boots"
EconPanel.item2price["item_pipe"] = 3150 -- "Pipe of Insight"
EconPanel.item2price["item_power_treads"] = 1350 -- "Power Treads"
EconPanel.item2price["item_radiance"] = 5150 -- "Radiance"
EconPanel.item2price["item_rapier"] = 6000 -- "Divine Rapier"
EconPanel.item2price["item_refresher"] = 5200 -- "Refresher Orb"
EconPanel.item2price["item_ring_of_aquila"] = 965 -- "Ring of Aquila"
EconPanel.item2price["item_ring_of_basilius"] = 500 -- "Ring of Basilius"
EconPanel.item2price["item_rod_of_atos"] = 3030 -- "Rod of Atos"
EconPanel.item2price["item_sange"] = 1950 -- "Sange"
EconPanel.item2price["item_sange_and_yasha"] = 3900 -- "Sange and Yasha"
EconPanel.item2price["item_satanic"] = 5500 -- "Satanic"
EconPanel.item2price["item_sheepstick"] = 5700 -- "Scythe of Vyse"
EconPanel.item2price["item_invis_sword"] = 2700 -- "Shadow Blade"
EconPanel.item2price["item_shivas_guard"] = 4750 -- "Shiva's Guard"
EconPanel.item2price["item_silver_edge"] = 5550 -- "Silver Edge"
EconPanel.item2price["item_basher"] = 2700 -- "Skull Basher"
EconPanel.item2price["item_solar_crest"] = 2625 -- "Solar Crest"
EconPanel.item2price["item_soul_booster"] = 3200 -- "Soul Booster"
EconPanel.item2price["item_soul_ring"] = 770 -- "Soul Ring"
EconPanel.item2price["item_tranquil_boots"] = 950 -- "Tranquil Boots"
EconPanel.item2price["item_urn_of_shadows"] = 875 -- "Urn of Shadows"
EconPanel.item2price["item_vanguard"] = 2150 -- "Vanguard"
EconPanel.item2price["item_veil_of_discord"] = 2330 -- "Veil of Discord"
EconPanel.item2price["item_vladmir"] = 2250 -- "Vladmir's Offering"
EconPanel.item2price["item_wraith_band"] = 465 -- "Wraith Band"
EconPanel.item2price["item_yasha"] = 1950 -- "Yasha"
EconPanel.item2price["item_meteor_hammer"] = 2625 -- "Meteor Hammer"
EconPanel.item2price["item_spirit_vessel"] = 2975 -- "Spirit Vessel"
EconPanel.item2price["item_nullifier"] = 4700 -- "Nullifier"
EconPanel.item2price["item_aeon_disk"] = 3350 -- "Aeon Disk"
EconPanel.item2price["item_kaya"] = 1950 -- "Kaya"
EconPanel.item2price["item_recipe_abyssal_blade"] = 1550 -- "Recipe: Abyssal Blade"
EconPanel.item2price["item_recipe_aeon_disk"] = 1350 -- "Recipe: Aeon Disk"
EconPanel.item2price["item_recipe_aether_lens"] = 600 -- "Recipe: Aether Lens"
EconPanel.item2price["item_recipe_armlet"] = 550 -- "Recipe: Armlet"
EconPanel.item2price["item_recipe_assault"] = 1300 -- "Recipe: Assault Cuirass"
EconPanel.item2price["item_recipe_black_king_bar"] = 1375 -- "Recipe: Black King Bar"
EconPanel.item2price["item_recipe_bloodthorn"] = 1000 -- "Recipe: Bloodthorn"
EconPanel.item2price["item_recipe_travel_boots"] = 2000 -- "Recipe: Travel Boots"
EconPanel.item2price["item_recipe_travel_boots_2"] = 2000 -- "Recipe: Travel Boots"
EconPanel.item2price["item_recipe_bracer"] = 165 -- "Recipe: Bracer"
EconPanel.item2price["item_recipe_buckler"] = 200 -- "Recipe: Buckler"
EconPanel.item2price["item_recipe_crimson_guard"] = 600 -- "Recipe: Crimson Guard"
EconPanel.item2price["item_recipe_lesser_crit"] = 500 -- "Recipe: Crystalys"
EconPanel.item2price["item_recipe_greater_crit"] = 1000 -- "Recipe: Daedalus"
EconPanel.item2price["item_recipe_dagon"] = 1250 -- "Recipe: Dagon"
EconPanel.item2price["item_recipe_dagon_2"] = 1250 -- "Recipe: Dagon"
EconPanel.item2price["item_recipe_dagon_3"] = 1250 -- "Recipe: Dagon"
EconPanel.item2price["item_recipe_dagon_4"] = 1250 -- "Recipe: Dagon"
EconPanel.item2price["item_recipe_dagon_5"] = 1250 -- "Recipe: Dagon"
EconPanel.item2price["item_recipe_diffusal_blade"] = 700 -- "Recipe: Diffusal Blade"
EconPanel.item2price["item_recipe_ancient_janggo"] = 575 -- "Recipe: Drum of Endurance"
EconPanel.item2price["item_recipe_cyclone"] = 650 -- "Recipe: Eul's Scepter of Divinity"
EconPanel.item2price["item_recipe_force_staff"] = 400 -- "Recipe: Force Staff"
EconPanel.item2price["item_recipe_guardian_greaves"] = 1700 -- "Recipe: Guardian Greaves"
EconPanel.item2price["item_recipe_hand_of_midas"] = 1650 -- "Recipe: Hand of Midas"
EconPanel.item2price["item_recipe_headdress"] = 300 -- "Recipe: Headdress"
EconPanel.item2price["item_recipe_kaya"] = 500 -- "Recipe: Kaya"
EconPanel.item2price["item_recipe_sphere"] = 1200 -- "Recipe: Linken's Sphere"
EconPanel.item2price["item_recipe_maelstrom"] = 700 -- "Recipe: Maelstrom"
EconPanel.item2price["item_recipe_manta"] = 900 -- "Recipe: Manta Style"
EconPanel.item2price["item_recipe_mekansm"] = 900 -- "Recipe: Mekansm"
EconPanel.item2price["item_recipe_mjollnir"] = 900 -- "Recipe: Mjollnir"
EconPanel.item2price["item_recipe_necronomicon"] = 1300 -- "Recipe: Necronomicon"
EconPanel.item2price["item_recipe_necronomicon_2"] = 1300 -- "Recipe: Necronomicon"
EconPanel.item2price["item_recipe_necronomicon_3"] = 1300 -- "Recipe: Necronomicon"
EconPanel.item2price["item_recipe_null_talisman"] = 165 -- "Recipe: Null Talisman"
EconPanel.item2price["item_recipe_orchid"] = 775 -- "Recipe: Orchid Malevolence"
EconPanel.item2price["item_recipe_null_talisman"] = 165 -- "Recipe: Null Talisman"
EconPanel.item2price["item_recipe_pipe"] = 800 -- "Recipe: Pipe of Insight"
EconPanel.item2price["item_recipe_radiance"] = 1350 -- "Recipe: Radiance"
EconPanel.item2price["item_recipe_refresher"] = 1800 -- "Recipe: Refresher Orb"
EconPanel.item2price["item_recipe_rod_of_atos"] = 1100 -- "Recipe: Rod of Atos"
EconPanel.item2price["item_recipe_sange"] = 500 -- "Recipe: Sange"
EconPanel.item2price["item_recipe_shivas_guard"] = 650 -- "Recipe: Shiva's Guard"
EconPanel.item2price["item_recipe_silver_edge"] = 700 -- "Recipe: Silver Edge"
EconPanel.item2price["item_recipe_basher"] = 1150 -- "Recipe: Skull Basher"
EconPanel.item2price["item_recipe_soul_ring"] = 200 -- "Recipe: Soul Ring"
EconPanel.item2price["item_recipe_spirit_vessel"] = 750 -- "Recipe: Spirit Vessel"
EconPanel.item2price["item_recipe_urn_of_shadows"] = 310 -- "Recipe: Urn of Shadows"
EconPanel.item2price["item_recipe_veil_of_discord"] = 500 -- "Recipe: Veil of Discord"
EconPanel.item2price["item_recipe_wraith_band"] = 165 -- "Recipe: Wraith Band"
EconPanel.item2price["item_recipe_yasha"] = 500 -- "Recipe: Yasha"

function EconPanel.OnUpdate()
	if Menu.IsEnabled(EconPanel.optionEnable) and Menu.IsKeyDownOnce(EconPanel.key) then
		EconPanel.isOpen = not EconPanel.isOpen
	end
end

local econTable = {} -- econTable = { {heroName_1, econValue_1}, {heroName_2, econValue_2}, ...}
local isSameTeamTable = {} -- isSameTeamTable[heroName] = True/False

function EconPanel.OnDraw()
	if not Menu.IsEnabled(EconPanel.optionEnable) or not EconPanel.isOpen then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end

	for i = 1, Heroes.Count() do
		local hero = Heroes.Get(i)
		if not NPC.IsIllusion(hero) then
			-- local heroName = EconPanel.heroes[NPC.GetUnitName(hero)]
			local heroName = NPC.GetUnitName(hero)
			isSameTeamTable[heroName] = Entity.IsSameTeam(myHero, hero)
			econTable[i] = {heroName, EconPanel.GetEcon(hero)}
		end
	end

	-- sort econTable by econValue in descending order
	table.sort(econTable, function(a, b) return a[2] > b[2] end)
	
	-- draw parameters
	local drawX = 10
	local drawY = 100
	local lineGap = 20
	local wordGap = 10
	local maxWidth = 200
	local maxGold = 1
	local rectHeight = lineGap - 1
	local heroIconWidth = math.floor(rectHeight * 128 / 72) -- original image is 128 * 72 (pixels)

	local myTeamEcon = 0
	local enemyTeamEcon = 0

	for i, v in ipairs(econTable) do
		local heroName = v[1]
		local econValue = v[2]
		maxGold = econValue >= maxGold and econValue or maxGold

		if isSameTeamTable[heroName] then
			Renderer.SetDrawColor(50, 205, 50, 200)
			myTeamEcon = myTeamEcon + econValue
		else
			Renderer.SetDrawColor(178, 34, 34, 200)
			enemyTeamEcon = enemyTeamEcon + econValue
		end

		drawY = drawY + lineGap
		-- draw bar
		local rectWidth = math.floor(maxWidth * econValue / maxGold)
		Renderer.DrawFilledRect(drawX, drawY, rectWidth, rectHeight)
		
		-- draw text
		local drawText = econValue -- .." - "..heroName
		Renderer.SetDrawColor(255, 215, 0, 255)
		Renderer.DrawText(EconPanel.font, drawX+heroIconWidth+wordGap, drawY, drawText, 1)

		-- draw hero icon
		local tmpHeroName = string.gsub(heroName, "npc_dota_hero_", "")
		local imageHandle
		if handlers[tmpHeroName] then -- need to cache image handlers, instead of calling LoadImage() evrytime
			imageHandle = handlers[tmpHeroName]
		else
			imageHandle = Renderer.LoadImage(EconPanel.heroIconPath .. tmpHeroName .. ".png")
			handlers[tmpHeroName] = imageHandle
		end
		Renderer.SetDrawColor(255, 255, 255, 255)
		Renderer.DrawImage(imageHandle, drawX, drawY, heroIconWidth, rectHeight)

	end

	local econDiff = myTeamEcon - enemyTeamEcon
	if econDiff > 0 then
		Renderer.SetDrawColor(50, 205, 50, 255)
	else
		Renderer.SetDrawColor(178, 34, 34, 255)
	end
	drawY = drawY - #econTable * lineGap
	Renderer.DrawText(EconPanel.font, drawX+wordGap, drawY, "Economic Worth: "..econDiff, 1)

	-- reallocate
	econTable = {}
end

-- does include gold of recipes
function EconPanel.GetEcon(hero)
	local totalEcon = 0
	local slotNum = 9
	for i = 0, slotNum-1 do
		myItem = NPC.GetItemByIndex(hero, i) -- index starts from 0
		if myItem then
			itemName = Ability.GetName(myItem)
			if EconPanel.item2price[itemName] then -- database includes all itemName, such as recipes.
				totalEcon = totalEcon + EconPanel.item2price[itemName]
			end
		end
	end
	
	return totalEcon
end

return EconPanel
