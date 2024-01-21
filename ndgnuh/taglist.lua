local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local capi = { screen = screen } -- luacheck: ignore

-- this module contain the specialized taglist
-- this task list does not contains anything but the background
-- it is displayed as a thin line at the top of the screen
local m = {}
local height = beautiful.xresources.apply_dpi(4)

--- Create the item callback
-- Screen is passed in to get the total width
--- @param screen table: the screen object
--- @return function: the callback for taglist item creation and update
local create_callback = function(screen)
    --- Item update/create callback
    --- @param tagitem table: the taglist widget
    --- @param tag table: the tag object
    --- @param index number: the index of the tag object
    --- @param tags table: the list of all tag objects
    return function(tagitem, tag, index, tags) --luacheck: no unused args
        local num_tags = #tags
        local screen_width = screen.geometry.width - screen.geometry.x
        tagitem.forced_width = screen_width / num_tags
    end
end

--- Taglist buttons
local buttons = awful.button({}, 1, function(t) t:view_only() end)

--- Create taglist item template
--- @param screen screen: the screen object
--- @return table: the widget template for awful.widget.taglist
local create_template = function(screen)
    return {
        wibox.widget.textbox(""), -- awesome stable needs this to show bg
        id = 'background_role',
        widget = wibox.container.background,
        forced_width = nil, -- to be set
        create_callback = create_callback(screen),
        update_callback = create_callback(screen),
    }
end

--- Setup the taglist
-- The argument in for this function must be passed as a table
--- @param screen screen: the screen object
m.setup = function(args)
    local screen = args.screen

    --- create the taglist
    local taglist = awful.widget.taglist {
        screen = screen,
        buttons = buttons,
        filter = awful.widget.taglist.filter.all,
        widget_template = create_template(screen),
    }

    --- create a wibar to display the tag list
    local wibar = awful.wibar {
        height = height,
        stretch = true,
        position = "top",
        screen = screen,
    }

    --- setup everything
    wibar:setup { taglist, widget = wibox.layout.flex.horizontal }
    capi.screen.connect_signal("tag::history::update", function(updated_screen)
        local num_tags = #updated_screen.tags
        if num_tags == 1 or updated_screen.selected_tag == nil then
            wibar.visible = false
        else
            wibar.visible = true
        end
    end)

    return wibar
end

return m
