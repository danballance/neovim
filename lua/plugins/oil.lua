local compact_columns = { "icon" }

local detail_columns = {
	"icon",
	"permissions",
	"size",
	{ "mtime", format = "%Y-%m-%d %H:%M" },
}

local show_detail = true

return {
	"stevearc/oil.nvim",
	lazy = false,
	opts = {
		default_file_explorer = true,
		columns = detail_columns,
		keymaps = {
			["gd"] = {
				desc = "Toggle Oil detail view",
				callback = function()
					show_detail = not show_detail
					require("oil").set_columns(show_detail and detail_columns or compact_columns)
				end,
			},
		},
	},
	config = function(_, opts)
		local oil = require("oil")
		oil.setup(opts)

		-- When Neovim is started with a directory argument (`nvim .`), oil can
		-- hijack the directory buffer before `VimEnter` but not render it. Re-open
		-- the oil URL once startup is complete so the project tree is populated.
		vim.api.nvim_create_autocmd("VimEnter", {
			group = vim.api.nvim_create_augroup("OilStartupDirectory", { clear = true }),
			callback = function()
				vim.schedule(function()
					local name = vim.api.nvim_buf_get_name(0)
					if name:match("^oil://") and vim.bo.filetype == "" then
						oil.open(name)
					end
				end)
			end,
		})
	end,
	keys = {
		{ "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
	},
}
