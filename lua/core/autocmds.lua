-- LspAttach: set LSP keymaps when a server attaches
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = function(desc) return { buffer = ev.buf, desc = desc } end
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Find references"))
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover docs"))
    vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, opts("Signature help"))
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename symbol"))
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
    vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts("Format buffer"))

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local name = client and client.name or "unknown"
    vim.notify(string.format("LSP [%s] attached to buffer %d", name, ev.buf), vim.log.levels.INFO)
  end,
})

-- LspDetach: log when a server detaches
vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local name = client and client.name or "unknown"
    vim.notify(string.format("LSP [%s] detached from buffer %d", name, ev.buf), vim.log.levels.INFO)
  end,
})
