_G.SafeHousePlus = _G.SafeHousePlus or {}
SafeHousePlus.EnemyType = SafeHousePlus.EnemyType or "units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"
SafeHousePlus.AIType = SafeHousePlus.AIType or ""
SafeHousePlus.KillCounter = SafeHousePlus.KillCounter or 0
SafeHousePlus.KillCounterTime = SafeHousePlus.KillCounterTime or 0

SafeHousePlus.Button_Name = Idstring("units/pd2_dlc_chill/props/chl_prop_tape_recorder/chl_prop_tape_recorder")
SafeHousePlus.Button_tweak_Name = "press_play_jacket_sound"

SafeHousePlus.Spawn_Location = {
	["Human"] = {pos = Vector3(-790, 1720, -2), rot = Rotation(180, 0, 0)},
	["Alone_Human"] = {pos = Vector3(-320, 555, 2), rot = Rotation(0, 0, 0)},
	["Vehicles"] = {pos = Vector3(-700, 1240, -2)},
	["Grenade_case"] = {pos = Vector3(-240, 1055, -2)},
	["Doctor_bag"] = {pos = Vector3(-140, 955, -2)},
	["Ammo_bag"] = {pos = Vector3(-140, 1055, -2)},
	["Button_Outside_Spawn"] = {pos = Vector3(-275, 820, 150), rot = Rotation(90, 0, 90)},
	["Button_Inside_Spawn_Loot"] = {pos = Vector3(790, 1300, 550), rot = Rotation(180, 0, 90)},
	["Button_Inside_Other_1"] = {pos = Vector3(1880, 10, 550), rot = Rotation(90, 0, 90)},
	["Loot"] = {pos = Vector3(570, 1280, 450)},
}

SafeHousePlus.Nowtime = function ()
	return math.floor(TimerManager:game():time())
end

if RequiredScript == "lib/units/beings/player/states/playerstandard" then
	Hooks:PreHook(PlayerStandard, "_check_action_interact", "PlayerStandard_check_action_interact_PreHook", function(ply, t, input)
		if managers.job:current_level_id() ~= "chill" then
			return
		end
		local new_action, timer, interact_object
		local interaction_wanted = input.btn_interact_press
		if not interaction_wanted then
			return
		end
		local action_forbidden = ply:chk_action_forbidden("interact") or ply._unit:base():stats_screen_visible() or ply:_interacting() or ply._ext_movement:has_carry_restriction() or ply:is_deploying() or ply:_changing_weapon() or ply:_is_throwing_projectile() or ply:_is_meleeing() or ply:_on_zipline()
		if action_forbidden then
			return
		end
		new_action, timer, interact_object = managers.interaction:interact(ply._unit)
		if not interact_object then
			return
		end
		local _unit = interact_object:interaction()._unit or nil
		local _unit_name = tostring(_unit:name():t()) or ""
		local _unit_pos = tostring(_unit:position()) or ""
		if _unit_name ~= "@ID5f6c0dde29227cd1@" then
			return
		end
		local _type = 0 
		if _unit_pos == tostring(SafeHousePlus.Spawn_Location.Button_Outside_Spawn.pos) then
			_type = 1
		elseif _unit_pos == tostring(SafeHousePlus.Spawn_Location.Button_Inside_Spawn_Loot.pos) then
			_type = 2
		elseif _unit_pos == tostring(SafeHousePlus.Spawn_Location.Button_Inside_Other_1.pos) then
			_type = 3
		end
		if _type == 0 then
			return
		end
		local _new_unit = safe_spawn_unit(SafeHousePlus.Button_Name, _unit:position(), _unit:rotation()) or nil
		if _new_unit and alive(_new_unit) then
			_new_unit:interaction():set_tweak_data(SafeHousePlus.Button_tweak_Name)
			_new_unit:interaction():set_active(true, false)
			_unit:set_slot(0)
			if _type == 1 then
				managers.menu:open_safehouse_menu()
			elseif _type == 2 then
				managers.menu:open_safehouse_menu_carry({start = 0})
			elseif _type == 3 then
				MenuCallbackHandler:leave_safehouse()
			end
		end
	end )
	--[[
	local _f3 = PlayerStandard._check_action_interact
	function PlayerStandard:_check_action_interact(t, input)
		if managers.job:current_level_id() == "safehouse" then
			local new_action, timer, interact_object
			local interaction_wanted = input.btn_interact_press
			if interaction_wanted then
				local action_forbidden = self:chk_action_forbidden("interact") or self._unit:base():stats_screen_visible() or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_on_zipline()
				if not action_forbidden then
					new_action, timer, interact_object = managers.interaction:interact(self._unit)
					if interact_object then
						local _unit = interact_object:interaction()._unit or {}
						local _name = tostring(_unit:name():t()) or ""
						local _pos = tostring(_unit:position()) or ""
						if _name == "@ID495f44b22c85b737@" then
							local _is_new_button = _pos == "Vector3(71, 4399, -283.52)" and false or true
							if _is_new_button then
								local _u = safe_spawn_unit(, _unit:position(), _unit:rotation()) or nil
								if not _u then
									return 
								end
								_u:interaction():set_tweak_data("button_infopad")
								_u:interaction():set_active(true, false)
								_unit:set_slot(0)
							end
							if _pos == "Vector3(71, 4399, -283.52)" or _pos == "Vector3(-3425, 2473, 114)" then
								if managers.menu then
									managers.menu:open_safehouse_menu()
								end
								return
							elseif _pos == "Vector3(-3373, 4661, 131)" then
								SafeHousePlus:ResetKillCounter()			
								managers.player:warp_to(Vector3(-21, 4363, -397), Vector3(0, 0, 0))
								local _dialog_data = { 
									title = "[Quick Shooting]",
									text = "You cancel this game.",
									button_list = {{ text = "OK", is_cancel_button = true }},
									id = tostring(math.random(0,0xFFFFFFFF))
								}
								managers.system_menu:show(_dialog_data)
								return
							elseif _pos == "Vector3(-2375, 2838, 135)" then
								managers.menu:open_safehouse_menu_carry({start = 0})
							end
						end
					end
				end
			end
		end
		return _f3(self, t, input)
	end
	]]
end

if RequiredScript == "lib/units/enemies/cop/copdamage" then
	Hooks:PostHook(CopDamage, "_on_death", "CopDamage_on_death_PostHook", function(cop, ...)
		if managers.job:current_level_id() ~= "chill" or managers.mission:Get_SafeHouse_Training_Init() <= 0 then
			return
		end
		local _type = managers.mission:Get_SafeHouse_Training_Type()
		if _type == 0 then
			SafeHousePlus:spawnsomething()
		--[[elseif _type == 1 then
			SafeHousePlus.KillCounter = SafeHousePlus.KillCounter + 1
			if SafeHousePlus.KillCounter == 1 or not SafeHousePlus.KillCounterTime then
				SafeHousePlus.KillCounterTime = SafeHousePlus.Nowtime()
			end
			if SafeHousePlus.KillCounter >= 20 then
				local _total_time = SafeHousePlus.Nowtime() - SafeHousePlus.KillCounterTime
				SafeHousePlus:ResetKillCounter()			
				managers.player:warp_to(Vector3(-21, 4363, -397), Vector3(0, 0, 0))
				local _dialog_data = { 
					title = "[Quick Shooting]",
					text = "Time : '".. _total_time .."'s",
					button_list = {{ text = "OK", is_cancel_button = true }},
					id = tostring(math.random(0,0xFFFFFFFF))
				}
				managers.system_menu:show(_dialog_data)
			else
				local _x = math.random(1860, 4152) * (-1)
				local _y = math.random(4710, 6496)
				local _pos = Vector3(_x, _y, 3)
				SafeHousePlus:spawnsomething(_pos)
			end]]
		end
	end )
end

function SafeHousePlus:ResetKillCounter()
	SafeHousePlus.KillCounter = 0
	SafeHousePlus.KillCounterTime = 0
end

function SafeHousePlus:changetraning(_type)
	managers.mission:Set_SafeHouse_Training_Type(_type or 0)
end

function SafeHousePlus:spawnsomething(_pos)
	if SafeHousePlus.AIType then
		managers.groupai:state():remove_one_teamAI(SafeHousePlus.AIType)
		SafeHousePlus.AIType = ""
	end
	local _unit = managers.mission:Get_SafeHouse_Training_EnemyUnit()
	local pos = SafeHousePlus.Spawn_Location.Human.pos
	if _pos then pos = _pos end
	local _spawn = SafeHousePlus.EnemyType or "units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"
	local _is_vehicle = _spawn:find("vehicles") and true or false
	if alive(_unit) then
		_unit:set_slot(0)
	end	
	if _is_vehicle then
		pos = SafeHousePlus.Spawn_Location.Vehicles.pos
	end	
	if not _is_vehicle and not _spawn:find("characters") then
		log("[SafeHousePlus] Error, spawnsomething, _spawn: " .. tostring(_spawn))
	end
	_unit = safe_spawn_unit(Idstring(_spawn), pos, SafeHousePlus.Spawn_Location.Human.rot) or nil
	if not _unit then
		return 
	end
	managers.mission:Set_SafeHouse_Training_EnemyUnit(_unit)
	if not _is_vehicle then
		local _access = _unit:base():char_tweak().access
		if _access == "civ_male" or _access == "civ_female" then
			_unit:movement():set_stance("hos", nil, true)
			_unit:interaction():set_tweak_data("hostage_move")
		else
			local _team = _unit:base():char_tweak().access == "gangster" and "gangster" or "combatant"
			local _team_id = tweak_data.levels:get_default_team_ID(_team)
			_unit:movement():set_team(managers.groupai:state():team_data(_team_id))			
			if SafeHousePlus.settings.no_attack == 1 then
				_unit:brain():set_active(false)
			end
			if SafeHousePlus.settings.friendly_enemy == 1 then
				managers.groupai:state():convert_hostage_to_criminal(_unit)
				managers.groupai:state():sync_converted_enemy(_unit)
				_unit:contour():add("friendly")
			end
		end
	end
end

function SafeHousePlus:spawnsomeammo(_pos)
	local _unit = managers.mission:Get_SafeHouse_Training_AmmoUnit()
	local pos = SafeHousePlus.Spawn_Location.Grenade_case.pos
	if _pos then pos = _pos end
	if alive(_unit) then
		_unit:set_slot(0)
	end
	_unit = AmmoBagBase.spawn(pos, Rotation(0, 0, 0), 1)
	managers.mission:Set_SafeHouse_Training_AmmoUnit(_unit)
end

function SafeHousePlus:spawnsomegrenade(_pos)
	local _unit = managers.mission:Get_SafeHouse_Training_GrenadeUnit()
	local pos = SafeHousePlus.Spawn_Location.Ammo_bag.pos
	if _pos then pos = _pos end
	if alive(_unit) then
		_unit:set_slot(0)
	end
	_unit = GrenadeCrateBase.spawn(pos, Rotation(0, 0, 0))
	managers.mission:Set_SafeHouse_Training_GrenadeUnit(_unit)
end

function SafeHousePlus:spawnsomedoctor(_pos)
	local _unit = managers.mission:Get_SafeHouse_Training_DoctorUnit()
	local pos = SafeHousePlus.Spawn_Location.Doctor_bag.pos
	if _pos then pos = _pos end
	if alive(_unit) then
		_unit:set_slot(0)
	end
	_unit = DoctorBagBase.spawn(pos, Rotation(0, 0, 0), 1)
	managers.mission:Set_SafeHouse_Training_DoctorUnit(_unit)
end

function SafeHousePlus:DoInit()
	if managers.mission then
		local _is_init = managers.mission:Get_SafeHouse_Training_Init() or 0
		if not _is_init or _is_init <= 0 then
			managers.mission:Set_SafeHouse_Training_Init(1)
			local _u = nil
			local _u_pos = SafeHousePlus.Spawn_Location.Button_Outside_Spawn.pos
			local _u_rot = SafeHousePlus.Spawn_Location.Button_Outside_Spawn.rot
			_u = safe_spawn_unit(SafeHousePlus.Button_Name, _u_pos, _u_rot) or nil
			if _u and alive(_u) then
				_u:interaction():set_tweak_data(SafeHousePlus.Button_tweak_Name)
				_u:interaction():set_active(true, false)
			end
			_u_pos = SafeHousePlus.Spawn_Location.Button_Inside_Spawn_Loot.pos
			_u_rot = SafeHousePlus.Spawn_Location.Button_Inside_Spawn_Loot.rot
			_u = safe_spawn_unit(SafeHousePlus.Button_Name, _u_pos, _u_rot) or nil
			if _u and alive(_u) then
				_u:interaction():set_tweak_data(SafeHousePlus.Button_tweak_Name)
				_u:interaction():set_active(true, false)
			end
			_u_pos = SafeHousePlus.Spawn_Location.Button_Inside_Other_1.pos
			_u_rot = SafeHousePlus.Spawn_Location.Button_Inside_Other_1.rot
			_u = safe_spawn_unit(SafeHousePlus.Button_Name, _u_pos, _u_rot) or nil
			if _u and alive(_u) then
				_u:interaction():set_tweak_data(SafeHousePlus.Button_tweak_Name)
				_u:interaction():set_active(true, false)
			end			
			local managers = managers
			local M_network = managers.network
			local net_session = M_network:session()

			if net_session then		
				local send_to_peers = net_session.send_to_peers
				-- No invisible walls by Harfatus
				local CollisionData = {
					["673ea142d68175df"] = true,
					["86efb80bf784046f"] = true,
					["b37a4188fde4c161"] = true,
					["7ae8fcbfe6a00f7b"] = true,
					["c5c4442c5e147cb0"] = true,
					["8f3cb89b79b42ec4"] = true,
					["e8fe662bb4d262d3"] = true,
					["9d8b22836aa015ed"] = true,
					["63be2c801283f573"] = true,
					["78f4407343b48f6d"] = true,
					["29d0139549a54de7"] = true,
					["e379cc9592197cd8"] = true,
					["7a4c85917d8d8323"] = true,
					["9eda9e73ac0ef710"] = true,
					["276de19dc5541f30"] = true,
					["6cdb4f6f58ec4fa8"] = true
				}
				for _, unit in pairs(World:find_units_quick("all", 1)) do
					if CollisionData[unit:name():key()] then
						send_to_peers(net_session, 'remove_unit', unit)
						_unit:set_slot(0)
					end
				end  
			end
			if SafeHousePlus.settings.nogameover_before_timeup == 1 then
				SafeHousePlus:Spawn_One_AI({alone = 1})
			end
			log("[SafeHousePlus] DoInit")
		end
	end
end

function SafeHousePlus:Spawn_One_AI(params)
	params.alone = params.alone or 0
	managers.groupai:state():remove_one_teamAI(SafeHousePlus.AIType)
	if params.alone == 0 then
		SafeHousePlus.AIType = ""
	end
	local _pos = SafeHousePlus.Spawn_Location.Human.pos
	if params.alone == 1 then
		_pos = SafeHousePlus.Spawn_Location.Alone_Human.pos
	end
	local character_name = params.name or managers.criminals:get_free_character_name()
	local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local unit_folder = lvl_tweak_data and lvl_tweak_data.unit_suit or "suit"
	local ai_character_id = managers.criminals:character_static_data_by_name(character_name).ai_character_id
	local unit_name = Idstring(tweak_data.blackmarket.characters[ai_character_id].npc_unit)
	local unit = World:spawn_unit(unit_name, _pos, SafeHousePlus.Spawn_Location.Human.rot)
	managers.network:session():send_to_peers_synched("set_unit", unit, character_name, "", 0, 0, tweak_data.levels:get_default_team_ID("player"))
	managers.criminals:add_character(character_name, unit, nil, true)
	unit:movement():set_character_anim_variables()
	unit:brain():set_spawn_ai({
		init_state = "idle",
		params = {scan = true},
		objective = objective
	})
	if SafeHousePlus.settings.no_attack == 1 or params.alone == 1 then
		unit:brain():set_active(false)
	else
		unit:brain():set_active(true)
	end
	if params.alone == 0 then
		SafeHousePlus.AIType = character_name
		local _unit = managers.mission:Get_SafeHouse_Training_EnemyUnit()
		managers.mission:Set_SafeHouse_Training_EnemyUnit(nil)
		if alive(_unit) then
			_unit:set_slot(0)
		end
	end
end