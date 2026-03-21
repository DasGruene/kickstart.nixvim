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
	local git_dir = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")
	if git_dir == "" then
		error("Could not find project root (.git)")
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
	vim.notify("No program selected, using default: " .. first_choice, vim.log.levels.INFO)
	return first_choice
end

-- GDB adapter
dap.adapters.gdb = {
	type = "executable",
	command = "@GDB_PATH@", -- placeholder replaced by Nix
	args = { "-q", "--interpreter=mi2" },
}

-- Rust configurations using codelldb
dap.configurations.rust = {
	{
		name = "Embedded (gdb)",
		type = "gdb",
		request = "attach", -- or "attach" if you prefer
		program = function()
			return get_dap_program()
		end,
		cwd = project_root,
		miDebuggerServerAddress = "localhost:1337", -- connect to GDB stub
		setupCommands = { { text = "target remote localhost:1337" } },
	},
}

-- Automatically open/close dapui
local dapui = require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

-- ===== Rustacean.nvim Configuration =====
local cfg = require("rustaceanvim.config")

-- VSCode LLDB extension path + liblldb
local extension_path = "@VSCODE_LLDB_PATH@" -- placeholder
local codelldb_path = extension_path .. "/adapter/codelldb"
local liblldb_path = "@LLDB_PATH@" -- placeholder

vim.g.rustaceanvim = {
	dap = {
		adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
	},
}
