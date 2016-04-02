_G.SafeHousePlus = _G.SafeHousePlus or {}
SafeHousePlus.EnemyType = SafeHousePlus.EnemyType or "units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"
SafeHousePlus.AIType = SafeHousePlus.AIType or ""
SafeHousePlus.KillCounter = SafeHousePlus.KillCounter or 0
SafeHousePlus.KillCounterTime = SafeHousePlus.KillCounterTime or 0

local nowtime = function (type)
	return math.floor(TimerManager:game():time())
end

if RequiredScript == "lib/units/beings/player/states/playerstandard" then
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
						if _name == "@IDc46fb257fd602df6@" or _name == "@ID5a95fe805e753436@" then
							local _is_new_button = _pos == "Vector3(71, 4399, -283.52)" and false or true
							if _is_new_button then
								local _u = safe_spawn_unit(_unit:name(), _unit:position(), _unit:rotation()) or nil
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
							end
						end
					end
				end
			end
		end
		return _f3(self, t, input)
	end
end

if RequiredScript == "lib/units/enemies/cop/copdamage" then
	local _f4 = CopDamage._on_death
	function CopDamage:_on_death(...)
		if managers.job:current_level_id() == "safehouse" then
			local _type = managers.mission:Get_SafeHouse_Training_Type()
			if _type == 0 then
				SafeHousePlus:spawnsomething()
			elseif _type == 1 then
				SafeHousePlus.KillCounter = SafeHousePlus.KillCounter + 1
				if SafeHousePlus.KillCounter == 1 or not SafeHousePlus.KillCounterTime then
					SafeHousePlus.KillCounterTime = nowtime()
				end
				if SafeHousePlus.KillCounter >= 20 then
					local _total_time = nowtime() - SafeHousePlus.KillCounterTime
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
				end
			end
		end
		_f4(self, ...)	
	end
end

function SafeHousePlus:ResetKillCounter()
	SafeHousePlus.KillCounter = 0
	SafeHousePlus.KillCounterTime = 0
end

function SafeHousePlus:changetraning(type)
	managers.mission:Set_SafeHouse_Training_Type(type or 0)
end

function SafeHousePlus:spawnsomething(_pos)
	if SafeHousePlus.AIType then
		managers.groupai:state():remove_one_teamAI(SafeHousePlus.AIType)
		SafeHousePlus.AIType = ""
	end
	local _unit = managers.mission:Get_SafeHouse_Training_EnemyUnit()
	local _type = managers.mission:Get_SafeHouse_Training_Type()
	local pos = Vector3(-3923, 1113, 1)
	if _pos then pos = _pos end
	local _spawn = SafeHousePlus.EnemyType or "units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"
	if alive(_unit) then
		_unit:set_slot(0)
	end	
	_unit = safe_spawn_unit(Idstring(_spawn), pos, Vector3(0, 0, -0)) or nil
	if not _unit then
		return 
	end
	managers.mission:Set_SafeHouse_Training_EnemyUnit(_unit)
	local _access = _unit:base():char_tweak().access
	if _access == "civ_male" or _access == "civ_female" then
		_unit:movement():set_stance("hos", nil, true)
		_unit:interaction():set_tweak_data("hostage_move")
	else
		set_team(_unit, _unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")
		if SafeHousePlus.settings.no_attack == 1 then
			_unit:brain():set_active(false)
		end
	end
end

function SafeHousePlus:spawnsomeammo(_pos)
	local _unit = managers.mission:Get_SafeHouse_Training_AmmoUnit()
	local pos = Vector3(-3656, 2377, 3)
	if _pos then pos = _pos end
	if alive(_unit) then
		_unit:set_slot(0)
	end
	_unit = AmmoBagBase.spawn(pos, Vector3(0, 0, 0), 1)
	managers.mission:Set_SafeHouse_Training_AmmoUnit(_unit)
end

function SafeHousePlus:spawnsomegrenade(_pos)
	local _unit = managers.mission:Get_SafeHouse_Training_GrenadeUnit()
	local pos = Vector3(-3376, 2613, 91)
	if _pos then pos = _pos end
	if alive(_unit) then
		_unit:set_slot(0)
	end
	_unit = GrenadeCrateBase.spawn(pos, Vector3(0, 0, 0))
	managers.mission:Set_SafeHouse_Training_GrenadeUnit(_unit)
end

function SafeHousePlus:spawnsomedoctor(_pos)
	local _unit = managers.mission:Get_SafeHouse_Training_DoctorUnit()
	local pos = Vector3(-3432, 2748, 91)
	if _pos then pos = _pos end
	if alive(_unit) then
		_unit:set_slot(0)
	end
	_unit = DoctorBagBase.spawn(pos, Vector3(0, 0, 0), 1)
	managers.mission:Set_SafeHouse_Training_DoctorUnit(_unit)
end

function set_team(_unit, team)
	local AIState = managers.groupai:state()
	local team_id = tweak_data.levels:get_default_team_ID(team)
	_unit:movement():set_team(AIState:team_data(team_id))
end

function no_invisible_walls()
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
				unit:set_slot(0)
			end
		end  
	end
end

function isPlaying()
	if not BaseNetworkHandler then return false end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end

function SafeHousePlus:DoInit()
	if managers.mission and isPlaying() then
		local _is_init = managers.mission:Get_SafeHouse_Training_Init() or 0
		if not _is_init or _is_init <= 0 then
			managers.mission:Set_SafeHouse_Training_Init(1)
			local _u = nil
			local _new_button_pos = {Vector3(-3373, 4661, 131), Vector3(-3425, 2473, 114)}
			local _new_button_rot = {Rotation(90, 0, 90), Rotation(-180, 0, 90)}
			for i = 1 , 2 do
				if not _new_button_pos[i] or not _new_button_rot[i] then
					break
				end
				_u = safe_spawn_unit(Idstring("units/payday2/props/str_prop_com_security_keypad/str_prop_com_security_keypad"), _new_button_pos[i], _new_button_rot[i]) or nil
				if _u then
					_u:interaction():set_tweak_data("button_infopad")
					_u:interaction():set_active(true)
				end
			end
			no_invisible_walls()
			log("[SafeHousePlus] DoInit")
		end
	end
end