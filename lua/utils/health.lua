local M = {}

M.check = function()
  vim.health.start("nvim")

  -- Neovim version
  local v = vim.version()
  vim.health.info(string.format("Neovim %d.%d.%d", v.major, v.minor, v.patch))

  -- NVIM_APPNAME and config dir
  vim.health.info("NVIM_APPNAME: " .. (vim.env.NVIM_APPNAME or "nvim"))
  vim.health.info("Config: " .. vim.fn.stdpath("config"))

  -- LSP binaries
  vim.health.start("LSP Binaries")
  local binaries = {
    { "lua-language-server", "Lua LSP" },
    { "nil", "Nix LSP" },
    { "rust-analyzer", "Rust LSP" },
    { "pylsp", "Python LSP (from project dev env)" },
    { "gcc", "C compiler (optional)" },
    { "nixpkgs-fmt", "Nix formatter" },
  }
  for _, bin in ipairs(binaries) do
    if vim.fn.executable(bin[1]) == 1 then
      vim.health.ok(bin[2] .. " (" .. bin[1] .. ")")
    else
      vim.health.warn(bin[2] .. " (" .. bin[1] .. ") not found on PATH")
    end
  end

  -- Treesitter parsers
  if vim.env.NIX_TS_PARSERS then
    vim.health.start("Treesitter Parsers (Nix-provided)")
  else
    vim.health.start("Treesitter Parsers (runtime-installed)")
  end
  local expected_parsers = { "lua", "nix", "rust", "python", "vim", "vimdoc", "markdown", "markdown_inline" }
  for _, lang in ipairs(expected_parsers) do
    local parser_ok, _ = pcall(vim.treesitter.language.inspect, lang)
    if parser_ok then
      vim.health.ok(lang)
    else
      vim.health.warn(lang .. " parser not installed")
    end
  end

  -- Lazy.nvim plugins
  vim.health.start("Plugins")
  local ok, lazy = pcall(require, "lazy")
  if ok then
    local plugins = lazy.plugins()
    vim.health.info(string.format("%d plugins installed", #plugins))
    for _, plugin in ipairs(plugins) do
      if plugin._.has_errors then
        vim.health.error("Plugin failed: " .. plugin.name)
      end
    end
  else
    vim.health.warn("lazy.nvim not available")
  end
end

return M
