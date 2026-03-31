-- Change breakpoint icons
-- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
-- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
-- local breakpoint_icons = vim.g.have_nerd_font
--     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
--   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
-- for type, icon in pairs(breakpoint_icons) do
--   local tp = 'Dap' .. type
--   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
--   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
-- end

-- ===== DAP Configuration =====
local dap = require("dap")

local function get_project_root()
	local cwd = vim.fn.getcwd()
	local git_dir = vim.fn.finddir(".git", cwd .. ";") -- ; makes it search upward
	if git_dir == "" then
		-- fallback to cwd if git not found
		vim.notify("Could not find .git, using cwd as project root", vim.log.levels.WARN)
		return cwd
	end
	return vim.fn.fnamemodify(git_dir, ":h")
end

local project_root = get_project_root()

local programs = {
	["Init Example"] = project_root .. "/target/thumbv7em-none-eabihf/debug/examples/init",
	-- ["Other Example"] = project_root .. "/target/thumbv7em-none-eabihf/debug/examples/other",
}

-- Program selection with fallback
local function get_dap_program()
	if vim.g.dap_last_program and vim.g.dap_last_program ~= "" then
		return vim.g.dap_last_program
	end

	-- fallback to first program
	local first_choice = programs[vim.tbl_keys(programs)[1]]
	vim.g.dap_last_program = first_choice
	--	vim.notify("No program selected, using default: " .. first_choice, vim.log.levels.INFO)
	return first_choice
end

-- placeholders in Lua
local extension_path = "@VSCODE_LLDB_PATH@" -- will be replaced by Nix
local codelldb_path = extension_path .. "/adapter/codelldb"
local liblldb_path = "@LLDB_PATH@" -- will be replaced by Nix

-- Register the cortex-debug adapter
dap.adapters.cortex_debug = {
	type = "executable",
	command = "arm-none-eabi-gdb", -- or 'OpenOCD', depending on your setup
	name = "cortex-debug",
}

dap.configurations.rust = {
	{
		name = "Embedded",
		type = "cortex_debug",
		request = "launch",
		program = get_dap_program(),
		cwd = vim.fn.getcwd(),
		miDebuggerServerAddress = "127.0.0.1:1337",
		stopOnEntry = true,
		setupCommands = {
			{ text = "target remote 127.0.0.1:1337", description = "Connect to probe-rs stub" },
			{ text = "break main", description = "Break at main" },
		},
	},
}

dap.set_log_level("DEBUG")

-- Automatically open/close dapui
local dapui = require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

-- VSCode LLDB extension path + liblldb
local extension_path = "@VSCODE_LLDB_PATH@" -- placeholder
local codelldb_path = extension_path .. "/adapter/codelldb"
local liblldb_path = "@LLDB_PATH@" -- placeholder
