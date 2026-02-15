--- Startup file logger for Neovim.
-- Writes timestamped messages to stdpath("log")/startup.log.
-- On first require, rotates (truncates) the log if it exceeds 10 KB.

local M = {}

local LOG_PATH = vim.fn.stdpath("log") .. "/startup.log"
local MAX_BYTES = 10 * 1024 -- 10 KB

--- Return an ISO-ish timestamp: 2026-02-14T09:31:45.123
local function timestamp()
  local sec, usec = vim.uv.gettimeofday()
  local ms = math.floor(usec / 1000)
  return os.date("!%Y-%m-%dT%H:%M:%S", sec) .. string.format(".%03d", ms)
end

--- Append a single line to the log file.
---@param level string  "INFO" | "WARN" | "ERROR"
---@param msg   string
local function write(level, msg)
  local fd = io.open(LOG_PATH, "a")
  if not fd then
    return
  end
  fd:write(string.format("[%s] [%-5s] %s\n", timestamp(), level, msg))
  fd:close()
end

--- Log an informational message.
---@param msg string
function M.info(msg)
  write("INFO", msg)
end

--- Log a warning message.
---@param msg string
function M.warn(msg)
  write("WARN", msg)
end

--- Log an error message.
---@param msg string
function M.error(msg)
  write("ERROR", msg)
end

--- Wrap a module load: call fn() inside pcall, log outcome.
-- On success logs the module name and returns fn()'s result.
-- On failure logs the error with a traceback and returns nil.
---@param name string  human-readable module name
---@param fn   function  thunk that loads the module
---@return any|nil  result of fn() on success, nil on failure
function M.module(name, fn)
  M.info("loading " .. name .. " ...")
  local ok, result = xpcall(fn, debug.traceback)
  if ok then
    M.info("loaded  " .. name)
    return result
  else
    M.error("FAILED  " .. name .. "\n" .. tostring(result))
    return nil
  end
end

-- Rotate (truncate) the log file if it exceeds MAX_BYTES.
local function rotate()
  local stat = vim.uv.fs_stat(LOG_PATH)
  if stat and stat.size > MAX_BYTES then
    local fd = io.open(LOG_PATH, "w")
    if fd then
      fd:write(string.format("[%s] [%-5s] log rotated (was %d bytes)\n", timestamp(), "INFO", stat.size))
      fd:close()
    end
  end
end

-- User command: open the startup log in a horizontal split.
vim.api.nvim_create_user_command("StartupLog", function()
  vim.cmd("split " .. vim.fn.fnameescape(LOG_PATH))
end, { desc = "Open startup.log in a horizontal split" })

-- Run rotation on first require.
rotate()
M.info("=== Neovim startup ===")

return M
