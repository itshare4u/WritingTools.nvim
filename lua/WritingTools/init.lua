local config = require("WritingTools.config")
local source = require("WritingTools.source")

local M = {}

M.setup = function(user_config)
  local final_config = config.merge(user_config)

  if final_config.highlight then
    for name, opts in pairs(final_config.highlight) do
      vim.api.nvim_set_hl(0, "CmpItem" .. name:gsub("^%l", string.upper) .. "WritingTools", opts)
    end
  end

  require('cmp').register_source('WritingTools', source.new(final_config))
end

return M
