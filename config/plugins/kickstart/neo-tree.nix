{
  # Neo-tree is a Neovim plugin to browse the file system
  # https://nix-community.github.io/nixvim/plugins/neo-tree/index.html?highlight=neo-tree#pluginsneo-treepackage
  plugins.neo-tree = {
    enable = true;

    extraOptions = {
      window = {
        position = "right";
      };
      filesystem = {
        filtered_items = {
          visible = true;
        };
      };
    };
  };

  # https://nix-community.github.io/nixvim/keymaps/index.html
  keymaps = [
    {
      key = "<leader>e";
      action = "<cmd>Neotree reveal<CR>";
      options = {
        desc = "NeoTree reveal";
        noremap = true;
        silent = true;
      };
    }
  ];
}
