return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = nil,
	config = function()
		local indent_filetypes = {
			lua = true,
			nix = true,
			rust = true,
			python = true,
			javascript = true,
			javascriptreact = true,
			typescript = true,
			typescriptreact = true,
			json = true,
			css = true,
			scss = true,
			html = true,
			yaml = true,
			markdown = true,
		}

		local group = vim.api.nvim_create_augroup("nvim-treesitter-features", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
				if indent_filetypes[vim.bo[args.buf].filetype] then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		pcall(vim.treesitter.start)
		if indent_filetypes[vim.bo.filetype] then
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
}
