local menu_id = "menu_safehouse_contract"

_G.SafeHousePlus = _G.SafeHousePlus or {}

	SafeHousePlus.ModPath = ModPath
	SafeHousePlus.SaveFile = SafeHousePlus.SaveFile or SavePath .. "SafeHousePlus.txt"
	SafeHousePlus.ModOptions = SafeHousePlus.ModPath .. "menus/modoptions.txt"
	SafeHousePlus.settings = SafeHousePlus.settings or {}
	SafeHousePlus.options_menu = "SafeHousePlus_menu"
	SafeHousePlus.settings = {
		no_attack = 1,
		heavy_loaded = 0,
		loot_loaded = 0,
		vehicle_loaded = 0,
		unit_tool = 0,
		friendly_enemy = 0,
		nogameover_before_timeup = 0,
		difficulty = 7,
		multi_type = 0,
		corpse_no_gone = 0,
		driving_test = 0,
		enable_self_damage = 0
	}
	SafeHousePlus.Difficulty = SafeHousePlus.Difficulty or "normal"

	Hooks:Add("LocalizationManagerPostInit", "SafeHousePlusReal_loc", function(loc)
		LocalizationManager:add_localized_strings({
			["safehouseplus_menu_title"] = "SafeHouse Plus",
			["safehouseplus_menu_desc"] = "",
			["safehouseplus_vehicle_loaded_menu_title"] = "Vehicle Loaded",
			["safehouseplus_vehicle_loaded_menu_desc"] = "It will load package of vehicles",
			["safehouseplus_heavy_loaded_menu_title"] = "Heavy Loaded",
			["safehouseplus_heavy_loaded_menu_desc"] = "Heavy Loaded will load tons of package to almost make sure you will not be albe to get crash when spawn something.",
			["safehouseplus_no_attack_menu_title"] = "Dummy Enemy",
			["safehouseplus_no_attack_menu_desc"] = "This will make enemy to be a dummy.",
			["safehouseplus_unit_tool_menu_title"] = "Unit Tool",
			["safehouseplus_unit_tool_menu_desc"] = "Unit Tool is main function of Customize your Safehouse",
			["safehouseplus_loot_loaded_menu_title"] = "Loot Loaded",
			["safehouseplus_loot_loaded_menu_desc"] = "You need to turn this ON when you want to use spawning loot function.",
			["safehouseplus_friendly_enemy_menu_title"] = "Friendly Enemy",
			["safehouseplus_friendly_enemy_menu_desc"] = "Convert enemy to your side",
			["safehouseplus_nogameover_before_timeup_menu_title"] = "No gameover before time up ",
			["safehouseplus_nogameover_before_timeup_menu_desc"] = "Spanw 1 AI so it will not gameover before time up after you down.",
			["safehouseplus_difficulty_menu_title"] = "Difficulty",
			["safehouseplus_difficulty_menu_desc"] = "Select your what difficulty you want to use.",
			["safehouseplus_multi_type_menu_title"] = "Multi-Type",
			["safehouseplus_multi_type_menu_desc"] = "Enable spawn different type enemy.",
			["safehouseplus_corpse_no_gone_menu_title"] = "Don't remove corpse",
			["safehouseplus_corpse_no_gone_menu_desc"] = "Enable = Don't remove corpse",
			["safehouseplus_driving_test_menu_title"] = "Practice Driving",
			["safehouseplus_driving_test_menu_desc"] = "Allow you to practice driving",
			["safehouseplus_enable_self_damage_menu_title"] = "Hurt Myself",
			["safehouseplus_enable_self_damage_menu_desc"] = "Boom",
		})
	end)

	function SafeHousePlus:Reset()
		self.settings = {
			no_attack = 1,
			heavy_loaded = 0,
			loot_loaded = 0,
			vehicle_loaded = 0,
			unit_tool = 0,
			friendly_enemy = 0,
			nogameover_before_timeout = 0,
			difficulty = 7,
			multi_type = 0,
			corpse_no_gone = 0,
			driving_test = 0,
			enable_self_damage = 0
		}
		self:Save()
	end

	function SafeHousePlus:Load()
		local file = io.open(self.SaveFile, "r")
		if file then
			for key, value in pairs(json.decode(file:read("*all"))) do
				self.settings[key] = value
			end
			file:close()
		else
			self:Reset()
		end
		self:Common_Refresh()
	end

	function SafeHousePlus:Save()
		local file = io.open(self.SaveFile, "w+")
		if file then
			file:write(json.encode(self.settings))
			file:close()
		end
		self:Common_Refresh()
	end
	
	function SafeHousePlus:Common_Refresh()
		local difficulties = {
			"normal",
			"hard",
			"overkill",
			"overkill_145",
			"easy_wish",
			"overkill_290",
			"sm_wish"
		}
		SafeHousePlus.Difficulty = difficulties[SafeHousePlus.settings.difficulty] or "normal"	
	end

	SafeHousePlus:Load()

	Hooks:Add("MenuManagerSetupCustomMenus", "SafeHousePlusOptions", function( menu_manager, nodes )
		MenuHelper:NewMenu( SafeHousePlus.options_menu )
	end)

	Hooks:Add("MenuManagerPopulateCustomMenus", "SafeHousePlusOptions", function( menu_manager, nodes )
		MenuCallbackHandler.SafeHousePlus_menu_UseWhat_callback = function(self, item)
			SafeHousePlus.settings.difficulty = item:value()
			SafeHousePlus:Save()
		end
		MenuHelper:AddMultipleChoice({
			id = "SafeHousePlus_menu_UseWhat_callback",
			title = "safehouseplus_difficulty_menu_title",
			desc = "safehouseplus_difficulty_menu_desc",
			callback = "SafeHousePlus_menu_UseWhat_callback",
			items = {"menu_difficulty_normal", "menu_difficulty_hard", "menu_difficulty_very_hard", "menu_difficulty_overkill", "menu_difficulty_easy_wish", "menu_difficulty_apocalypse", "menu_difficulty_sm_wish"},
			value = SafeHousePlus.settings.difficulty,
			menu_id = SafeHousePlus.options_menu,
		})
		MenuCallbackHandler.set_safehouseplus_vehicle_loaded_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.vehicle_loaded = 1
			else
				SafeHousePlus.settings.vehicle_loaded = 0
			end
			SafeHousePlus:Save()
		end
		local _bool = SafeHousePlus.settings.vehicle_loaded == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_vehicle_loaded_toggle_callback",
			title = "safehouseplus_vehicle_loaded_menu_title",
			desc = "safehouseplus_vehicle_loaded_menu_desc",
			callback = "set_safehouseplus_vehicle_loaded_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
		MenuCallbackHandler.set_safehouseplus_enable_self_damage_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.enable_self_damage = 1
			else
				SafeHousePlus.settings.enable_self_damage = 0
			end
			SafeHousePlus:Save()
		end
		_bool = SafeHousePlus.settings.enable_self_damage == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_enable_self_damage_toggle_callback",
			title = "safehouseplus_enable_self_damage_menu_title",
			desc = "safehouseplus_enable_self_damage_menu_desc",
			callback = "set_safehouseplus_enable_self_damage_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
		MenuCallbackHandler.set_safehouseplus_corpse_no_gone_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.corpse_no_gone = 1
			else
				SafeHousePlus.settings.corpse_no_gone = 0
			end
			SafeHousePlus:Save()
		end
		_bool = SafeHousePlus.settings.corpse_no_gone == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_corpse_no_gone_toggle_callback",
			title = "safehouseplus_corpse_no_gone_menu_title",
			desc = "safehouseplus_corpse_no_gone_menu_desc",
			callback = "set_safehouseplus_corpse_no_gone_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
		MenuCallbackHandler.set_safehouseplus_driving_test_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.driving_test = 1
			else
				SafeHousePlus.settings.driving_test = 0
			end
			SafeHousePlus:Save()
		end
		_bool = SafeHousePlus.settings.driving_test == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_driving_test_toggle_callback",
			title = "safehouseplus_driving_test_menu_title",
			desc = "safehouseplus_driving_test_menu_desc",
			callback = "set_safehouseplus_driving_test_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
		MenuCallbackHandler.set_safehouseplus_multi_type_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.multi_type = 1
			else
				SafeHousePlus.settings.multi_type = 0
			end
			SafeHousePlus:Save()
		end
		_bool = SafeHousePlus.settings.multi_type == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_multi_type_toggle_callback",
			title = "safehouseplus_multi_type_menu_title",
			desc = "safehouseplus_multi_type_menu_desc",
			callback = "set_safehouseplus_multi_type_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
		MenuCallbackHandler.set_safehouseplus_nogameover_before_timeup_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.nogameover_before_timeup = 1
			else
				SafeHousePlus.settings.nogameover_before_timeup = 0
			end
			SafeHousePlus:Save()
		end
		_bool = SafeHousePlus.settings.nogameover_before_timeup == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_nogameover_before_timeup_toggle_callback",
			title = "safehouseplus_nogameover_before_timeup_menu_title",
			desc = "safehouseplus_nogameover_before_timeup_menu_desc",
			callback = "set_safehouseplus_nogameover_before_timeup_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
		MenuCallbackHandler.set_safehouseplus_friendly_enemy_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.friendly_enemy = 1
			else
				SafeHousePlus.settings.friendly_enemy = 0
			end
			SafeHousePlus:Save()
		end
		_bool = SafeHousePlus.settings.friendly_enemy == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_friendly_enemy_toggle_callback",
			title = "safehouseplus_friendly_enemy_menu_title",
			desc = "safehouseplus_friendly_enemy_menu_desc",
			callback = "set_safehouseplus_friendly_enemy_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
		MenuCallbackHandler.set_safehouseplus_loot_loaded_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.loot_loaded = 1
			else
				SafeHousePlus.settings.loot_loaded = 0
			end
			SafeHousePlus:Save()
		end
		_bool = SafeHousePlus.settings.loot_loaded == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_loot_loaded_toggle_callback",
			title = "safehouseplus_loot_loaded_menu_title",
			desc = "safehouseplus_loot_loaded_menu_desc",
			callback = "set_safehouseplus_loot_loaded_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
		MenuCallbackHandler.set_safehouseplus_heavy_loaded_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.heavy_loaded = 1
			else
				SafeHousePlus.settings.heavy_loaded = 0
			end
			SafeHousePlus:Save()
		end
		_bool = SafeHousePlus.settings.heavy_loaded == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_heavy_loaded_toggle_callback",
			title = "safehouseplus_heavy_loaded_menu_title",
			desc = "safehouseplus_heavy_loaded_menu_desc",
			callback = "set_safehouseplus_heavy_loaded_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
		MenuCallbackHandler.set_safehouseplus_no_attack_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.no_attack = 1
			else
				SafeHousePlus.settings.no_attack = 0
			end
			SafeHousePlus:Save()
		end
		_bool = SafeHousePlus.settings.no_attack == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_no_attack_toggle_callback",
			title = "safehouseplus_no_attack_menu_title",
			desc = "safehouseplus_no_attack_menu_desc",
			callback = "set_safehouseplus_no_attack_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
		MenuCallbackHandler.set_safehouseplus_unit_tool_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.unit_tool = 1
			else
				SafeHousePlus.settings.unit_tool = 0
			end
			SafeHousePlus:Save()
		end
		_bool = SafeHousePlus.settings.unit_tool == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_unit_tool_toggle_callback",
			title = "safehouseplus_unit_tool_menu_title",
			desc = "safehouseplus_unit_tool_menu_desc",
			callback = "set_safehouseplus_unit_tool_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
	end)

	Hooks:Add("MenuManagerBuildCustomMenus", "SafeHousePlusOptions", function(menu_manager, nodes)
		nodes[SafeHousePlus.options_menu] = MenuHelper:BuildMenu( SafeHousePlus.options_menu )
		MenuHelper:AddMenuItem( MenuHelper.menus.lua_mod_options_menu, SafeHousePlus.options_menu, "safehouseplus_menu_title", "safehouseplus_menu_desc")
	end)
	
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_SafeHouse", function(menu_manager, nodes)
	if nodes.lobby then
		MenuHelper:NewMenu( menu_id )
	end
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_SafeHouse", function(menu_manager, nodes)
	if nodes.lobby then
		MenuCallbackHandler.GetSafeHouseNow = function(self, item)
			MenuCallbackHandler:play_single_player()
			MenuCallbackHandler:start_single_player_job({job_id = "chill", difficulty = SafeHousePlus.Difficulty})
		end
		MenuHelper:AddButton({
			id = "GetSafeHouseNow",
			title = "menu_safehouse_contract_name",
			desc = "menu_safehouse_contract_desc",
			callback = "GetSafeHouseNow",
			menu_id = menu_id,
		})
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_SafeHouse", function(menu_manager, nodes)
	if nodes.lobby then
		nodes[menu_id] = MenuHelper:BuildMenu( menu_id )
		MenuHelper:AddMenuItem( nodes.lobby, menu_id, "menu_safehouse_contract_name", "menu_safehouse_contract_desc" )
	end
end)

Hooks:Add("LocalizationManagerPostInit", "SafeHouse_loc", function(loc)
	LocalizationManager:add_localized_strings({
		["menu_safehouse_contract"] = "SafeHouse Plus",
		["menu_safehouse_contract_name"] = "SafeHouse Plus",
		["menu_safehouse_contract_desc"] = "Go to SafeHouse in other difficulty",
	})
end)