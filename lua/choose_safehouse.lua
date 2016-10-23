local menu_id = "menu_safehouse_contract"

_G.SafeHousePlus = _G.SafeHousePlus or {}
_G.SC = _G.SC or {}
_G.DW = _G.DW or {}

function MenuManager:open_safehouse_menu()

	SafeHousePlus:DoInit()
	
	math.randomseed( os.time() )

	local opts = {}
	opts[#opts+1] = { text = "Spawn 'Common'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 9}) }
	opts[#opts+1] = { text = "Spawn 'COPS'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 1}) }
	opts[#opts+1] = { text = "Spawn 'FBI'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 2}) }
	opts[#opts+1] = { text = "Spawn 'SWATS'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 3}) }
	opts[#opts+1] = { text = "Spawn 'GANGS'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 4}) }
	opts[#opts+1] = { text = "Spawn 'CIVS'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 5}) }
	opts[#opts+1] = { text = "Spawn 'Russia'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 6}) }
	opts[#opts+1] = { text = "Spawn 'Vehicle'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 7}) }
	opts[#opts+1] = { text = "Spawn 'Others'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 8}) }
	opts[#opts+1] = { text = "Spawn 'PAYDAY GANG'", callback_func = callback(self, self, "select_safehouse_spawan_pdg_menu", {}) }
	opts[#opts+1] = { text = "Spawn 'Ammo & Health Bag'", callback_func = callback(self, self, "select_safehouse_menu_spawn", {item = 0}) }
	if SC and SC.Hooks then
		opts[#opts+1] = { text = "Spawn 'SC'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 10}) }	
	end
	if DW and DW.Hooks then
		opts[#opts+1] = { text = "Spawn 'DW Plus'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 11}) }	
	end
	if SafeHousePlus.settings.driving_test == 1 then
		opts[#opts+1] = { text = "Play 'Practice Driving'", callback_func = callback(self, self, "select_safehouse_menu_driving_test", {}) }
	end
	--opts[#opts+1] = { text = "Play 'Quick Shooting'", callback_func = callback(self, self, "select_safehouse_menu_spawn", {item = 101}) }
	
	if SafeHousePlus.settings.unit_tool == 1 then
		opts[#opts+1] = { text = "Unit Tool", callback_func = callback(self, self, "select_Unit_Tool_main", {}) }
	end	
	
	opts[#opts+1] = { text = "[Cancel]", is_cancel_button = true }
	local _dialog_data = {
		title = "[List]",
		text = "Choose what you want.",
		button_list = opts,
		id = tostring(math.random(0,0xFFFFFFFF))
	}
	if managers.system_menu then
		managers.system_menu:show(_dialog_data)
	end
end

function mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

function MenuManager:select_safehouse_menu_driving_test()
	local _default = "units/pd2_dlc_shoutout_raid/vehicles/fps_vehicle_muscle_1/fps_vehicle_muscle_1"
	SafeHousePlus.EnemyType = SafeHousePlus.EnemyType or _default
	if not tostring(SafeHousePlus.EnemyType):find("vehicles") then
		SafeHousePlus.EnemyType = _default
	end
	SafeHousePlus:spawnsomething(Vector3(-425, 1150, 1050))
	managers.player:warp_to(Vector3(-85, 1000, 1050), Rotation(0, 0, 0))
end

function MenuManager:select_safehouse_adv_menu(params)
	params.thisone = params.thisone or false
	params.item = params.item or 0
	params.start = params.start or 0
	params.units = params.units or ""
	if params.thisone then
		if SafeHousePlus.settings.multi_type == 1 then
			local _txt_array = mysplit(params.units, "/")
			local _idx = _txt_array[#_txt_array]
			if SafeHousePlus.EnemyType_Multi[_idx] then
				if SafeHousePlus.EnemyType_Multi[_idx].unit and alive(SafeHousePlus.EnemyType_Multi[_idx].unit) then
					SafeHousePlus.EnemyType_Multi[_idx].unit:set_slot(0)
				end
			end
			SafeHousePlus.EnemyType_Multi[_idx] = {unit = nil, enable = true, unit_name = params.units}
		end
		SafeHousePlus.EnemyType = params.units
		SafeHousePlus:changetraning(0)
		SafeHousePlus:spawnsomething()
		SafeHousePlus:spawnsomeammo()
		SafeHousePlus:spawnsomedoctor()
		SafeHousePlus:spawnsomegrenade()
		return
	end
	if params.item == 7 and not SafeHousePlus.Vehicle_Loaded then
		local _dialog_data = {
			title = "[Warning]",
			text = "Required 'Vehicle Loaded', please turn it on and restart the game.",
			button_list = {{ text = "OK", is_cancel_button = true }},
			id = tostring(math.random(0,0xFFFFFFFF))
		}
		managers.system_menu:show(_dialog_data)
		return
	end
	if ((params.item >= 1 and params.item <= 6) or params.item == 8) and not SafeHousePlus.Heavy_Loaded then
		local _dialog_data = {
			title = "[Warning]",
			text = "Required 'Heavy Loaded', please turn it on and restart the game.",
			button_list = {{ text = "OK", is_cancel_button = true }},
			id = tostring(math.random(0,0xFFFFFFFF))
		}
		managers.system_menu:show(_dialog_data)
		return
	end
	local _all_units = SafeHousePlus:AllHumanUnits()
	if not _all_units then return end
	local _select_list = {}
	if params.item == 1 then _select_list = _all_units.all_cops or {} 
	elseif params.item == 2 then _select_list = _all_units.all_fbi or {} 
	elseif params.item == 3 then _select_list = _all_units.all_swats or {} 
	elseif params.item == 4 then _select_list = _all_units.all_gangs or {}
	elseif params.item == 5 then _select_list = _all_units.all_civs or {}
	elseif params.item == 6 then _select_list = _all_units.all_russia or {}
	elseif params.item == 7 then _select_list = _all_units.all_vehicle or {}
	elseif params.item == 8 then _select_list = _all_units.all_others or {}
	elseif params.item == 9 then _select_list = _all_units.all_common or {}
	elseif params.item == 10 then _select_list = _all_units.all_sc_mod or {}
	elseif params.item == 11 then _select_list = _all_units.all_dw_plus or {} end
	if not _select_list or table.size(_select_list) == 0 then return end
	
	local _txt = {}
	local opts = {}
	local start = params.start
	start = start >= 0 and start or 0
	for k, v in pairs(_select_list) do
		if k > start then
			_txt = mysplit(v, "/")
			opts[#opts+1] = { text = "" .. tostring(_txt[#_txt]), callback_func = callback(self, self, "select_safehouse_adv_menu", {units = v, thisone = true}) }
		end
		if (#opts) >= 10 then
			start = k
			break
		end
	end
	opts[#opts+1] = { text = "[Next]--------------", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = params.item, start = start}) }
	opts[#opts+1] = { text = "[Back to Main]----", callback_func = callback(self, self, "open_safehouse_menu", {}) }
	opts[#opts+1] = { text = "[Cancel]", is_cancel_button = true }
	local _dialog_data = {
		title = "!! Warning !!",
		text = "Some of units will make your game crash.",
		button_list = opts,
		id = tostring(math.random(0,0xFFFFFFFF))
	}
	if managers.system_menu then
		managers.system_menu:show(_dialog_data)
	end
end

function MenuManager:select_safehouse_menu_spawn(params)
	if params.item ~= 0 then
		if params.item == 101 then
			SafeHousePlus.EnemyType = "units/payday2/characters/ene_sniper_2/ene_sniper_2"
			SafeHousePlus:changetraning(1)
			SafeHousePlus:ResetKillCounter()
			SafeHousePlus:spawnsomething(Vector3(-3247, 5506, 1))			
			SafeHousePlus:spawnsomeammo(Vector3(-3180, 4840, 1))
			SafeHousePlus:spawnsomedoctor(Vector3(-3650, 4905, 1))
			SafeHousePlus:spawnsomegrenade(Vector3(-4005, 4955, 1))
			managers.player:warp_to(Vector3(-3247, 5506, 1), Vector3(0, 0, 0))
			local _dialog_data = { 
				title = "[Quick Shooting]",
				text = "Kill 20 enemies as soon as possible",
				button_list = {{ text = "OK", is_cancel_button = true }},
				id = tostring(math.random(0,0xFFFFFFFF))
			}
			managers.system_menu:show(_dialog_data)
			return
		else
			SafeHousePlus:changetraning(0)
			local enmylist = {
				"units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3",
				"units/payday2/characters/ene_spook_1/ene_spook_1",
				"units/payday2/characters/ene_tazer_1/ene_tazer_1"
			}
			SafeHousePlus.EnemyType = enmylist[params.item]
			SafeHousePlus:spawnsomething()
		end
	end
	SafeHousePlus:spawnsomeammo()
	SafeHousePlus:spawnsomedoctor()
	SafeHousePlus:spawnsomegrenade()
end

function MenuManager:select_safehouse_spawan_pdg_menu(params)
	local opts = {}
	local free_paydaygang = managers.criminals:get_all_free_character_name() or {}
	for _, name in pairs(free_paydaygang) do
		opts[#opts+1] = { text = "Spawn '".. name .."'", callback_func = callback(self, self, "select_safehouse_spawan_pdg", {name = name}) }
	end
	opts[#opts+1] = { text = "[Back to Main]----", callback_func = callback(self, self, "open_safehouse_menu", {}) }
	opts[#opts+1] = { text = "[Cancel]", is_cancel_button = true }
	local _dialog_data = {
		title = "[List]",
		text = "Choose what you want.",
		button_list = opts,
		id = tostring(math.random(0,0xFFFFFFFF))
	}
	if managers.system_menu then
		managers.system_menu:show(_dialog_data)
	end
end

function MenuManager:select_safehouse_spawan_pdg(params)
	SafeHousePlus:Spawn_One_AI(params)
end

function MenuManager:open_safehouse_menu_carry(params)

	if not SafeHousePlus.Carry_list then
		SafeHousePlus.Carry_list = {}
		for k, v in pairs(SafeHousePlus:CarryandProp() or {}) do
			if not SafeHousePlus.Carry_list[k] then
				table.insert(SafeHousePlus.Carry_list, {name = v.name, unit_name = v.unit_name})
			end
		end
		for _, name in pairs(CarryTweakData:get_carry_ids() or {}) do
			if tweak_data.carry[name].unit then
				if not SafeHousePlus.Carry_list[name] then
					table.insert(SafeHousePlus.Carry_list, {name = name, unit_name = tweak_data.carry[name].unit})
				end
			end
		end
	end
	
	local id = 0
	local opts = {}
	local start = params.start or 0
	start = start >= 0 and start or 0
	for k, v in pairs(SafeHousePlus.Carry_list) do
		id = id + 1
		if id > start then
			opts[#opts+1] = { text = "".. v.name .."", callback_func = callback(self, self, "select_safehouse_menu_carry", {key = k, unit_name = v.unit_name}) }
		end
		if (#opts) >= 15 then
			start = id
			break
		end
	end
	opts[#opts+1] = { text = "[Next]--------------", callback_func = callback(self, self, "open_safehouse_menu_carry", {start = start}) }
	opts[#opts+1] = { text = "[Back to Main]----", callback_func = callback(self, self, "open_safehouse_menu_carry", {start = 0}) }
	opts[#opts+1] = { text = "[Cancel]", is_cancel_button = true }
	local _dialog_data = {
		title = "!! Warning !!",
		text = "Some of units will make your game crash.",
		button_list = opts,
		id = tostring(math.random(0,0xFFFFFFFF))
	}
	if managers.system_menu then
		managers.system_menu:show(_dialog_data)
	end
end

SafeHousePlus.Carry_Unit = nil

function MenuManager:select_safehouse_menu_carry(params)
	if alive(SafeHousePlus.Carry_Unit) then
		SafeHousePlus.Carry_Unit:set_slot(0)
	end
	if not SafeHousePlus.Loot_Loaded then
		local _dialog_data = {
			title = "[Warning]",
			text = "Required 'Loot Loaded', please turn it on and restart the game.",
			button_list = {{ text = "OK", is_cancel_button = true }},
			id = tostring(math.random(0,0xFFFFFFFF))
		}
		managers.system_menu:show(_dialog_data)	
	else
		if params.unit_name and params.unit_name ~= "" then
			SafeHousePlus.Carry_Unit = World:spawn_unit(Idstring(params.unit_name), SafeHousePlus.Spawn_Location.Loot.pos, Vector3(0, 0, 0))
			if SafeHousePlus.Carry_Unit and SafeHousePlus.Carry_Unit:interaction() then
				SafeHousePlus.Carry_Unit:interaction():set_active(false, false)
			end
		else
			table.remove(SafeHousePlus.Carry_list, params.key)
		end
	end
end