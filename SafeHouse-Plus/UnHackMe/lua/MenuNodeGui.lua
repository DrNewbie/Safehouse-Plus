
-- show warning at startup
local _setup_item_rows_original = MenuNodeGui._setup_item_rows
function MenuNodeGui:_setup_item_rows(node, ...)
	_setup_item_rows_original(self, node, ...)
	if not Global._friendsonly_warning_shown then
		Global._friendsonly_warning_shown = true
		QuickMenu:new(
			"[SafeHouse Plus]",
			"The following is disabled: Achievments, public-gameplay, statistics and progress-saving.\nFor your sake, turn off this MOD, and reboot the game before you're going to play other or normal heist.",
			{
				{
					text = "ok",
					is_cancel_button = true
				}
			},
			true
		)
	end
end
