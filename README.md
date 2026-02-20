# nvim-nightly

Neovim 0.12 nightly configuration. Uses lazy.nvim for plugin management with a modular file structure — one file per plugin, separate modules for LSP, core settings, and utilities.

## Quick Start

```bash
# Clone to your Neovim config directory
git clone git@github.com:danballance/neovim.git ~/.config/nvim

# Launch Neovim
nvim
```

On first launch, lazy.nvim will bootstrap itself and install all plugins. On non-NixOS systems, treesitter parsers will also be installed automatically.

On NixOS, this config is designed to be used with a Nix wrapper that provides the nightly binary, LSP servers, and treesitter parsers. See the [NixOS-Specific Design](#nixos-specific-design) section.

## Directory Structure

```
nvim-nightly/
├── init.lua                    # Set leader, load modules via logger helper
├── lazy-lock.json              # Plugin version lockfile
├── docs/                       # This documentation
└── lua/
    ├── lazy_bootstrap.lua      # Bootstrap lazy.nvim & setup plugins
    ├── core/
    │   ├── options.lua         # Editor settings (line numbers, tabs, etc.)
    │   ├── keymaps.lua         # Global keymaps (diagnostic navigation)
    │   └── autocmds.lua        # LspAttach/LspDetach autocommands
    ├── plugins/
    │   ├── catppuccin.lua      # Colorscheme
    │   ├── oil.lua             # File explorer (replaces netrw)
    │   ├── fzf.lua             # Fuzzy finder
    │   ├── neotree.lua         # Project tree (floating)
    │   ├── outline.lua         # Code outline sidebar
    │   ├── treesitter.lua      # Syntax highlighting (parsers from Nix or runtime)
    │   ├── blink.lua           # Completion engine
    │   ├── whichkey.lua        # Keymap hints
    │   └── notify.lua          # Visual notifications (replaces vim.notify)
    ├── lsp/
    │   ├── init.lua            # Server configs & debug commands
    │   └── diagnostics.lua     # Diagnostic display & sign definitions
    └── utils/
        ├── logger.lua          # Startup tracing with timestamps
        └── health.lua          # :checkhealth integration
```

## Startup Load Order

```
1. vim.g.mapleader = " "          (before lazy.nvim)
2. require("utils.logger")        (enables startup tracing)
3. core.options                   (editor settings)
4. core.keymaps                   (global keymaps)
5. core.autocmds                  (LSP autocommands)
6. lazy_bootstrap                 (bootstrap lazy.nvim + load plugins)
7. lsp/init.lua                   (server configs, vim.lsp.enable)
8. lsp/diagnostics.lua            (diagnostic display)
9. colorscheme catppuccin         (apply theme)
```

Every module load (steps 3-8) is wrapped in `logger.module()` via a `load()` helper, which uses `xpcall` with `debug.traceback`. If any module fails, the error and full traceback are logged to `startup.log` and the remaining modules still load.

## NixOS-Specific Design

This config is built for NixOS. Key differences from a typical Neovim setup:

- **No Mason** — LSP server binaries (`lua-language-server`, `nil`, `rust-analyzer`) are installed via NixOS packages. `pylsp` (Python) comes from each project's dev environment (`nix develop` / `devenv`)
- **nixpkgs-fmt** — used as the Nix formatter (configured in nil_ls)
- **flake.nix root marker** — nil_ls recognizes `flake.nix` as a project root
- **Nix-provided treesitter parsers** — parsers are built by Nix via `nvim-treesitter.withPlugins`, exported as `NIX_TS_PARSERS` env var by the `nvim` wrapper, and preserved through lazy.nvim's rtp reset via `performance.rtp.paths`. No runtime compilation needed.

### Portability

This config also works on non-NixOS machines:
- **Treesitter parsers** are auto-installed at runtime when `NIX_TS_PARSERS` is not set
- **LSP servers** must be on PATH (install via your system package manager)
- **lazy.nvim** bootstraps itself on first launch

## Further Reading

- [Keymaps](docs/keymaps.md) — complete keymap reference
- [LSP](docs/lsp.md) — language server setup and debugging
- [Plugins](docs/plugins.md) — plugin list and configuration
- [Troubleshooting](docs/troubleshooting.md) — debug commands and common issues
