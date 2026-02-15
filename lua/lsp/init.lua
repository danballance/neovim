-- LSP server configurations (Neovim 0.11+ built-in API)

-- Wildcard config: applies to all servers
vim.lsp.config("*", {
  root_markers = { ".git" },
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("nil_ls", {
  cmd = { "nil" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
  settings = {
    ["nil"] = {
      formatting = { command = { "nixpkgs-fmt" } },
    },
  },
})

vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git" },
})

vim.lsp.config("pylsp", {
  cmd = { "pylsp" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
})

vim.lsp.enable({ "lua_ls", "nil_ls", "rust_analyzer" })

-- pylsp comes from project dev environments, only enable when available
if vim.fn.executable("pylsp") == 1 then
  vim.lsp.enable("pylsp")
end

-- Debug commands
vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd("split " .. vim.lsp.get_log_path())
end, { desc = "Open LSP log file" })

vim.api.nvim_create_user_command("LspStatus", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP clients attached to current buffer", vim.log.levels.WARN)
    return
  end
  for _, client in ipairs(clients) do
    local root = client.config.root_dir or "unknown"
    vim.notify(string.format("LSP [%s] root: %s", client.name, root), vim.log.levels.INFO)
  end
end, { desc = "Show LSP status for current buffer" })

vim.api.nvim_create_user_command("LspDebug", function()
  local current = vim.lsp.log.get_level()
  if current == vim.lsp.log.levels.DEBUG then
    vim.lsp.set_log_level("WARN")
    vim.notify("LSP log level: WARN", vim.log.levels.INFO)
  else
    vim.lsp.set_log_level("DEBUG")
    vim.notify("LSP log level: DEBUG", vim.log.levels.INFO)
  end
end, { desc = "Toggle LSP debug logging" })
