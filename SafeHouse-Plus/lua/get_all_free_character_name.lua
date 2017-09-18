function CriminalsManager:get_all_free_character_name()
	local available = {}
	for id, data in pairs(self._characters) do
		local taken = data.taken
		if not taken and not self:is_character_as_AI_level_blocked(data.name) then
			table.insert(available, data.name)
		end
	end
	if #available > 0 then
		return available
	end
end