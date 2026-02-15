-- Leader must be set before lazy.nvim
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Logger (available for all subsequent modules)
local log = require("utils.logger")

-- Core modules
log.module("core.options", function() require("core.options") end)
log.module("core.keymaps", function() require("core.keymaps") end)
log.module("core.autocmds", function() require("core.autocmds") end)

-- Plugins (lazy.nvim auto-imports lua/plugins/)
local nix_ts = vim.env.NIX_TS_PARSERS
log.module("lazy/plugins", function()
  require("lazy").setup("plugins", {
    install = { colorscheme = { "catppuccin" } },
    performance = {
      rtp = {
        paths = nix_ts and { nix_ts } or {},
      },
    },
  })
end)

-- LSP configuration (after plugins so blink.cmp is available)
log.module("lsp", function() require("lsp") end)
log.module("lsp.diagnostics", function() require("lsp.diagnostics") end)

-- Colorscheme
local ok, _ = pcall(vim.cmd.colorscheme, "catppuccin")
if not ok then
  log.warn("colorscheme catppuccin not available")
end

log.info("startup complete")
