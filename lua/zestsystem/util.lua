local M = {}

function M.optional_require(name)
  local ok, mod = pcall(require, name)
  if ok then
    return mod
  end

  vim.schedule(function()
    vim.notify(
      ("Skipping optional plugin '%s': %s"):format(name, mod),
      vim.log.levels.WARN,
      { title = "zestsystem.nvim" }
    )
  end)

  return nil
end

return M
