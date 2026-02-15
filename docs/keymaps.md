# Keymaps

Leader key: `Space`

## Global Keymaps

Defined in `lua/core/keymaps.lua`. Available in all buffers.

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `[d` | n | `vim.diagnostic.goto_prev` | Previous diagnostic |
| `]d` | n | `vim.diagnostic.goto_next` | Next diagnostic |
| `<leader>d` | n | `vim.diagnostic.open_float` | Show diagnostic float |
| `<leader>q` | n | `vim.diagnostic.setloclist` | Diagnostics to location list |

## LSP Keymaps

Defined in `lua/core/autocmds.lua` via `LspAttach` autocommand. Only active in buffers with an attached language server.

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `gd` | n | `vim.lsp.buf.definition` | Go to definition |
| `gD` | n | `vim.lsp.buf.declaration` | Go to declaration |
| `gr` | n | `vim.lsp.buf.references` | Find references |
| `gi` | n | `vim.lsp.buf.implementation` | Go to implementation |
| `K` | n | `vim.lsp.buf.hover` | Hover documentation |
| `<leader>k` | n | `vim.lsp.buf.signature_help` | Signature help |
| `<leader>rn` | n | `vim.lsp.buf.rename` | Rename symbol |
| `<leader>ca` | n | `vim.lsp.buf.code_action` | Code action |
| `<leader>f` | n | `vim.lsp.buf.format` | Format buffer (async) |

## Plugin Keymaps

| Key | Mode | Action | Plugin | Defined in |
|-----|------|--------|--------|------------|
| `-` | n | `:Oil` | oil.nvim | `lua/plugins/oil.lua` |
| `<leader>e` | n | `:Neotree float toggle` | neo-tree | `lua/plugins/neotree.lua` |
| `<leader>o` | n | `:Outline` | outline.nvim | `lua/plugins/outline.lua` |
| `<leader>?` | n | Show buffer-local keymaps | which-key | `lua/plugins/whichkey.lua` |

## User Commands

| Command | Description | Defined in |
|---------|-------------|------------|
| `:StartupLog` | Open startup log in a split | `lua/utils/logger.lua` |
| `:LspLog` | Open LSP log file in a split | `lua/lsp/init.lua` |
| `:LspStatus` | Show attached LSP clients for current buffer | `lua/lsp/init.lua` |
| `:LspDebug` | Toggle LSP log level (DEBUG/WARN) | `lua/lsp/init.lua` |
| `:Lazy` | Open lazy.nvim plugin manager | lazy.nvim (built-in) |
| `:Notifications` | Show notification history | nvim-notify |
| `:checkhealth utils` | Run custom health checks | `lua/utils/health.lua` |
