{ ... }:
let
  minuetConfig = ''
        local api_key = os.getenv('CODESTRAL_API_KEY')
        if not api_key or api_key == "" then
          vim.notify('Codestral API envroment variable not available', vim.log.levels.ERROR)
          return
        end
    require('minuet').setup({
          provider = 'codestral',
          request_timeout = 30,
          provider_options = {
            codestral = {
              end_point = 'https://codestral.mistral.ai/v1/fim/completions',
              stream = true,
              optional = {
                max_tokens = 256,
              },
            },
          },
        })
  '';
  minuetConfigFile = builtins.toFile "minuet-config.lua" minuetConfig;
in
{
  plugins.minuet = {
    enable = true;
  };

  extraConfigLua = ''
    dofile("${minuetConfigFile}")
  '';
}
