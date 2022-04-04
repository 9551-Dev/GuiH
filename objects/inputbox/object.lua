return function(object,data)
    local btn = {
        name=data.name or "",
        visible=(data.visible ~= nil) and data.visible or true,
        reactive=(data.reactive ~= nil) and data.reactive or true,
        react_to_events={
            ["mouse_click"]=true,
            ["monitor_touch"]=true,
            ["char"]=true,
            ["key"]=true,
        },
        positioning = {
            x=data.x or 1,
            y=data.y or 1,
            width=data.width or 0,
        },
        selected=data.selected or false,
        btn=data.btn,
        cursor_pos=data.cursor_pos or 0,
        char_limit = data.char_limit or data.width or math.huge,
        input="",
        background_color = data.background_color or object.term_object.getBackgroundColor(),
        text_color = data.text_color or object.term_object.getTextColor(),
        order = data.order or 1,
        shift=0,
        background_symbol=data.background_symbol or " ",
        on_change_select=data.on_change_select or function() end,
        on_change_input=data.on_change_input or function() end
    }
    btn.cursor_x = btn.positioning.x
    return btn
end