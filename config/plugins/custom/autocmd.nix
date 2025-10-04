{
  autoCmd = [
    {
      #makes neovim remember last cursor position when reopening files
      event = [ "BufReadPost" ];
      pattern = [ "*" ];
      callback = {
        __raw = ''
          	      function()
                          local last_position = vim.fn.line("'\"")
                          if last_position > 0 and last_position <= vim.fn.line("$") then
                            vim.cmd("normal! g'\"")
                          end
                        end '';
      };
    }
  ];
}
