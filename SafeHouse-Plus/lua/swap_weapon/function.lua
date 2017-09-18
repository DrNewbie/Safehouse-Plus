_G.SafeHousePlus = _G.SafeHousePlus or {}

function MenuManager:open_safehouse_swapweapon_menu(params)
	params.start = params.start or 0
	local _txt = {}
	local opts = {}
	local start = params.start
	local _, _, _, weapon_list, _, _, _, _, _ = tweak_data.statistics:statistics_table()
	for k, weapon_name in pairs(weapon_list) do
		if k > start then
			opts[#opts+1] = { text = "" .. managers.localization:text(tweak_data.weapon[weapon_name].name_id), callback_func = callback(self, self, "open_safehouse_swapweapon_modattach_menu", {init = 1, thisone = weapon_name, start = 0}) }
		end
		if (#opts) >= 20 then
			start = k
			break
		end
	end
	opts[#opts+1] = { text = "[Next]--------------", callback_func = callback(self, self, "open_safehouse_swapweapon_menu", {start = start}) }
	opts[#opts+1] = { text = "[Back to Main]----", callback_func = callback(self, self, "open_safehouse_swapweapon_menu", {start = 0}) }
	opts[#opts+1] = { text = "[Cancel]", is_cancel_button = true }
	local _dialog_data = {
		title = "[ Pick weapon ]",
		text = "You know what you're doing, right?",
		button_list = opts,
		id = tostring(math.random(0,0xFFFFFFFF))
	}
	if managers.system_menu then
		managers.system_menu:show(_dialog_data)
	end
end

function MenuManager:open_safehouse_swapweapon_modattach_menu(params)
	local _tweak_data_factory = tweak_data.weapon.factory
	
	params.thisone = params.thisone or ""
	params.thismod = params.thismod or ""
	params.thisdata = params.thisdata or {}
	params.init = params.init or 0
	
	if params.thismod and params.thismod ~= "" then
		params.thisdata[params.thismod] = params.thisdata[params.thismod] or {}
		if params.thisdata[params.thismod].bool and params.thisdata[params.thismod].bool == true then
			params.thisdata[params.thismod].bool = false
		else
			params.thisdata[params.thismod].bool = true
		end
		local _used = {}
		for k, v in pairs(params.thisdata) do
			if k ~= params.thismod and params.thisdata[params.thismod].bool == true and _tweak_data_factory.parts[k].type == _tweak_data_factory.parts[params.thismod].type then
				params.thisdata[k].bool = false
			end
		end
	end

	params.start = params.start or 0
	if not params.thisone or params.thisone == "" then
		return		
	end
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(params.thisone)
	if not factory_id then
		return
	end	
	if params.init == 1 then
		local default_blueprint = _tweak_data_factory[factory_id].default_blueprint
		for k, part_name in pairs(default_blueprint) do		
			params.thisdata[part_name] = {bool = true}
		end
	end
	
	local start = params.start
	local parts_data = _tweak_data_factory[factory_id].uses_parts
	local opts = {}
	local _add = 0
	for k, part_name in pairs(parts_data) do
		local _this_part_data = _tweak_data_factory.parts[part_name]
		local _bool_this = params.thisdata[part_name] and params.thisdata[part_name].bool and "[O]" or "[X]"
		if k > start then
			_add = _add + 1
			opts[#opts+1] = { text = _bool_this .. " , " .. managers.localization:text(_this_part_data.name_id), callback_func = callback(self, self, "open_safehouse_swapweapon_modattach_menu", {thisone = params.thisone, thisdata = params.thisdata, thismod = part_name, start = start}) }
		end
		if (#opts) >= 20 then
			start = k
			break
		end
	end
	if _add < 20 then
		start = 0
	end
	opts[#opts+1] = { text = "[Next]--------------", callback_func = callback(self, self, "open_safehouse_swapweapon_modattach_menu", {thisone = params.thisone, thisdata = params.thisdata, start = start}) }
	opts[#opts+1] = { text = "[Craft]----", callback_func = callback(self, self, "open_safehouse_swapweapon_craft_menu", {thisone = params.thisone, thisdata = params.thisdata}) }
	opts[#opts+1] = { text = "[Cancel]", is_cancel_button = true }
	local _dialog_data = {
		title = "[ ".. managers.localization:text(tweak_data.weapon[params.thisone].name_id) .." ]",
		text = "You know what you're doing, right?",
		button_list = opts,
		id = tostring(math.random(0,0xFFFFFFFF))
	}
	if managers.system_menu then
		managers.system_menu:show(_dialog_data)
	end
end

function MenuManager:open_safehouse_swapweapon_craft_menu(params)
	local _tweak_data_factory = tweak_data.weapon.factory
	params.thisone = params.thisone or ""
	params.thisdata = params.thisdata or {}
	if params.thisone and params.thisone ~= "" and params.thisdata then
		local player_unit = managers.player:player_unit():inventory()
		if not player_unit then
			return
		end
		local _saved_data = {
			factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(params.thisone),
			blueprint = {}
		}
		for k, v in pairs(params.thisdata) do
			table.insert(_saved_data.blueprint, k)
		end
		local _c = player_unit:equipped_unit()
		if not _c then
			return
		end
		local use_data = _c:base():get_use_data("player")
		local _s = use_data.selection_index
		local _u = player_unit:unit_by_selection(_s)
		if _u then
			if _saved_data and _saved_data.factory_id then
				player_unit:remove_selection(_s, true)
				player_unit:add_unit_by_factory_name(_saved_data.factory_id, true, false, _saved_data.blueprint, nil, {})
				_u:set_slot(0)
				managers.player:player_unit():inventory():equipped_unit():base():set_ammo_total(0)
				managers.player:player_unit():inventory():equipped_unit():base():set_ammo_total(0)
				managers.player:player_unit():inventory():equipped_unit():base():set_ammo_remaining_in_clip(0)
				managers.player:player_unit():inventory():equipped_unit():base():set_ammo_remaining_in_clip(0)
			end
		end
	end
end