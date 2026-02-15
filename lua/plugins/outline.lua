return {
  "hedyhli/outline.nvim",
  opts = {
    outline_window = {
      position = "right",
      width = 25,
      relative_width = true,
      focus_on_open = true,
    },
  },
  keys = {
    { "<leader>o", "<CMD>Outline<CR>", desc = "Toggle code outline" },
  },
}
