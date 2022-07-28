local api = require("util")

return function(object,data)
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.reactive) ~= "boolean" then data.reactive = true end
    if not data.autoc then data.autoc = {} end
    if type(data.autoc.put_space) ~= "boolean" then data.autoc.put_space = true end
    if type(data.blocking) ~= "boolean" then data.blocking = true end
    if type(data.always_update) ~= "boolean" then data.always_update = false end
    local btn = {
        name=data.name or api.uuid4(),
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
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        shift=0,
        space_symbol=data.space_symbol or "\175",
        background_symbol=data.background_symbol or " ",
        on_change_select=data.on_change_select or function() end,
        on_change_input=data.on_change_input or function() end,
        on_enter=data.on_enter or function() end,
        replace_char=data.replace_char,
        ignore_tab = data.ignore_tab,
        autoc={
            strings=data.autoc.strings or {},
            spec_strings=data.autoc.spec_strings or {},
            bg=data.autoc.bg or data.background_color or object.term_object.getBackgroundColor(),
            fg=data.autoc.fg or data.text_color or object.term_object.getTextColor(),
            current="",
            selected=1,
            put_space=data.autoc.put_space
        },
        blocking = data.blocking,
        always_update = data.always_update
    }
    btn.cursor_x = btn.positioning.x
    return btn
end