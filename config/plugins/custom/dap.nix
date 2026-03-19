{
  pkgs,
  ...
}:
{
  extraPackages = with pkgs; [
    lldb
    # BEST option on Nix:
    vscode-extensions.vadimcn.vscode-lldb.adapter
  ];

  plugins = {
    dap.enable = true;
    dap-ui.enable = true;
    rustaceanvim.enable = true;
  };

  extraConfigLua = ''
    vim.g.rustaceanvim = function()
      local cfg = require('rustaceanvim.config')
        return {
          dap = {
            adapter = cfg.get_codelldb_adapter(
              -- Nix provides this automatically in PATH
              "codelldb",
              "liblldb"
            ),
          },
        }
      end
  '';
}
