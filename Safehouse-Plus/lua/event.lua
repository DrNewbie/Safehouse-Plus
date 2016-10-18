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
	if SafeHousePlus and not Network:is_client() then
		if _id == "id_101282" and not SafeHousePlus._tmp[_id] then
			SafeHousePlus._tmp[_id] = true
			SafeHousePlus:DoInit()
		end
	end
	_MissionScriptElement_on_executed(self, ...)
end