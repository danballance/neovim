# LSP Configuration

Uses Neovim 0.11+ built-in LSP API (`vim.lsp.config` + `vim.lsp.enable`). No nvim-lspconfig plugin needed.

## Configured Servers

| Server | Binary | Filetypes | Root Markers |
|--------|--------|-----------|--------------|
| lua_ls | `lua-language-server` | lua | `.luarc.json`, `.luarc.jsonc`, `.git` |
| nil_ls | `nil` | nix | `flake.nix`, `.git` |
| rust_analyzer | `rust-analyzer` | rust | `Cargo.toml`, `.git` |
| ts_ls | `typescript-language-server --stdio` | javascript, javascriptreact, typescript, typescriptreact | `package.json`, `tsconfig.json`, `jsconfig.json`, `.git` |
| pylsp | `pylsp` | python | `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`, `.git` |

All servers share a wildcard config that sets `.git` as a fallback root marker and registers blink.cmp completion capabilities.

### Server-Specific Settings

**lua_ls**: Runtime set to LuaJIT, workspace includes Neovim runtime files (enables completion for `vim.*` APIs), telemetry disabled.

**nil_ls**: Uses `nixpkgs-fmt` as the Nix formatter.

**rust_analyzer**: Minimal config — relies on rust-analyzer defaults and `Cargo.toml` for project settings.

**ts_ls**: Uses the global `typescript-language-server` package and disables LSP formatting so Conform/Prettier owns formatting for JS/TS buffers.

**pylsp**: Minimal config — uses the globally installed `pylsp` binary on PATH.

## NixOS Binary Sources

LSP binaries come from NixOS packages — no Mason needed. They are declared in `modules/programs/dev-tools.nix` in the parent NixOS config. Run `:checkhealth utils` to verify they're on PATH.

## Capabilities (blink.cmp Integration)

The wildcard config calls `require("blink.cmp").get_lsp_capabilities()` to register completion capabilities with every server. This is why `lsp/init.lua` must load *after* `lazy.setup("plugins")` in the init.lua boot sequence.

## Debug Commands

### `:LspStatus`

Shows which LSP servers are attached to the current buffer and their workspace root directories.

```
LSP [lua_ls] root: /home/anoni/.nixos/dotfiles/nvim-nightly
```

### `:LspLog`

Opens the Neovim LSP log file in a horizontal split. Useful for seeing raw server communication.

### `:LspDebug`

Toggles the LSP log level between `WARN` (default) and `DEBUG`. When `DEBUG` is active, the LSP log captures all request/response traffic — use `:LspLog` to view it.

```
:LspDebug    " -> "LSP log level: DEBUG"
:LspDebug    " -> "LSP log level: WARN"
```

## Adding a New Language Server

1. Add the server binary to your NixOS config (`modules/programs/dev-tools.nix`)

2. Add a config block to `lua/lsp/init.lua`:
   ```lua
   vim.lsp.config("server_name", {
     cmd = { "binary-name" },
     filetypes = { "filetype" },
     root_markers = { "project-file", ".git" },
   })
   ```

3. Add the server name to the `vim.lsp.enable()` call:
   ```lua
   vim.lsp.enable({ "lua_ls", "nil_ls", "rust_analyzer", "ts_ls", "pylsp", "server_name" })
   ```

4. Add the binary to the health check in `lua/utils/health.lua`:
   ```lua
   { "binary-name", "Language LSP" },
   ```

5. Rebuild NixOS: `sudo nixos-rebuild switch --flake .#mouse`

6. Verify: open a file of the target filetype, run `:LspStatus`
