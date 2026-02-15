# Troubleshooting

## Diagnostic Tools

### `:StartupLog`

Opens `~/.local/state/nvim/startup.log` in a split. Shows timestamped module load events:

```
[2026-02-14T09:31:45.123] [INFO ] === Neovim startup ===
[2026-02-14T09:31:45.124] [INFO ] loading core.options ...
[2026-02-14T09:31:45.124] [INFO ] loaded  core.options
[2026-02-14T09:31:45.125] [INFO ] loading core.keymaps ...
[2026-02-14T09:31:45.125] [INFO ] loaded  core.keymaps
...
[2026-02-14T09:31:45.300] [INFO ] startup complete
```

If a module fails, you'll see `FAILED` with a full traceback:

```
[2026-02-14T09:31:45.200] [ERROR] FAILED  lsp
stack traceback:
    lua/lsp/init.lua:6: module 'blink.cmp' not found
    ...
```

The log auto-rotates at 10 KB.

### `:checkhealth utils`

Verifies your environment is correctly set up:

```vim
:checkhealth utils
```

Checks:
- Neovim version and config paths
- LSP binaries on PATH (`lua-language-server`, `nil`, `rust-analyzer`, `pylsp`, `nixpkgs-fmt`)
- Treesitter parsers available (lua, nix, rust, python, vim, vimdoc, markdown, markdown_inline) — provided by Nix
- Lazy.nvim plugin count and any failed plugins

### `:LspStatus`

Shows LSP servers attached to the current buffer:

```vim
:LspStatus
" -> LSP [lua_ls] root: /home/anoni/.nixos/dotfiles/nvim-nightly
```

If no output, no LSP server is attached to the current buffer.

### `:LspDebug`

Toggles verbose LSP logging. After enabling, check `:LspLog` for detailed request/response traffic.

## Common Issues

### LSP not attaching

1. Check the binary exists: `:checkhealth utils`
2. Check the filetype is correct: `:set filetype?`
3. Check the root marker is found: the server needs a root marker (e.g., `.git`, `Cargo.toml`) in a parent directory
4. Enable debug logging: `:LspDebug`, edit a file, then `:LspLog`
5. Check startup log for errors: `:StartupLog`

### Oil.nvim not opening as file explorer

Oil must load eagerly. Verify `lua/plugins/oil.lua` has `lazy = false`. If `nvim .` opens netrw instead of oil, the plugin either failed to load or is being lazy-loaded.

Check `:StartupLog` for oil-related errors and `:Lazy` to confirm oil.nvim is loaded (not just installed).

### Treesitter parsers missing

Parsers are provided by Nix via `nvim-treesitter.withPlugins`. The `nvim` wrapper exports `NIX_TS_PARSERS` pointing to the parser store path, and `init.lua` passes it to lazy.nvim's `performance.rtp.paths` so the path survives lazy.nvim's rtp reset. If parsers are missing:

1. Check the env var is set: `echo $NIX_TS_PARSERS` — should print a `/nix/store/...-treesitter-parsers` path
2. Check `:set rtp?` — should include the same `/nix/store/...-treesitter-parsers` path
3. If the env var is set but the rtp path is missing, lazy.nvim's `performance.rtp.paths` may not be configured — check `init.lua`
4. Run `:checkhealth utils` — all 8 parsers should show OK
5. If parsers fail to load, there may be an ABI mismatch between the nightly binary and nixpkgs' tree-sitter C library. Check `:messages` for dlopen errors.

### Notifications not showing

nvim-notify must load at startup. Check `lua/plugins/notify.lua` has `lazy = false`. If notifications aren't appearing, verify the plugin loaded:

```vim
:lua print(type(vim.notify))
" Should print: "function" (from nvim-notify, not the default)
```

### Plugin load failures

```vim
:Lazy              " Check for failed plugins (shown with error icons)
:Notifications     " Check for error notifications
:StartupLog        " Check for module load failures
```

## Log File Locations

| Log | Path | Command |
|-----|------|---------|
| Startup log | `~/.local/state/nvim/startup.log` | `:StartupLog` |
| LSP log | `~/.local/state/nvim/lsp.log` | `:LspLog` |
| Neovim log | `~/.local/state/nvim/log` | `:edit $NVIM_LOG_FILE` |
