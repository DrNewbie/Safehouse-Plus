_G.SafeHousePlus = _G.SafeHousePlus or {}

	SafeHousePlus.ModPath = ModPath
	SafeHousePlus.SaveFile = SafeHousePlus.SaveFile or SavePath .. "SafeHousePlus.txt"
	SafeHousePlus.ModOptions = SafeHousePlus.ModPath .. "menus/modoptions.txt"
	SafeHousePlus.settings = SafeHousePlus.settings or {}
	SafeHousePlus.options_menu = "SafeHousePlus_menu"

	Hooks:Add("LocalizationManagerPostInit", "SafeHousePlus_loc", function(loc)
		LocalizationManager:add_localized_strings({
			["safehouseplus_menu_title"] = "SafeHouse Plus",
			["safehouseplus_menu_desc"] = "",
			["safehouseplus_vehicle_loaded_menu_title"] = "Vehicle Loaded",
			["safehouseplus_vehicle_loaded_menu_desc"] = "It will load package of vehicles",
			["safehouseplus_heavy_loaded_menu_title"] = "Heavy Loaded",
			["safehouseplus_heavy_loaded_menu_desc"] = "Heavy Loaded will load tons of package to almost make sure you will not be albe to get crash when spawn something.",
			["safehouseplus_no_attack_menu_title"] = "Dummy Enemy",
			["safehouseplus_no_attack_menu_desc"] = "This will make enemy to be a dummy.",
			["safehouseplus_no_unit_tool_menu_title"] = "Unit Tool",
			["safehouseplus_no_unit_tool_menu_desc"] = "Unit Tool is main function of Customize your Safehouse",
		})
	end)

	function SafeHousePlus:Reset()
		self.settings = {
			heavy_loaded = 1,
			vehicle_loaded = 1,
			no_attack = 1,
			unit_tool = 1,
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
	end

	function SafeHousePlus:Save()
		local file = io.open(self.SaveFile, "w+")
		if file then
			file:write(json.encode(self.settings))
			file:close()
		end
	end

	SafeHousePlus:Load()

	Hooks:Add("MenuManagerSetupCustomMenus", "SafeHousePlusOptions", function( menu_manager, nodes )
		MenuHelper:NewMenu( SafeHousePlus.options_menu )
	end)

	Hooks:Add("MenuManagerPopulateCustomMenus", "SafeHousePlusOptions", function( menu_manager, nodes )
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
		
		MenuCallbackHandler.set_safehouseplus_heavy_loaded_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.heavy_loaded = 1
			else
				SafeHousePlus.settings.heavy_loaded = 0
			end
			SafeHousePlus:Save()
		end
		local _bool = SafeHousePlus.settings.heavy_loaded == 1 and true or false
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
		MenuCallbackHandler.set_safehouseplus_no_unit_tool_toggle_callback = function(self, item)
			if tostring(item:value()) == "on" then
				SafeHousePlus.settings.unit_tool = 1
			else
				SafeHousePlus.settings.unit_tool = 0
			end
			SafeHousePlus:Save()
		end
		_bool = SafeHousePlus.settings.unit_tool == 1 and true or false
		MenuHelper:AddToggle({
			id = "set_safehouseplus_no_unit_tool_toggle_callback",
			title = "safehouseplus_no_unit_tool_menu_title",
			desc = "safehouseplus_no_unit_tool_menu_desc",
			callback = "set_safehouseplus_no_unit_tool_toggle_callback",
			value = _bool,
			menu_id = SafeHousePlus.options_menu,
		})
	end)

	Hooks:Add("MenuManagerBuildCustomMenus", "SafeHousePlusOptions", function(menu_manager, nodes)
		nodes[SafeHousePlus.options_menu] = MenuHelper:BuildMenu( SafeHousePlus.options_menu )
		MenuHelper:AddMenuItem( MenuHelper.menus.lua_mod_options_menu, SafeHousePlus.options_menu, "safehouseplus_menu_title", "safehouseplus_menu_desc", 1 )
	end)