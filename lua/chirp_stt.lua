--- Minimal Google Chirp 3 speech-to-text bridge for Neovim.
---
--- Runtime assumptions:
--- - Launch Neovim from `nix develop ~/.nixos#python-gcp`
--- - `python3` on PATH provides `pyaudio` and `google-cloud-speech`
--- - `GOOGLE_CLOUD_PROJECT` and Application Default Credentials are configured
--- - `GOOGLE_CLOUD_LOCATION` optionally overrides the default `eu` region
---
--- This module owns a single background Python worker.
--- - STATUS lines become notifications
--- - INTERIM lines are shown as inline virtual text
--- - FINAL lines are pasted into the buffer at the cursor
---
--- Toggling again stops the worker and exits Insert mode.

local M = {}

local ns = vim.api.nvim_create_namespace("chirp_stt")

local state = {
  job_id = nil,
  winid = nil,
  stdout_pending = "",
  stderr_pending = "",
  stopping = false,
  last_status = nil,
  interim_bufnr = nil,
  interim_extmark = nil,
  interim_text = nil,
}

local function is_insert_mode()
  return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
end

---@return string
local function worker_path()
  return vim.fn.stdpath("config") .. "/lua/chirp_stt_worker.py"
end

local function clear_interim()
  if state.interim_bufnr and state.interim_extmark and vim.api.nvim_buf_is_valid(state.interim_bufnr) then
    pcall(vim.api.nvim_buf_del_extmark, state.interim_bufnr, ns, state.interim_extmark)
  end

  state.interim_bufnr = nil
  state.interim_extmark = nil
  state.interim_text = nil
end

local function run_in_target_window(fn)
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    return pcall(vim.api.nvim_win_call, state.winid, fn)
  end

  return pcall(fn)
end

local function show_interim(text)
  local interim_text = vim.trim(text)
  if interim_text == "" or interim_text == state.interim_text then
    return
  end

  clear_interim()

  local ok = run_in_target_window(function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local bufnr = vim.api.nvim_get_current_buf()

    state.interim_bufnr = bufnr
    state.interim_extmark = vim.api.nvim_buf_set_extmark(bufnr, ns, cursor[1] - 1, cursor[2], {
      virt_text = { { interim_text, "Comment" } },
      virt_text_pos = "inline",
      hl_mode = "combine",
    })
    state.interim_text = interim_text
  end)

  if not ok then
    clear_interim()
  end
end

local function paste_final(text)
  local final_text = vim.trim(text)
  if final_text == "" then
    return
  end

  clear_interim()

  local ok = run_in_target_window(function()
    vim.api.nvim_paste(final_text .. " ", false, -1)
  end)

  if not ok then
    vim.notify("Chirp STT: failed to insert transcript", vim.log.levels.ERROR)
  end
end

local function show_status(text)
  local status_text = vim.trim(text)
  if status_text == "" or status_text == state.last_status then
    return
  end

  state.last_status = status_text
  vim.notify("Chirp STT: " .. status_text, vim.log.levels.INFO)
end

local function is_benign_stderr(line)
  return line:match("^ALSA lib ") ~= nil
end

local function process_stream_data(pending, data, on_line)
  if not data or vim.tbl_isempty(data) then
    return pending
  end

  local lines = vim.list_extend({}, data)
  lines[1] = pending .. (lines[1] or "")

  local next_pending = table.remove(lines) or ""

  for _, line in ipairs(lines) do
    if line ~= "" then
      on_line(line)
    end
  end

  return next_pending
end

local function handle_stdout_line(line)
  local kind, payload = line:match("^(%u+)\t(.*)$")

  if kind == "STATUS" then
    vim.schedule(function()
      show_status(payload)
    end)
    return
  end

  if kind == "INTERIM" then
    vim.schedule(function()
      show_interim(payload)
    end)
    return
  end

  if kind == "FINAL" then
    vim.schedule(function()
      paste_final(payload)
    end)
    return
  end

  vim.schedule(function()
    paste_final(line)
  end)
end

local function start()
  state.stopping = false
  state.last_status = nil
  state.winid = vim.api.nvim_get_current_win()
  state.stdout_pending = ""
  state.stderr_pending = ""
  clear_interim()

  local job_id
  job_id = vim.fn.jobstart({ "python3", worker_path() }, {
    on_stdout = function(_, data)
      if state.job_id ~= job_id then
        return
      end

      state.stdout_pending = process_stream_data(state.stdout_pending, data, handle_stdout_line)
    end,
    on_stderr = function(_, data)
      if state.job_id ~= job_id then
        return
      end

      local stderr_lines = {}
      state.stderr_pending = process_stream_data(state.stderr_pending, data, function(line)
        if not is_benign_stderr(line) then
          table.insert(stderr_lines, line)
        end
      end)

      if #stderr_lines > 0 then
        vim.schedule(function()
          vim.notify(table.concat(stderr_lines, "\n"), vim.log.levels.ERROR, { title = "Chirp STT" })
        end)
      end
    end,
    on_exit = function(_, code)
      if state.job_id ~= job_id then
        return
      end

      local was_stopping = state.stopping
      state.job_id = nil
      state.winid = nil
      state.stdout_pending = ""
      state.stderr_pending = ""
      state.stopping = false
      state.last_status = nil

      vim.schedule(function()
        clear_interim()

        if not was_stopping then
          vim.cmd.stopinsert()
        end

        if code ~= 0 and not was_stopping then
          vim.notify("Chirp STT worker exited with code " .. code, vim.log.levels.ERROR)
        end
      end)
    end,
  })

  if job_id <= 0 then
    state.winid = nil
    error("failed to start chirp stt worker")
  end

  state.job_id = job_id

  if not is_insert_mode() then
    vim.cmd.startinsert()
  end
end

local function stop()
  if not state.job_id then
    return
  end

  state.stopping = true
  vim.fn.jobstop(state.job_id)
  clear_interim()
  vim.cmd.stopinsert()
end

--- Toggle realtime Chirp STT on or off.
---
--- Start path:
--- - spawns `lua/chirp_stt_worker.py` with plain `python3`
--- - enters Insert mode immediately
--- - shows interim recognition inline while the worker is listening
---
--- Stop path:
--- - stops the worker job
--- - clears interim text
--- - leaves Insert mode immediately
function M.toggle()
  if state.job_id then
    stop()
  else
    start()
  end
end

return M
