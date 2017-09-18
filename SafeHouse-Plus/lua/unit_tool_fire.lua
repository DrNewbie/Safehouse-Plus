_G.SafeHousePlus = _G.SafeHousePlus or {}

Hooks:PostHook(NewRaycastWeaponBase, "fire", "Unit_Tool_Fire_Even", function(fff, ...)
	local _bool = SafeHousePlus.Unit_Tool_Remover or SafeHousePlus.Unit_Tool_Rotation or SafeHousePlus.Unit_Tool_Position or SafeHousePlus.Unit_Tool_Spawner
	if _bool then
		--Copy from 'pierredjays'
		local camera = managers.player:player_unit():movement()._current_state._ext_camera
		local mvec_to = Vector3()
		local from_pos = camera:position()
		mvector3.set( mvec_to, camera:forward() )
		mvector3.multiply( mvec_to, 20000 )
		mvector3.add( mvec_to, from_pos )
		local col_ray = World:raycast( "ray", from_pos, mvec_to, "slot_mask", managers.slot:get_mask( "all" ) )
		if col_ray and col_ray.unit then
			SafeHousePlus:select_unit_tool_menu({unit = col_ray.unit, position = col_ray.position})
		end
		fff.set_ammo(fff, 1.0)
	end
end )