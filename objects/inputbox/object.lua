return function(object,data)
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.reactive) ~= "boolean" then data.reactive = true end
    local btn = {
        name=data.name or "",
        visible=data.visible,
        reactive=data.reactive,
        react_to_events={
            ["mouse_click"]=true,
            ["monitor_touch"]=true,
            ["char"]=true,
            ["key"]=true,
            ["key_up"]=true,
            ["paste"]=true
        },
        positioning = {
            x=data.x or 1,
            y=data.y or 1,
            width=data.width or 0,
        },
        pattern=data.pattern or ".",
        selected=data.selected or false,
        insert=false,
        ctrl=false,
        btn=data.btn,
        cursor_pos=data.cursor_pos or 0,
        char_limit = data.char_limit or data.width or math.huge,
        input="",
        background_color = data.background_color or object.term_object.getBackgroundColor(),
        text_color = data.text_color or object.term_object.getTextColor(),
        order = data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        shift=0,
        background_symbol=data.background_symbol or " ",
        on_change_select=data.on_change_select or function() end,
        on_change_input=data.on_change_input or function() end,
        replace_char=data.replace_char,
        ignore_tab = data.ignore_tab
    }
    btn.cursor_x = btn.positioning.x
    return btn
end