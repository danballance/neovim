# Plugins

Managed by [lazy.nvim](https://github.com/folke/lazy.nvim). Each plugin has its own spec file in `lua/plugins/`. Lazy.nvim auto-imports the entire directory.

## Plugin List

| Plugin | Repo | Purpose | Loading | Config File |
|--------|------|---------|---------|-------------|
| catppuccin | `catppuccin/nvim` | Colorscheme | `priority = 1000` | `plugins/catppuccin.lua` |
| oil.nvim | `stevearc/oil.nvim` | File explorer (replaces netrw) | `lazy = false` | `plugins/oil.lua` |
| fzf-lua | `ibhagwan/fzf-lua` | Fuzzy finder | default (lazy) | `plugins/fzf.lua` |
| neo-tree | `nvim-neo-tree/neo-tree.nvim` | Project tree (floating) | on `<leader>e` | `plugins/neotree.lua` |
| outline.nvim | `hedyhli/outline.nvim` | Code outline sidebar | on `<leader>o` | `plugins/outline.lua` |
| nvim-treesitter | `nvim-treesitter/nvim-treesitter` | Syntax highlighting | default | `plugins/treesitter.lua` |
| blink.cmp | `saghen/blink.cmp` | Completion engine | default | `plugins/blink.lua` |
| which-key | `folke/which-key.nvim` | Keymap hints | `VeryLazy` | `plugins/whichkey.lua` |
| nvim-notify | `rcarriga/nvim-notify` | Visual notifications | `lazy = false` | `plugins/notify.lua` |

### Dependencies (auto-installed)

- `nvim-tree/nvim-web-devicons` — file icons (used by neo-tree, oil)
- `MunifTanjim/nui.nvim` — UI component library (used by neo-tree)
- `nvim-lua/plenary.nvim` — Lua utility library (used by neo-tree)

## Notable Configuration Choices

**oil.nvim** (`lazy = false`): Must load eagerly to register as the default file explorer before netrw. Without this, opening a directory falls through to netrw.

**nvim-notify** (`lazy = false`): Replaces `vim.notify` at startup so LSP attach/detach messages and errors display as visual popups instead of hiding in `:messages`.

**blink.cmp** (`version = "1.*"`): Pinned to v1.x for stability. Provides LSP capabilities to all language servers via `get_lsp_capabilities()`.

**neo-tree** (floating window): Opens as a centered float (80% height, 50% width) instead of a sidebar, keeping the editing area uncluttered.

**treesitter** (Nix-provided parsers): Parsers are built by Nix via `nvim-treesitter.withPlugins`. The `nvim` wrapper exports a `NIX_TS_PARSERS` env var pointing to the store path, and `lazy_bootstrap.lua` passes it to lazy.nvim's `performance.rtp.paths` so the path survives lazy.nvim's rtp reset. No runtime compilation, `build` step, or `gcc` required.

## Managing Plugins

```vim
:Lazy              " Open lazy.nvim dashboard
:Lazy sync         " Update all plugins to latest versions
:Lazy health       " Check lazy.nvim health
```

The `lazy-lock.json` lockfile pins exact plugin versions for reproducibility.
