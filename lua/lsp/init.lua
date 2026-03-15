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

if vim.fn.executable("pylsp") == 1 then
	vim.lsp.enable("pylsp")
end

if vim.fn.executable("rust_analyzer") == 1 then
	vim.lsp.enable("rust_analyzer")
end

if vim.fn.executable("nil") == 1 then
	vim.lsp.enable("nil_ls")
end

if vim.fn.executable("lua-language-server") == 1 then
	vim.lsp.enable("lua_ls")
end
