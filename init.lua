-- Leader must be set before lazy.nvim
vim.g.mapleader = " "

-- Logger (available for all subsequent modules)
local log = require("utils.logger")

local function load(name)
  log.module(name, function() require(name) end)
end

-- Core modules
load("core.options")
load("core.keymaps")
load("core.autocmds")

-- Plugins (bootstrap lazy.nvim, then auto-import lua/plugins/)
load("lazy_bootstrap")

-- LSP configuration (after plugins so blink.cmp is available)
load("lsp")
load("lsp.diagnostics")

-- Colorscheme
local ok, _ = pcall(vim.cmd.colorscheme, "catppuccin")
if not ok then
  log.warn("colorscheme catppuccin not available")
end

log.info("startup complete")
