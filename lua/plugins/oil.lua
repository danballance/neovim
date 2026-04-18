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
	keys = {
		{ "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
	},
}
