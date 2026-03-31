{
  pkgs,
  ...
}:
let
  lua_file = builtins.readFile ./debug.lua;
in
{
  # Shows how to use the DAP plugin to debug your code.
  #
  # Primarily focused on configuring the debugger for Go, but can
  # be extended to other languages as well. That's why it's called
  # kickstart.nixvim and not kitchen-sink.nixvim ;)
  # https://nix-community.github.io/nixvim/plugins/dap/index.html
  plugins.dap = {
    enable = true;
  };

  # Creates a beautiful debugger UI
  plugins.dap-ui = {
    enable = true;

    # Set icons to characters that are more likely to work in every terminal.
    # Feel free to remove or use ones that you like more! :)
    # Don't feel like these are good choices.
    settings = {
      icons = {
        expanded = "▾";
        collapsed = "▸";
        current_frame = "*";
      };

      controls = {
        icons = {
          pause = "⏸";
          play = "▶";
          step_into = "⏎";
          step_over = "⏭";
          step_out = "⏮";
          step_back = "b";
          run_last = "▶▶";
          terminate = "⏹";
          disconnect = "⏏";
        };
      };
    };
  };

  # Add your own debuggers here
  plugins = {
    #rustaceanvim.enable = true;
  };
  extraPlugins = with pkgs.vimPlugins; [
    nvim-dap-cortex-debug
  ];
  # https://nix-community.github.io/nixvim/keymaps/index.html
  keymaps = [
    # Basic debugging keymaps, feel free to change to your liking!
    {
      mode = "n";
      key = "<F5>";
      action.__raw = ''
        function()
          require('dap').continue()
        end
      '';
      options = {
        desc = "Debug: Start/Continue";
      };
    }
    {
      mode = "n";
      key = "<F1>";
      action.__raw = ''
        function()
          require('dap').step_into()
        end
      '';
      options = {
        desc = "Debug: Step Into";
      };
    }
    {
      mode = "n";
      key = "<F2>";
      action.__raw = ''
        function()
          require('dap').step_over()
        end
      '';
      options = {
        desc = "Debug: Step Over";
      };
    }
    {
      mode = "n";
      key = "<F3>";
      action.__raw = ''
        function()
          require('dap').step_out()
        end
      '';
      options = {
        desc = "Debug: Step Out";
      };
    }
    {
      mode = "n";
      key = "<leader>b";
      action.__raw = ''
        function()
          require('dap').toggle_breakpoint()
        end
      '';
      options = {
        desc = "Debug: Toggle Breakpoint";
      };
    }
    {
      mode = "n";
      key = "<leader>B";
      action.__raw = ''
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end
      '';
      options = {
        desc = "Debug: Set Breakpoint";
      };
    }
    # Toggle to see last session result. Without this, you can't see session output
    # in case of unhandled exception.
    {
      mode = "n";
      key = "<F7>";
      action.__raw = ''
        function()
          require('dapui').toggle()
        end
      '';
      options = {
        desc = "Debug: See last session result.";
      };
    }
  ];

  environment.systemPackages = with pkgs; [
    llvmPackages.lldb
    gdb
    probe-rs
    # BEST option on Nix:
    vscode-extensions.vadimcn.vscode-lldb.adapter
  ];

  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#extraconfiglua
  extraConfigLua =
    builtins.replaceStrings
      [ "@VSCODE_LLDB_PATH@" "@LLDB_PATH@" ]
      [
        "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb"
        "${pkgs.llvmPackages.lldb}/lib/liblldb.so"
      ]
      lua_file;
}
