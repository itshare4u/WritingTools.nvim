local cmp = require('cmp')
local Job = require('plenary.job')

local source = {}

source.new = function(config)
  return setmetatable({
    trigger_characters = config.trigger_characters,
    default_prompt = config.default_prompt,
    icon = config.icon,
    priority = config.priority,
    highlight = config.highlight,
  }, { __index = source })
end

source.get_trigger_characters = function(self)
  return self.trigger_characters
end

source.is_available = function()
  return true
end

source.complete = function(self, request, callback)
  local text_before_cursor = request.context.cursor_before_line
  local match = nil

  for _, trigger_char in ipairs(self.trigger_characters) do
    local pattern = string.format("%s%s(.+)$", vim.pesc(trigger_char), "%s*")
    match = text_before_cursor:match(pattern)
    if match then break end
  end

  if not match then
    callback({ items = {}, isIncomplete = false })
    return
  end

  local prompt = self.default_prompt .. match

  Job:new({
    command = 'curl',
    args = {
      '-X', 'POST',
      '-H', 'Authorization: Bearer <YOUR_API_KEY>',
      '-H', 'Content-Type: application/json',
      '-d', string.format('{"prompt": "%s"}', prompt),
      'https://api.github-copilot.com/v1/completions',
    },
    on_exit = function(job, return_val)
      if return_val ~= 0 then
        callback({ items = {}, isIncomplete = false })
        return
      end

      local result = table.concat(job:result(), '\n')
      local suggestions = {}

      for suggestion in result:gmatch('"(.-)"') do
        table.insert(suggestions, {
          label = suggestion,
          insertText = suggestion,
          kind = cmp.lsp.CompletionItemKind.Snippet,
          documentation = {
            kind = 'markdown',
            value = "Generated by GitHub Copilot",
          },
          source = {
            name = "copilot_custom",
            icon = self.icon,
            priority = self.priority,
          },
        })
      end

      callback({ items = suggestions, isIncomplete = false })
    end,
  }):start()
end

return source
