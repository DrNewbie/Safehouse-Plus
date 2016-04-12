local menu_id = "menu_safehouse_contract"

_G.SafeHousePlus = _G.SafeHousePlus or {}

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_SafeHouse", function(menu_manager, nodes)
	if nodes.lobby then
		MenuHelper:NewMenu( menu_id )
	end
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_SafeHouse", function(menu_manager, nodes)
	if nodes.lobby then
		MenuCallbackHandler.GetSafeHouseNow = function(self, item)
			create_job({ difficulty = item._priority, job_id = "safehouse" })
		end
		MenuHelper:AddButton({
			id = "safehouse_contract_ovk",
			title = "safehouse_contract_ovk_title",
			desc = "safehouse_contract_ovk_desc",
			callback = "GetSafeHouseNow",
			priority = "overkill_145",
			menu_id = menu_id,
		})
		MenuHelper:AddButton({
			id = "safehouse_contract_dw",
			title = "safehouse_contract_dw_title",
			desc = "safehouse_contract_dw_desc",
			callback = "GetSafeHouseNow",
			priority = "overkill_290",
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
    ["menu_safehouse_contract"] = "SafeHouse+",
    ["menu_safehouse_contract_name"] = "SafeHouse+",
    ["menu_safehouse_contract_desc"] = "Go to SafeHouse in other difficulty",
    ["safehouse_contract_ovk_title"] = "OVERKILL",
    ["safehouse_contract_ovk_desc"] = "Safe House in OVERKILL",
    ["safehouse_contract_dw_title"] = "DEATH WISH",
    ["safehouse_contract_dw_desc"] = "Safe House in DEATH WISH",	
  })
end)

function create_job(data)
	MenuCallbackHandler:start_job({job_id = data.job_id, difficulty = data.difficulty})
	Global.game_settings.permission = "friend"
end

function MenuManager:open_safehouse_menu()

	SafeHousePlus:DoInit()
	
	math.randomseed( os.time() )

	local opts = {}
	opts[#opts+1] = { text = "Spawn 'Bulldozer'", callback_func = callback(self, self, "select_safehouse_menu_spawn", {item = 1}) }
	opts[#opts+1] = { text = "Spawn 'Cloaker'", callback_func = callback(self, self, "select_safehouse_menu_spawn", {item = 2}) }
	opts[#opts+1] = { text = "Spawn 'Taser'", callback_func = callback(self, self, "select_safehouse_menu_spawn", {item = 3}) }
	
	opts[#opts+1] = { text = "Spawn 'COPS'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 1}) }
	opts[#opts+1] = { text = "Spawn 'FBI'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 2}) }
	opts[#opts+1] = { text = "Spawn 'SWATS'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 3}) }
	opts[#opts+1] = { text = "Spawn 'GANGS'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 4}) }
	opts[#opts+1] = { text = "Spawn 'CIVS'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 5}) }
	opts[#opts+1] = { text = "Spawn 'Russia'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 6}) }
	opts[#opts+1] = { text = "Spawn 'Vehicle'", callback_func = callback(self, self, "select_safehouse_adv_menu", {item = 7}) }
	opts[#opts+1] = { text = "Spawn 'PAYDAY GANG'", callback_func = callback(self, self, "select_safehouse_spawan_pdg_menu", {}) }
	
	opts[#opts+1] = { text = "Spawn 'Ammo & Health Bag'", callback_func = callback(self, self, "select_safehouse_menu_spawn", {item = 0}) }
	
	opts[#opts+1] = { text = "Play 'Quick Shooting'", callback_func = callback(self, self, "select_safehouse_menu_spawn", {item = 101}) }
	
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

function MenuManager:select_safehouse_adv_menu(params)
	if params.thisone then
		SafeHousePlus:changetraning(0)
		SafeHousePlus.EnemyType = params.units
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
	if params.item >= 1 and params.item <= 6 and not SafeHousePlus.Heavy_Loaded then
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
	elseif params.item == 7 then _select_list = _all_units.all_vehicle or {} end
	if not _select_list then return end
	local _txt = {}
	local opts = {}
	local start = params.start or 0
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
	managers.groupai:state():remove_one_teamAI(SafeHousePlus.AIType)
	SafeHousePlus.AIType = ""
	local character_name = params.name or managers.criminals:get_free_character_name()
	local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local unit_folder = lvl_tweak_data and lvl_tweak_data.unit_suit or "suit"
	local ai_character_id = managers.criminals:character_static_data_by_name(character_name).ai_character_id
	local unit_name = Idstring(tweak_data.blackmarket.characters[ai_character_id].npc_unit)
	local unit = World:spawn_unit(unit_name, Vector3(-3923, 1113, 1), Vector3(0, 0, -0))
	managers.network:session():send_to_peers_synched("set_unit", unit, character_name, "", 0, 0, tweak_data.levels:get_default_team_ID("player"))
	managers.criminals:add_character(character_name, unit, nil, true)
	unit:movement():set_character_anim_variables()
	unit:brain():set_spawn_ai({
		init_state = "idle",
		params = {scan = true},
		objective = objective
	})
	unit:brain():set_active(false)
	SafeHousePlus.AIType = character_name
	local _unit = managers.mission:Get_SafeHouse_Training_EnemyUnit()
	managers.mission:Set_SafeHouse_Training_EnemyUnit(nil)
	if alive(_unit) then
		_unit:set_slot(0)
	end	
end