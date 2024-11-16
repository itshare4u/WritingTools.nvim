local M = {}

-- Cấu hình mặc định
M.defaults = {
	trigger_characters = { "/r", "/c" },
	default_prompt = "Rewrite the sentence: ",
	icon = "",
	priority = 100, -- Độ ưu tiên
	highlight = { -- Màu sắc tùy chỉnh
		kind = { fg = "#ffd700", bold = true },
		menu = { fg = "#87ceeb", italic = true },
	},
}

-- Hàm merge config
M.merge = function(user_config)
	return vim.tbl_deep_extend("force", M.defaults, user_config or {})
end

return M
