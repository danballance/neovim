return {
  dir = vim.fn.stdpath("config"),
  name = "chirp-stt",
  lazy = false,
  config = function()
    vim.keymap.set({ "n", "i" }, "<leader>c", function()
      require("chirp_stt").toggle()
    end, { desc = "Toggle Chirp STT", silent = true })
  end,
}
