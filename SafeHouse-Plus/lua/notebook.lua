_G.SafeHousePlus = _G.SafeHousePlus or {}

function MenuManager:show_leave_safehouse_dialog(params)
	local dialog_data = {}
	dialog_data.title = managers.localization:text("dialog_safehouse_title")
	dialog_data.text = managers.localization:text("dialog_are_you_sure_you_want_to_leave_game")
	local yes_button = {}
	yes_button.text = managers.localization:text("dialog_yes")
	yes_button.callback_func = params.yes_func
	local no_button = {}
	no_button.text = managers.localization:text("dialog_no")
	local plus_button = {}
	plus_button.text = "Use 'SafeHouse Plus'"
	plus_button.callback_func = callback(self, self, "open_safehouse_menu", {})
	dialog_data.button_list = {plus_button, yes_button, no_button}
	managers.system_menu:show(dialog_data)
end

function MenuCallbackHandler:play_safehouse(params)
	local function yes_func()
		self:play_single_player()
		Global.mission_manager.has_played_tutorial = true
		self:start_single_player_job({job_id = "safehouse", difficulty = SafeHousePlus.Difficulty})
	end
	if params.skip_question then
		yes_func()
		return
	end
	managers.menu:show_play_safehouse_question({yes_func = yes_func})
end

function CustomSafehouseGuiPageMap:_go_to_safehouse()
	if Global.game_settings.single_player then
		MenuCallbackHandler:play_single_player()
		MenuCallbackHandler:start_single_player_job({job_id = "chill", difficulty = SafeHousePlus.Difficulty})
	else
		MenuCallbackHandler:start_job({job_id = "chill", difficulty = SafeHousePlus.Difficulty})
	end
end