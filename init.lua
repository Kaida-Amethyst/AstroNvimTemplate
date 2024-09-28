-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo(
    { { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } },
    true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"

-- local cmp_nvim_lsp = require "cmp_nvim_lsp"
require("mason-lspconfig").setup()

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.mbt",
  command = "set filetype=moonbit",
})

---@class ParserInfo
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.moonbit = {
  install_info = {
    url = "https://github.com/Kaida-Amethyst/tree-sitter-moonbit", -- local path or git repo
    files = { "src/parser.c", "src/scanner.c" },
    -- optional entries
    branch = "main",
  },
  filetype = "moonbit", -- if filetype does not match the parser name
}

local ft = require "Comment.ft"
ft.set("moonbit", "// %s")

-- require("lspconfig.util").clangd.setup {
--   on_attach = on_attach,
--   capabilities = cmp_nvim_lsp.default_capabilities(),
--   cmd = {
--     "clangd",
--     "--offset-encoding=UTF-16",
--   },
-- }
-- Custom Settings
vim.opt.wrap = true

-- 定义一个函数来处理 moonbit 文件的诊断信息
local function diagnose_moonbit()
  -- 获取当前文件的 filetype
  local filetype = vim.bo.filetype

  -- 如果 filetype 不是 moonbit，则直接返回
  if filetype ~= "moonbit" then return end

  -- 获取当前文件的路径
  local filepath = vim.fn.expand "%:p"

  -- 创建一个临时文件来存储 moon check 的输出
  local temp_file = os.tmpname()

  -- 调用 moon check --output-json 命令并将标准输出和标准错误重定向到临时文件
  local command = string.format("moon check --output-json &> %s", temp_file)
  local success, exit_code = pcall(vim.fn.system, command)
  -- if not success or exit_code ~= 0 then
  --     vim.notify("Failed to run moon check command", vim.log.levels.ERROR)
  --     os.remove(temp_file)  -- 删除临时文件
  --     return
  -- end

  -- 打开临时文件并逐行读取输出
  local file = io.open(temp_file, "r")
  if not file then
    vim.notify("Failed to open temporary file", vim.log.levels.ERROR)
    os.remove(temp_file) -- 删除临时文件
    return
  end

  -- 逐行读取输出并解析 JSON
  local diagnostics = {}
  for line in file:lines() do
    local ok, json_data = pcall(vim.json.decode, line)
    if ok and json_data["$message_type"] == "diagnostic" then
      -- 检查路径是否匹配
      if json_data.loc.path == filepath then
        -- 提取错误信息
        local level = json_data.level
        local start_line = json_data.loc.start.line
        local start_col = json_data.loc.start.col
        local end_line = json_data.loc["end"].line
        local end_col = json_data.loc["end"].col
        local message = json_data.message:match "^[^\n]+" -- 只取第一行

        -- 根据错误类型设置诊断信息的 severity
        local severity
        if level == "error" then
          severity = vim.diagnostic.severity.ERROR
        elseif level == "warning" then
          severity = vim.diagnostic.severity.WARN
        end

        -- 添加诊断信息
        table.insert(diagnostics, {
          lnum = start_line - 1,
          col = start_col - 1,
          end_lnum = end_line - 1,
          end_col = end_col,
          message = message,
          severity = severity,
        })
      end
    end
  end

  -- 关闭临时文件
  file:close()
  os.remove(temp_file) -- 删除临时文件

  -- 设置诊断信息
  vim.diagnostic.set(vim.api.nvim_create_namespace "moonbit_diagnostics", 0, diagnostics)

  -- 强制刷新显示
  vim.cmd "redraw"
end

-- 在文件保存时自动调用 diagnose_moonbit 函数
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
  pattern = "*.mbt",
  callback = diagnose_moonbit,
})

-- 定义高亮组
vim.cmd [[
highlight MoonbitError cterm=underline ctermfg=Red guifg=Red gui=underline
highlight MoonbitErrorVirtText ctermfg=Red guifg=Red
highlight MoonbitWarning cterm=underline ctermfg=Yellow guifg=Yellow gui=underline
highlight MoonbitWarningVirtText ctermfg=Yellow guifg=Yellow
]]
