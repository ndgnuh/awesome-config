local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local prompt = "  Run: "

local function prompt_prompt(prompt)
   return prompt
   :get_children()[1]
   :get_children()[1]
   :get_children()[1]
   :get_children()[2]
end

local function prompt_text(prompt)
   return prompt
   :get_children()[1]
   :get_children()[1]
   :get_children()[1]
   :get_children()[1]
end

local function prompt_bg(prompt)
   return prompt
   :get_children()[1]
   :get_children()[1]
end

local completion = wibox.widget({
   bg = gears.color.transparent,
   shape = beautiful.common_shape(dpi(8)),
   widget = wibox.container.background,
   wibox.widget.textbox(""),
})

local completion_text = completion:get_children()[1]

local function changed_callback(command)
   local markup = beautiful.whitetext
   local completion_command = "dmenu_path | grep -i '^" .. command .. "' | head -n 20 | tr '\\n' ' '"
   if command == '' then
      completion_text.markup = ""
      completion.bg = gears.color.transparent
      return
   end
   awful.spawn.easy_async_with_shell(completion_command, function(stdout, stderr)
      completion.bg = beautiful.shade
      if tostring(stderr) ~= "" then
         completion_text.markup = markup(tostring(stderr))
      else
         completion_text.markup = markup("  "..stdout)
      end
   end)
end

for s in screen do
   s.mypromptbox = wibox.widget({
      widget = wibox.container.margin,
      margins = {
         top = beautiful.useless_gap,
         left = beautiful.taglist_spacing,
         right = beautiful.taglist_spacing,
         bottom = beautiful.useless_gap,
      },
      {
         layout = wibox.layout.flex.vertical,
         spacing = dpi(4),
         {
            bg = beautiful.shade,
            shape = beautiful.common_shape(dpi(8)),
            widget = wibox.container.background,
            {
               layout = wibox.layout.align.horizontal,
               wibox.widget.textbox(beautiful.whitetext(prompt)),
               awful.widget.prompt({
                  prompt = "",
                  changed_callback = changed_callback,
                  done_callback = function() s.mypromptbox:dismiss() end
               }), -- awful.widget.prompt,
               nil,
            }, -- wibox.layout.align,
         }, -- wibox.container.background,
         completion,
      } -- wibox.layout.flex
   }) -- s.mypromptbox

   function s.mypromptbox:run()
      prompt_prompt(self):run()
      prompt_bg(self).bg = beautiful.white
      prompt_text(self).markup = beautiful.bluetext(prompt)
      completion_text.markup = ""
   end

   function s.mypromptbox:dismiss()
      prompt_bg(self).bg = beautiful.shade
      prompt_text(self).markup = beautiful.whitetext(prompt)
      completion_text.markup = ""
      completion.bg = gears.color.transparent
   end

   s.mypromptbox:buttons(gears.table.join(
      awful.button({}, 1, function() s.mypromptbox:run() end),
      awful.button({}, 3, function() s.mypromptbox:run() end)
   ))
end
--
-- notify({
--    timeout = 0,
--    text = gears.debug.dump_return(s.mypromptbox
--    :get_children()[1]
--    :get_children()[1]
--    :get_children()[1]
--    :get_children())
-- })
-- for word in string.gmatch(command, "([^ ]+)") do
--    completion_command = completion_command .. " | grep " .. word
-- end
-- completion_command = completion_command .. " | head -n 20"
-- completion.markup = beautiful.blacktext("  "..completion_command)
