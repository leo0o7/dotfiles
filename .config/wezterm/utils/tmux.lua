local M = {}

local wezterm = require("wezterm")
local act = wezterm.action

local function in_tmux_or_else(window, true_fn, false_fn)
	local pane = window:active_pane()

	if M.is_in_tmux(pane) then
		print("in tmux")
		window:perform_action(true_fn, pane)
	else
		print("not in tmux")
		window:perform_action(false_fn, pane)
	end
end
wezterm.on("close_tmux_pane_or_window", function(window)
	in_tmux_or_else(window, M.prefixed_key("x"), act.CloseCurrentPane({ confirm = false }))
	--local in_tmux = M.is_in_tmux(pane)
	--if in_tmux then
	--	window:perform_action(M.prefixed_key("x"), pane)
	--else
	--	window:perform_action(act.CloseCurrentPane({ confirm = false }), pane)
	--end
end)

wezterm.on("clear_tmux_or_normal", function(window)
	in_tmux_or_else(
		window,
		M.prefixed_keymap("l", "CTRL"),
		act.Multiple({
			act.SendString(" clear"),
			act.SendKey({ key = "Enter", mods = " " }),
		})
	)
end)

wezterm.on("new_tmux_or_tab", function(window)
	in_tmux_or_else(window, M.prefixed_key("c"), act.SpawnTab("CurrentPaneDomain"))
end)
M.prefixed_key = function(tmux_key)
	return act.Multiple({
		act.SendKey({ key = "a", mods = "CTRL" }),
		act.SendKey({ key = tmux_key }),
	})
end

M.prefixed_keymap = function(tmux_key, tmux_mod)
	return act.Multiple({
		act.SendKey({ key = "a", mods = "CTRL" }),
		act.SendKey({ key = tmux_key, mods = tmux_mod }),
	})
end

M.is_in_tmux = function(pane)
	local process_info = pane:get_foreground_process_info()

	if process_info == nil then
		return false
	end

	-- check if executable is tmux
	if process_info.executable == "/opt/homebrew/bin/tmux" then
		return true
	end

	-- check if any childs are tmux
	for _, child in pairs(process_info.children) do
		if child.executable == "/opt/homebrew/bin/tmux" then
			return true
		end
	end

	-- TODO:
	-- make it work
	-- check if parent is tmux

	-- if process_info.ppid then
	-- 	local parent_process_info = wezterm.get_info_for_pid(process_info.ppid)
	-- 	if parent_process_info and parent_process_info.executable == "/opt/homebrew/bin/tmux" then
	-- 		return true
	-- 	end
	-- end

	return false
end

return M
