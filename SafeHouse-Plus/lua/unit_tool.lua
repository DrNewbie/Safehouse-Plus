_G.SafeHousePlus = _G.SafeHousePlus or {}

if SafeHousePlus.settings.unit_tool == 0 then
	return
end

SafeHousePlus.Unit_Tool_Modify_History = {}
SafeHousePlus.Unit_Tool_Spawner_setting = {}
SafeHousePlus.Unit_Tool_Remover_Last_Did_Name = nil
SafeHousePlus.Unit_Tool_Remover = false
SafeHousePlus.Unit_Tool_Spawner = false
SafeHousePlus.Unit_Tool_Position = false
SafeHousePlus.Unit_Tool_Position_Type = 0
SafeHousePlus.Unit_Tool_Rotation = false
SafeHousePlus.Unit_Tool_Rotation_Type = 0
SafeHousePlus.Unit_Tool_World_find_units_quick = {}
SafeHousePlus.Unit_Tool_Spawn_Remove_List = {}

if not SafeHousePlus.UnitToolSpawnerList then
	SafeHousePlus.UnitToolSpawnerList = {}
	local _select_path_list = {}
	_select_path_list[#_select_path_list+1] = "safehouse_default.txt"
	SafeHousePlus.UnitToolSpawnerList = _select_path_list
	_select_path_list = {}
end

function idstring_lookup()
	local result = {}
	if( DB:has( "idstring_lookup", "idstring_lookup" ) ) then
		local file = DB:open( "idstring_lookup", "idstring_lookup" )
		local data = file:read()   
		for _,text in pairs( string.split( data, '%z' ) ) do
			local key = text:id():key()
			key = key:lower()
			result[key] = text
		end
		file:close()
	end 
	return result
end

SafeHousePlus.Unit_Tool_Key_Init_List = idstring_lookup()

function MenuManager:select_Unit_Tool_main(params)
	local opts = {}
	opts[#opts+1] = { text = "Unit Tool - 'Remover' [".. (SafeHousePlus.Unit_Tool_Remover == true and "ON" or "OFF") .."]", callback_func = callback(self, self, "select_Unit_Tool_Remover_onoff", {}) }
	opts[#opts+1] = { text = "Unit Tool - 'Spawner' [".. (SafeHousePlus.Unit_Tool_Spawner == true and "ON" or "OFF") .."]", callback_func = callback(self, self, "select_Unit_Tool_Spawner_onoff", {}) }
	
	opts[#opts+1] = { text = "Unit Tool - 'Position' [".. (SafeHousePlus.Unit_Tool_Position == true and "ON" or "OFF") .."]", callback_func = callback(self, self, "select_Unit_Tool_Pos_Rot_onoff", {bool = "pos"}) }
	opts[#opts+1] = { text = "Unit Tool - 'Rotation' [".. (SafeHousePlus.Unit_Tool_Rotation == true and "ON" or "OFF") .."]", callback_func = callback(self, self, "select_Unit_Tool_Pos_Rot_onoff", {bool = "rot"}) }
	
	opts[#opts+1] = { text = "Unit Tool - 'Save'", callback_func = callback(self, self, "select_Unit_Tool_save", {}) }
	opts[#opts+1] = { text = "Unit Tool - 'Load'", callback_func = callback(self, self, "select_Unit_Tool_load", {}) }

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

function MenuManager:select_Unit_Tool_save()
	local _history = SafeHousePlus.Unit_Tool_Modify_History or {}
	local file = io.open("mods/SafeHouse-Plus/UnitToolSave/save.txt", "w")
	if file and _history then
		file:write(json.encode(_history))
		file:close()
		managers.hud:show_hint({ text = "Unit Tool - Saved" })
	end
end

function MenuManager:select_Unit_Tool_load()
	managers.hud:show_hint( { text = "Now loading..." } )
	SafeHousePlus.Unit_Tool_Modify_History = {}
	local _list = {}
	local _list_final = {}
	local _txt = ""
	local _txt_list = {}
	local file = io.open("mods/SafeHouse-Plus/UnitToolSave/save.txt", "r")
	if file then
		_list_final = json.decode(file:read("*all")) or {}
		file:close()
	end
	for k, v in pairs(_list_final) do
		_list_final[k] = {type = v.type, key = v.key, pos = v.pos:ToVector3(), rot = Rotation(v.rot[1], v.rot[2], v.rot[3])}
	end
	SafeHousePlus.Unit_Tool_Spawn_Remove_List = _list_final
	
	local _select_path_list = SafeHousePlus.UnitToolSpawnerList or {}
	local _select_name_list = {}
	for _, name in pairs(_select_path_list) do
		local file = io.open("mods/SafeHouse-Plus/UnitToolSpawnerList/" .. name, "r")
		if file then
			local line = file:read()
			while line do
				_txt = tostring(line)
				_txt_list = mysplit(_txt, ",")
				_select_name_list[#_select_name_list+1] = tostring(_txt_list[1])
				line = file:read()
			end
			file:close()
		end
	end
	
	DelayedCalls:Add("Delayed2spawn_from_list", 1, function()
		_spawn_from_list()
	end)
end

function _spawn_from_list()
	local _times = 5
	local _key_init_list = SafeHousePlus.Unit_Tool_Key_Init_List or {}
	local _list_final = SafeHousePlus.Unit_Tool_Spawn_Remove_List
	SafeHousePlus.Unit_Tool_Remove_List_Total = 0
	for key, data in pairs(_list_final) do
		if data.type == "spawn" and _key_init_list[data.key] then
			local _name = Idstring(_key_init_list[data.key])
			if _name then
				local _u = safe_spawn_unit(_name, data.pos, data.rot)
				SafeHousePlus:Unit_Tool_History_record(_u, "spawn")
				_times = _times - 1
				SafeHousePlus.Unit_Tool_Spawn_Remove_List[key] = {key = "", pos = nil, rot = nil}
				SafeHousePlus.Unit_Tool_Spawn_Remove_List[key] = {}
				if _times <= 0 then
					break
				end
			end
		else
			SafeHousePlus.Unit_Tool_Remove_List_Total = SafeHousePlus.Unit_Tool_Remove_List_Total + 1
		end
	end
	if _times <= 0 then
		managers.hud:show_hint( { text = "Now loading..." } )
		DelayedCalls:Add("Delayed2spawn_from_list", 1, function()
			_spawn_from_list()
		end)
	else
		DelayedCalls:Add("Delayed2remove_from_list", 1, function()
			_remove_from_list()
		end)
	end
	return
end

function _remove_from_list()
	local _list_final = SafeHousePlus.Unit_Tool_Spawn_Remove_List or {}
	local _remove_list = {}
	local _times = 10
	for _, data in pairs(_list_final) do
		if data.type == "remove" then
			for _, unit in pairs(World:find_units_quick("all", 1)) do
				if unit then
					local keyA = tostring(unit:name():key())
					local _posA, _rotA = get_xyz_yawpitchroll(unit)				
					local keyB = tostring(data.key)
					local _x = math.floor(data.pos.x)
					local _y = math.floor(data.pos.y)
					local _z = math.floor(data.pos.z)
					local _yaw = math.floor(data.rot:yaw())
					local _pitch = math.floor(data.rot:pitch())
					local _roll = math.floor(data.rot:roll())
					local _posB = _x .. "," .. _y .. "," .. _z
					local _rotB = _yaw .. "," .. _pitch .. "," .. _roll
					_rotA = _rotA:gsub("-0", "0")
					_rotB = _rotB:gsub("-0", "0")
					if keyA == keyB and _posA == _posB and _rotA == _rotB then
						SafeHousePlus:Unit_Tool_History_record(unit, "remove")
						managers.network:session():send_to_peers_synched( "remove_unit", unit )
						unit:set_slot(0)
						_times = _times - 1
						SafeHousePlus.Unit_Tool_Remove_List_Total = SafeHousePlus.Unit_Tool_Remove_List_Total - 1
						break
					end
					if _times <= 0 then
						break
					end
				end
			end
		end
		if _times <= 0 then
			break
		end
	end
	if _times <= 0 then
		managers.hud:show_hint( { text = "Now loading... [Left: ".. SafeHousePlus.Unit_Tool_Remove_List_Total .."]" } )
		DelayedCalls:Add("Delayed2remove_from_list", 1, function()
			_remove_from_list()
		end)
	else
		SafeHousePlus.Unit_Tool_Remove_List_Total = 0
		SafeHousePlus.Unit_Tool_World_find_units_quick = {}
		SafeHousePlus.Unit_Tool_Spawn_Remove_List = {}
		managers.hud:show_hint( { text = "Complete!!" } )
	end
end

function SafeHousePlus:Unit_Tool_History_record(_unit, _type)
	if _unit then
		local _list = SafeHousePlus.Unit_Tool_Modify_History or {}
		local _pos, _rot = _unit:position(), _unit:rotation()
		if not SafeHousePlus:UnitTool_IsBlocked(tostring(_unit:name():key())) then
			SafeHousePlus.Unit_Tool_Modify_History[#_list+1] = {type = _type, key = _unit:name():key(), pos = _pos:ToString(), rot = {_rot:yaw(), _rot:pitch(), _rot:roll()}}
		end
		log("[Unit Tool]: {".. tostring(_unit) .."},{".. _type .."}")
	end
	return
end

function SafeHousePlus:Empty(var)
	for i = 1, var do
		if true then
			local no = false
		end
	end
	return
end

function get_xyz_yawpitchroll(_unit)
	if _unit then
		local _x = math.floor(_unit:position().x)
		local _y = math.floor(_unit:position().y)
		local _z = math.floor(_unit:position().z)
		local _yaw = math.floor(_unit:rotation():yaw())
		local _pitch = math.floor(_unit:rotation():pitch())
		local _roll = math.floor(_unit:rotation():roll())
		local _pos = _x .. "," .. _y .. "," .. _z
		local _rot = _yaw .. "," .. _pitch .. "," .. _roll
		return _pos, _rot
	end
	return
end

function MenuManager:select_Unit_Tool_Pos_Rot_onoff(params)
	SafeHousePlus.Unit_Tool_Spawner_setting = {}
	SafeHousePlus.Unit_Tool_Remover_Last_Did_Name = nil
	SafeHousePlus.Unit_Tool_Remover = false
	SafeHousePlus.Unit_Tool_Spawner = false
	SafeHousePlus.Unit_Tool_Position = false
	SafeHousePlus.Unit_Tool_Position_Type = 0
	SafeHousePlus.Unit_Tool_Rotation = false
	SafeHousePlus.Unit_Tool_Rotation_Type = 0
	
	local opts = {}
	opts[#opts+1] = { text = "+a", callback_func = callback(self, self, "select_Unit_Tool_Pos_Rot_Setting", {_type = 1, bool = params.bool}) }
	opts[#opts+1] = { text = "-a", callback_func = callback(self, self, "select_Unit_Tool_Pos_Rot_Setting", {_type = 2, bool = params.bool}) }
	opts[#opts+1] = { text = "+b", callback_func = callback(self, self, "select_Unit_Tool_Pos_Rot_Setting", {_type = 3, bool = params.bool}) }
	opts[#opts+1] = { text = "-b", callback_func = callback(self, self, "select_Unit_Tool_Pos_Rot_Setting", {_type = 4, bool = params.bool}) }
	opts[#opts+1] = { text = "+c", callback_func = callback(self, self, "select_Unit_Tool_Pos_Rot_Setting", {_type = 5, bool = params.bool}) }
	opts[#opts+1] = { text = "-c", callback_func = callback(self, self, "select_Unit_Tool_Pos_Rot_Setting", {_type = 6, bool = params.bool}) }
	
	opts[#opts+1] = { text = "[Cancel]", is_cancel_button = true }
	local _dialog_data = {
		title = "[List]",
		text = "Position(a, b, c)",
		button_list = opts,
		id = tostring(math.random(0,0xFFFFFFFF))
	}
	if params.bool == "rot" then
		_dialog_data.text = "Rotation(a, b, c)"
	end
	if managers.system_menu then
		managers.system_menu:show(_dialog_data)
	end
end

function MenuManager:select_Unit_Tool_Pos_Rot_Setting(params)
	local _l = {"+a", "-a", "+b", "-b", "+c", "-c"}
	if params.bool == "rot" then
		SafeHousePlus.Unit_Tool_Rotation = true
		SafeHousePlus.Unit_Tool_Rotation_Type = params._type
		managers.hud:show_hint( { text = "'Unit Tool - Rotation ".. _l[params._type] .."' ON" } )
	else
		SafeHousePlus.Unit_Tool_Position = true
		SafeHousePlus.Unit_Tool_Position_Type = params._type
		managers.hud:show_hint( { text = "'Unit Tool - Position ".. _l[params._type] .."' ON" } )
	end
end

function MenuManager:select_Unit_Tool_Remover_onoff(params)
	SafeHousePlus.Unit_Tool_Remover = SafeHousePlus.Unit_Tool_Remover == false and true or false
	if SafeHousePlus.Unit_Tool_Remover then
		managers.hud:show_hint( { text = "'Unit Tool - Remover' ON" } )
	else
		managers.hud:show_hint( { text = "'Unit Tool - Remover' OFF" } )
	end
	SafeHousePlus.Unit_Tool_Spawner = false
	SafeHousePlus.Unit_Tool_Spawner_setting = {}
	SafeHousePlus.Unit_Tool_Position = false
	SafeHousePlus.Unit_Tool_Position_Type = 0
	SafeHousePlus.Unit_Tool_Rotation = false
	SafeHousePlus.Unit_Tool_Rotation_Type = 0
end

function MenuManager:select_Unit_Tool_Spawner_onoff(params)

	if params.bool == 2 then
		SafeHousePlus.Unit_Tool_Spawner = true
		managers.hud:show_hint( { text = "'Unit Tool - Spawner' ON" } )
	elseif params.bool == 1 then
		SafeHousePlus.Unit_Tool_Spawner = false
		managers.hud:show_hint( { text = "'Unit Tool - Spawner' OFF" } )
	end
	
	local _select_list = SafeHousePlus.UnitToolSpawnerList or {}
	
	if not _select_list then return end
	local opts = {}
	
	if SafeHousePlus.Unit_Tool_Remover_Last_Did_Name then
		opts[#opts+1] = { text = "USE LAST ONE", callback_func = callback(self, self, "select_Unit_Tool_Spawner_setting", {name = SafeHousePlus.Unit_Tool_Remover_Last_Did_Name}) }
	end
	
	opts[#opts+1] = {text = ""}
	
	local start = params.start or 0
	local _txt = {}
	start = start >= 0 and start or 0
	for k, _date in pairs(_select_list) do
		if k > start and _date then
			opts[#opts+1] = { text = "" .. _date, callback_func = callback(self, self, "select_Unit_Tool_Spawner_read_file", {name = _date}) }
		end
		if (#opts) >= 17 then
			start = k
			break
		end
	end
	
	opts[#opts+1] = { text = "[OFF]", callback_func = callback(self, self, "select_Unit_Tool_Spawner_onoff", {bool = 1}) }
	opts[#opts+1] = { text = "[ON]", callback_func = callback(self, self, "select_Unit_Tool_Spawner_onoff", {bool = 2}) }
	opts[#opts+1] = { text = "[Next]----------------------------", callback_func = callback(self, self, "select_Unit_Tool_Spawner_onoff", {start = start}) }
	opts[#opts+1] = { text = "[Back to Main]---------------", callback_func = callback(self, self, "select_Unit_Tool_Spawner_onoff", {}) }
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

function MenuManager:select_Unit_Tool_Spawner_read_file(params)
	if not params or not params.name then
		return
	end	
	local file = io.open("mods/SafeHouse-Plus/UnitToolSpawnerList/" .. params.name, "r")
	local _select_list = {}
	if file then
		local line = file:read()
		while line do
			_select_list[#_select_list+1] = tostring(line)
			line = file:read()
		end
		file:close()
	end
	if not _select_list then
		return
	end
	local opts = {}	
	local start = params.start or 0
	local _txt = {}
	local _txt_name = {}
	start = start >= 0 and start or 0
	for k, _date in pairs(_select_list) do
		if k > start and _date then
			_txt = mysplit(_date, ",")
			if _txt[2] and _txt[2] ~= "" then
				_txt_name = {_txt[2]}
			else
				_txt_name = mysplit(_txt[1], "/")
			end
			opts[#opts+1] = { text = "" .._txt_name[#_txt_name], callback_func = callback(self, self, "select_Unit_Tool_Spawner_setting", {name = Idstring(_txt[1])}) }
		end
		if (#opts) >= 17 then
			start = k
			break
		end
	end
	
	opts[#opts+1] = { text = "[OFF]", callback_func = callback(self, self, "select_Unit_Tool_Spawner_onoff", {bool = 1}) }
	opts[#opts+1] = { text = "[ON]", callback_func = callback(self, self, "select_Unit_Tool_Spawner_onoff", {bool = 2}) }
	opts[#opts+1] = { text = "[Next]----------------------------", callback_func = callback(self, self, "select_Unit_Tool_Spawner_read_file", {name = params.name, start = start}) }
	opts[#opts+1] = { text = "[Back to Main]---------------", callback_func = callback(self, self, "select_Unit_Tool_Spawner_onoff", {}) }
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

function MenuManager:select_Unit_Tool_Spawner_setting(params)
	SafeHousePlus.Unit_Tool_Spawner_setting = {name = params.name}
	SafeHousePlus.Unit_Tool_Spawner = true
	managers.hud:show_hint( { text = "'Unit Tool - Spawner' ON" } )
	SafeHousePlus.Unit_Tool_Remover = false
	SafeHousePlus.Unit_Tool_Position = false
	SafeHousePlus.Unit_Tool_Position_Type = 0
	SafeHousePlus.Unit_Tool_Rotation = false
	SafeHousePlus.Unit_Tool_Rotation_Type = 0
end

function SafeHousePlus:select_unit_tool_menu(params)
	if params then
		if SafeHousePlus.Unit_Tool_Remover and params.unit then
			if not SafeHousePlus:UnitTool_IsBlocked(tostring(params.unit:name():key())) then
				SafeHousePlus:Unit_Tool_History_record(params.unit, "remove")
				managers.hud:show_hint( { text = "Removed" } )
				SafeHousePlus.Unit_Tool_Remover_Last_Did_Name = params.unit:name()
				params.unit:set_slot(0)
			else
				managers.hud:show_hint( { text = "Blocked" } )
			end
		end
		if SafeHousePlus.Unit_Tool_Spawner then
			managers.hud:show_hint( { text = "Spawned" } )
			local _setting = SafeHousePlus.Unit_Tool_Spawner_setting or {}
			if _setting and _setting.name then
				local _pos = _setting.position or params.position
				local _rot = _setting.rotation or Rotation(0, 0, 0)
				local _u = safe_spawn_unit(_setting.name, _pos, _rot)
				if SafeHousePlus:UnitTool_IsBlocked(tostring(_u:name():key())) then
					_u:set_slot(0)
				else
					SafeHousePlus:Unit_Tool_History_record(_u, "spawn")
				end
			end
		end
		if (SafeHousePlus.Unit_Tool_Rotation or SafeHousePlus.Unit_Tool_Position) and params.unit then
			if SafeHousePlus:UnitTool_IsBlocked(tostring(params.unit:name():key())) then
				return
			end
			local _l2 = {"+a", "-a", "+b", "-b", "+c", "-c"}
			local _pos = params.unit:position()
			local _rot = {params.unit:rotation():yaw(), params.unit:rotation():pitch(), params.unit:rotation():roll()}
			local _rot_final = params.unit:rotation()
			if SafeHousePlus.Unit_Tool_Rotation then
				local _type = SafeHousePlus.Unit_Tool_Rotation_Type
				local _l = {{5, 0, 0}, {-5, 0, 0}, {0, 5, 0}, {0, -5, 0}, {0, 0, 5}, {0, 0, -5}}
				local _rotfix = _l[_type]
				_rot[1] = math.floor(_rot[1] + _rotfix[1])
				_rot[2] = math.floor(_rot[2] + _rotfix[2])
				_rot[3] = math.floor(_rot[3] + _rotfix[3])
				managers.hud:show_hint( { text = "Rotation ".. _l2[_type] .." Change" } )
				_rot_final = Rotation(_rot[1], _rot[2], _rot[3])
			end
			if SafeHousePlus.Unit_Tool_Position then
				local _type = SafeHousePlus.Unit_Tool_Position_Type
				local _l = {Vector3(5, 0, 0), Vector3(-5, 0, 0), Vector3(0, 5, 0), Vector3(0, -5, 0), Vector3(0, 0, 5), Vector3(0, 0, -5)}
				local _posfix = _l[_type]
				_pos = _pos + _posfix
				managers.hud:show_hint( { text = "Position ".. _l2[_type] .." Change" } )
			end
			SafeHousePlus:Unit_Tool_History_record(params.unit, "remove")
			local _u = safe_spawn_unit(params.unit:name(), _pos, _rot_final)
			SafeHousePlus:Unit_Tool_History_record(_u, "spawn")
			params.unit:set_slot(0)
		end
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