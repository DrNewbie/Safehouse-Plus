_G.SafeHousePlus = _G.SafeHousePlus or {}
local _missino_init_orig = MissionManager.init
function MissionManager:init(...)

	_missino_init_orig(self, ...)
	
	self.safehouse_training_unit_enemy = nil
	self.safehouse_training_unit_ammo = nil
	self.safehouse_training_unit_doctor = nil
	self.safehouse_training_unit_grenade = nil
	self.safehouse_training_type = 0
	self.safehouse_training_Init = 0
	
	CriminalsManager.MAX_NR_TEAM_AI = 1
	CriminalsManager.MAX_NR_CRIMINALS = 2
	
	SafeHousePlus:Load()

	SafeHousePlus.Vehicle_Loaded = false
	SafeHousePlus.Heavy_Loaded = false
	SafeHousePlus.Loot_Loaded = false
	
	if SafeHousePlus and SafeHousePlus.settings and 
		tweak_data and tweak_data.narrative and tweak_data.levels and PackageManager and
		PackageManager:loaded("packages/game_base_init") and
		Global.game_settings and Global.game_settings.level_id == "safehouse" then
		if SafeHousePlus.settings.vehicle_loaded == 1 then
			log("[SafeHousePlus] Vehicle Loaded")
			local _others_package = { "levels/narratives/bain/cage/world/world",
				"levels/narratives/vlad/shout/world/world",
				"levels/narratives/vlad/jolly/world/world",
				"levels/narratives/pbr/jerry/world/world",
				"levels/instances/unique/born/born_truck/world/world",
				"levels/narratives/elephant/born/world/world"
			}
			for _, _package in pairs(_others_package) do
				if not PackageManager:loaded(_package) then
					log("[SafeHousePlus] Loaded Package: " .. _package)
					PackageManager:load(_package)
				end
			end
			SafeHousePlus.Vehicle_Loaded = true
		end
		if SafeHousePlus.settings.heavy_loaded == 1 then
			log("[SafeHousePlus] Heavy Loaded")
			local _jobs_index = tweak_data.narrative._jobs_index or {}
			for _, v in pairs(_jobs_index) do
				if tweak_data.narrative.jobs[v] then
					local _package = tweak_data.narrative.jobs[v].package
					if _package then
						if not PackageManager:loaded(_package) then
							log("[SafeHousePlus] Loaded Package: " .. _package)
							PackageManager:load(_package)
						end
					end
				end
			end
			local _heavy_loaded_patch = {"packages/lvl_mad"}
			for _, _package in pairs(_heavy_loaded_patch) do
				if not PackageManager:loaded(_package) then
					log("[SafeHousePlus] Loaded Package: " .. _package)
					PackageManager:load(_package)
				end
			end
			SafeHousePlus.Heavy_Loaded = true
		end
		if SafeHousePlus.settings.loot_loaded == 1 then
			log("[SafeHousePlus] Loot Loaded")
			local _world_name = {
				"narratives/e_framing_frame/stage_1",
				"narratives/vlad/peta/stage1",
				"narratives/vlad/jewelry_store",
				"narratives/vlad/ukrainian_job",
				"narratives/bain/diamond_store",
				"narratives/dentist/mus",
				"narratives/bain/rat",
				"narratives/bain/shadow_raid",	
				"narratives/armadillo/arm_for",
				"narratives/h_firestarter/stage_3",
				"narratives/vlad/mallcrasher",
			}
			for _, v in pairs(_world_name) do
				v = "levels/".. v .."/world"
				if not PackageManager:loaded(v) then
					log("[SafeHousePlus] Loaded Package: " .. v)
					PackageManager:load(v)
				end
				v = v .."/world"
				if not PackageManager:loaded(v) then
					log("[SafeHousePlus] Loaded Package: " .. v)
					PackageManager:load(v)
				end
			end
			SafeHousePlus.Loot_Loaded = true
		end
	end
end

function MissionManager:Get_SafeHouse_Training_Init()
	return self.safehouse_training_Init
end

function MissionManager:Set_SafeHouse_Training_Init(_type)
	self.safehouse_training_Init = _type
end

function MissionManager:Get_SafeHouse_Training_Type()
	return self.safehouse_training_type
end

function MissionManager:Set_SafeHouse_Training_Type(_type)
	self.safehouse_training_type = _type
end

function MissionManager:Get_SafeHouse_Training_EnemyUnit()
	return self.safehouse_training_unit_enemy
end

function MissionManager:Set_SafeHouse_Training_EnemyUnit(_unit)
	self.safehouse_training_unit_enemy = _unit
end

function MissionManager:Get_SafeHouse_Training_AmmoUnit()
	return self.safehouse_training_unit_ammo
end

function MissionManager:Set_SafeHouse_Training_AmmoUnit(_unit)
	self.safehouse_training_unit_ammo = _unit
end

function MissionManager:Get_SafeHouse_Training_GrenadeUnit()
	return self.safehouse_training_unit_grenade
end

function MissionManager:Set_SafeHouse_Training_GrenadeUnit(_unit)
	self.safehouse_training_unit_grenade = _unit
end

function MissionManager:Get_SafeHouse_Training_DoctorUnit()
	return self.safehouse_training_unit_doctor
end

function MissionManager:Set_SafeHouse_Training_DoctorUnit(_unit)
	self.safehouse_training_unit_doctor = _unit
end