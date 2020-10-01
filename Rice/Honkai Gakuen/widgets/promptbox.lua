local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local prompt = "Run: "

local function prompt_prompt(prompt)
   return prompt
   :get_children()[1]
   :get_children()[1]
end

local function prompt_completion(prompt)
   return prompt
   :get_children()[1]
   :get_children()[2]
   :get_children()[1]
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
   local completion_command = "dmenu_path | grep -i '^" .. command .. "' | head -n 20"
   if command == '' then
      completion_text.markup = ""
      completion.bg = gears.color.transparent
      return
   end
   awful.spawn.easy_async_with_shell(completion_command, function(stdout, stderr)
      -- completion.bg = beautiful.shade
      if tostring(stderr) ~= "" then
         completion_text.markup = markup(tostring(stderr))
      else
         completion_text.markup = markup("  "..stdout)
      end
   end)
end

local function generate_completion(cmd, index)
   local execs = {}
   local count = 1
   if cmd == '' then return '' end
   local matchpattern = ".*"
   for c in cmd:gmatch(".") do
      matchpattern = matchpattern .. tostring(c) .. '.*'
   end
   index = index or 1
   local paths = os.getenv("PATH")
   local lfs = require("lfs")
   for path in string.gmatch(paths, "([^:]+)") do
      if pcall(function() lfs.dir(path) end) then
         for exec in lfs.dir(path) do
            if string.match(exec, matchpattern) then
               table.insert(execs, exec)
               count = count + 1
            end
            if count == 20 then
               return execs
            end
         end
      end
   end

   for i=1,#execs do
      for j=i+1,#execs do
         if execs[i] > execs[j] then
            local swap = execs[i]
            execs[i] = execs[j]
            execs[j] = swap
         end
      end
   end
   return execs
end

local function generate_markup(execs, index, trimindex)
   local markup = ''
   local trimindex = 1
   if #execs < 1 then return "" end
   if index < 1 or not index then return "" end
   if index > 10 then trimindex = index - 10 end
   for i=trimindex,index-1 do
      markup = markup .. beautiful.blacktext(execs[i]) .. '\n'
   end
   markup = markup .. tostring("<span stretch='ultraexpanded' color='".. beautiful.white .. "' background='".. beautiful.blue .."'>".. tostring(execs[index]) .."</span>")
   for i=index+1,#execs do
      markup =  markup .. "\n" .. beautiful.blacktext(execs[i])
   end
   return markup
end

local get_cmd = [[
   for p in $(echo $PATH | tr ':' '\n');
   do   
      if [ -d $p ]
         then
            find $p -type f -executable | awk -F '/' '{print $NF}'
         fi
   done | grep
]]

for s in screen do
   s.textbox = wibox.widget.textbox("")
   s.mypromptbox = awful.popup({
      shape = beautiful.common_shape(dpi(8)),
      widget = wibox.widget({
         {
            wibox.widget.textbox(""),
            {
               wibox.widget.textbox(""),
               layout = wibox.container.scroll.vertical,
               speed = 0,
            },
            layout = wibox.layout.fixed.vertical,
            forced_width = s.geometry.width/3,
            forced_height = s.geometry.height/3
         },
         margins = dpi(8),
         widget = wibox.container.margin,
      }),
      placement = awful.placement.centered,
      visible = false
   })
   s.mypromptbox.selection= 1
   s.mypromptbox.execs = {}

   function s.mypromptbox:run()
      s.mypromptbox.visible = true
      s.mypromptbox.ontop = true
      awful.prompt.run({
         textbox = prompt_prompt(s.mypromptbox.widget),
         done_callback = function()
            s.mypromptbox.visible = false
            prompt_completion(s.mypromptbox.widget).markup = ''
         end,
         changed_callback = function(cmd)
            s.mypromptbox.execs = {}
            local completion_command = "dmenu_path | grep -i '^" .. cmd .. "' | head -n 20"
            local markup = beautiful.blacktext
            local completion_widget = prompt_completion(s.mypromptbox.widget)
            s.mypromptbox.execs = generate_completion(cmd)
            if cmd == '' then prompt_completion(s.mypromptbox.widget).markup = '' return end
            if #s.mypromptbox.execs > 0 then
               if s.mypromptbox.selection < 1 then s.mypromptbox.selection = 1 end
               completion_widget.markup = generate_markup(s.mypromptbox.execs, s.mypromptbox.selection)
            else
               completion_widget.markup = ""
               -- s.mypromptbox.selection = -1
            end
         end,
         hooks = {
            {{}, "Return", function(cmd)
               if s.mypromptbox.selection > 0 then
                  awful.spawn(s.mypromptbox.execs[s.mypromptbox.selection])
               else
                  awful.spawn(cmd)
               end
            end},
            {{"Shift"}, "Return", function(cmd)
               if s.mypromptbox.selection > 0 then
                  awful.spawn("terminal -e " .. s.mypromptbox.execs[s.mypromptbox.selection])
               else
                  awful.spawn("terminal -e " .. cmd)
               end
            end},
         },
         keypressed_callback = function(mod, key, cmd)
            if key == 'Up' then
               if s.mypromptbox.selection > 0 then
                  s.mypromptbox.selection = s.mypromptbox.selection - 1
               end
            elseif key == 'Down' then
               if s.mypromptbox.selection < #s.mypromptbox.execs then
                  s.mypromptbox.selection = s.mypromptbox.selection + 1
               end
            elseif key == "Return" then
            elseif key == "BackSpace" then
               s.mypromptbox.selection = 1
            elseif string.match(key, "[a-zA-Z0-9]{1}") then
               s.mypromptbox.selection = 1
            end
         end,
         prompt = prompt,
      })
   end
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
-- awful.widget.prompt({
--    prompt = beautiful.bluetext("Run: "),
--    done_callback = function()
--       s.mypromptbox.visible = false
--       prompt_completion(s.mypromptbox.widget).markup = ''
--    end,
--    changed_callback = function(cmd)
--       local completion_command = "dmenu_path | grep -i '^" .. cmd .. "' | head -n 20"
--       local markup = beautiful.blacktext
--       local execs = generate_completion(cmd)
--       if cmd == '' then prompt_completion(s.mypromptbox.widget).markup = '' return end
--       -- prompt_completion(s.mypromptbox.widget).markup = generate_markup(execs, 2)
--    end,
--    prompt = prompt,
--    hook = {
--       {{"Shift"}, "Return", function(command)
--          notify({ text = command })
--       end},
--    },
-- }),
