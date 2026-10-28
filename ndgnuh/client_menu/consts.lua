local m = {}

m.OPTION_ONTOP = "ontop"
m.OPTION_STICKY = "sticky"
m.OPTION_FLOATING = "floating"
m.OPTION_MAXIMIZED = "maximized"
m.OPTION_MINIMIZED = "minimized"
m.OPTION_FULLSCREEN = "fullscreen"
m.OPTION_BAMBOO_INPUT = "bamboo-input-mode"
m.OPTION_CANCEL = "cancel"

-- Bamboo input modes, from bamboo-cli
m.BAMBOO_MODE_PREEDIT = "preedit"
m.BAMBOO_MODE_SURROUNDING_TEXT = "surrounding-text"
m.BAMBOO_MODE_FORWARD_KEY_1 = "forward-key-1"
m.BAMBOO_MODE_FORWARD_KEY_2 = "forward-key-2"
m.BAMBOO_MODE_FORWARD_AS_COMMIT = "forward-as-commit"
m.BAMBOO_MODE_XTEST = "xtest"
m.BAMBOO_MODE_EXCLUDE = "exclude"

-- Ordered so that the position matches bamboo-cli's mode index
m.bamboo_modes = {
	m.BAMBOO_MODE_PREEDIT,
	m.BAMBOO_MODE_SURROUNDING_TEXT,
	m.BAMBOO_MODE_FORWARD_KEY_1,
	m.BAMBOO_MODE_FORWARD_KEY_2,
	m.BAMBOO_MODE_FORWARD_AS_COMMIT,
	m.BAMBOO_MODE_XTEST,
	m.BAMBOO_MODE_EXCLUDE,
}

m.bamboo_modes_to_indices = {}
for i, mode in ipairs(m.bamboo_modes) do
	m.bamboo_modes_to_indices[mode] = i
end

m.bamboo_modes_to_descriptions = {
	[m.BAMBOO_MODE_PREEDIT] = "Cấu hình mặc định (Pre-edit)",
	[m.BAMBOO_MODE_SURROUNDING_TEXT] = "Sửa lỗi gạch chân (Surrounding Text)",
	[m.BAMBOO_MODE_FORWARD_KEY_1] = "Sửa lỗi gạch chân (ForwardKeyEvent I)",
	[m.BAMBOO_MODE_FORWARD_KEY_2] = "Sửa lỗi gạch chân (ForwardKeyEvent II)",
	[m.BAMBOO_MODE_FORWARD_AS_COMMIT] = "Sửa lỗi gạch chân (Forward as commit)",
	[m.BAMBOO_MODE_XTEST] = "Sửa lỗi gạch chân (XTestFakeKeyEvent)",
	[m.BAMBOO_MODE_EXCLUDE] = "Thêm vào danh sách loại trừ",
}

m.options = {
	m.OPTION_ONTOP,
	m.OPTION_STICKY,
	m.OPTION_FLOATING,
	m.OPTION_MAXIMIZED,
	m.OPTION_MINIMIZED,
	m.OPTION_FULLSCREEN,
	m.OPTION_BAMBOO_INPUT,
	m.OPTION_CANCEL,
}

m.options_to_titles = {
	[m.OPTION_ONTOP] = "On-top",
	[m.OPTION_STICKY] = "Sticky",
	[m.OPTION_FLOATING] = "Floating",
	[m.OPTION_MAXIMIZED] = "Maximized",
	[m.OPTION_MINIMIZED] = "Minimized",
	[m.OPTION_FULLSCREEN] = "Fullscreen",
	[m.OPTION_CANCEL] = "Cancel",
	[m.OPTION_BAMBOO_INPUT] = "Input mode (Ibus Bamboo)",
}

m.options_to_subtitles = {
	[m.OPTION_ONTOP] = "Toggle on-top property of client",
	[m.OPTION_STICKY] = "Toggle sticky property of client",
	[m.OPTION_FLOATING] = "Toggle floating property of client",
	[m.OPTION_MAXIMIZED] = "Toggle maximized property of client",
	[m.OPTION_MINIMIZED] = "Toggle minimized property of client",
	[m.OPTION_FULLSCREEN] = "Toggle fullscreen property of client",
	[m.OPTION_CANCEL] = "Close this menu",
	[m.OPTION_BAMBOO_INPUT] = "Select IBus Bamboo input mode",
}

return m
