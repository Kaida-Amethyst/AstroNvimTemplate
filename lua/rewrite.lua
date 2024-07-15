local function rewrite_register()
  -- 读取 @c 寄存器内容
  local input = vim.fn.getreg "c"

  -- 构建执行命令字符串
  local command = "rewriter -c '" .. input .. "'"

  vim.api.nvim_echo({ { command, "" } }, false, {})

  -- 执行命令，并获取输出
  local handle = io.popen(command, "r")
  local output = handle:read "*a" -- 读取所有输出
  handle:close()

  -- 存储输出到 @d 寄存器
  vim.fn.setreg("d", output)
end

return rewrite_register
