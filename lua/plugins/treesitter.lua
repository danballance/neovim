return {
  "nvim-treesitter/nvim-treesitter",
  config = function()
    local opts = {}
    -- On non-Nix systems, install parsers at runtime
    if not vim.env.NIX_TS_PARSERS then
      opts.ensure_installed = {
        "lua", "nix", "rust", "python",
        "vim", "vimdoc", "markdown", "markdown_inline",
      }
    end
    require("nvim-treesitter").setup(opts)
  end,
}
