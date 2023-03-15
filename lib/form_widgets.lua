local awful = require("awful")

local beautiful = require("beautiful")

local widget = require("wibox.widget")
local container = require("wibox.container")
local layout = require("wibox.layout")

local gears = require("gears")

local shape = require("gears.shape")
local color = require("gears.color")

local capi = {
    awesome = awesome,
    root = root,
    client = client
}

local theme = {}
local global_lock = false -- ensure only 1 prompt is running at a time

local function text_field(args)
	local label = args.label
	local value = tostring(args.value) or ""
    local callback = args.callback or function(...) end
    local forced_width = args.width

    local w_label = widget.textbox(label)
    local w_input = widget.textbox(value)


    w_input:connect_signal("button::press", function(self)
        if self.running or global_lock then
            return
        end
        self.running = true
        global_lock = true
        awful.prompt.run{
            textbox = self,
            text = self:get_text(),
            prompt = "",
            exe_callback = function(txt)
                callback(txt)
                self:set_text(txt)
                self.running = false
                global_lock = false
            end
        }
    end)

    local w_tfield = widget {
        widget = layout.flex.horizontal,
        forced_width = forced_width,
        w_label,
        -- widget.textbox(":"),
        w_input,
        nil,
    }
    w_tfield.label = w_label
    w_tfield.input = w_input

    return w_tfield
end

local function list_inputs(inputs)
    local hspacing = 20
    local col1 = layout.fixed.vertical()
    local col2 = layout.fixed.vertical()
    for _, field in ipairs(inputs) do
        col1:add(field.label)
        col2:add(field.input)
    end

    local w = widget {
        widget = layout.fixed.horizontal,
        spacing = hspacing,
        col1,
        col2
    }
    return w
end

-- local w = awful.popup{
--     x = 0,
--     y = 0,
--     -- width = 400,
--     -- height = 200,
--     bg = "#323251",
--     visible = true,
--     ontop = true,
--     widget = widget{
--         widget = container.background,
--         {
--             widget = layout.fixed.vertical,
--             widget.textbox("<b># Commands</b>"),
--             list_inputs{
--                 text_field{ label = "Terminal", value = "qterminal", callback = ic, width=500},
--                 text_field{ label = "Calendar", value = "gsimplecal", width=500},
--                 text_field{ label = "Run", value = "rofi -show run", },
--             }
--         }
--     }
-- }


return {
    list_inputs = list_inputs,
    text_field = text_field,
    text_input = text_field,
}
