core:module("CoreMissionScriptElement")
core:import("CoreXml")
core:import("CoreCode")
core:import("CoreClass")
MissionScriptElement = MissionScriptElement or class()

_G.SafeHousePlus = _G.SafeHousePlus or {}
SafeHousePlus = _G.SafeHousePlus
SafeHousePlus._tmp = SafeHousePlus._tmp or {}

local _MissionScriptElement_on_executed = MissionScriptElement.on_executed

function MissionScriptElement:on_executed(...)
	local _id = "id_" .. tostring(self._id)
	if SafeHousePlus and not Network:is_client() and Global.game_settings and Global.game_settings.level_id == "chill" then
		--Before Enter
		if _id == "id_101282" and not SafeHousePlus._tmp[_id] then
			SafeHousePlus._tmp[_id] = true
			SafeHousePlus:DoInit()
		end
		--After Enter
		if _id == "id_100014" and not SafeHousePlus._tmp[_id] then
			SafeHousePlus._tmp[_id] = true
			if SafeHousePlus.settings.nogameover_before_timeup == 1 then
				SafeHousePlus:Spawn_One_AI({alone = 1})
			end
		end
	end
	_MissionScriptElement_on_executed(self, ...)
end