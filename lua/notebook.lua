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