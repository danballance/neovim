return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    popup_border_style = "rounded",
    window = {
      position = "float",
      popup = {
        size = { height = "80%", width = "50%" },
        position = "50%",
      },
    },
  },
  keys = {
    { "<leader>e", "<CMD>Neotree float toggle<CR>", desc = "Toggle project tree" },
  },
}
