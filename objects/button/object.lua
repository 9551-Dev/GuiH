local api = require("util")

return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.reactive) ~= "boolean" then data.reactive = true end
    if type(data.blocking) ~= "boolean" then data.blocking = true end
    if type(data.always_update) ~= "boolean" then data.always_update = false end
    local btn = {
        name=data.name or api.uuid4(),
        positioning = {
            x=data.x or 1,
            y=data.y or 1,
            width=data.width or 0,
            height=data.height or 0
        },
        on_click=data.on_click or function() end,
        background_color = data.background_color or object.term_object.getBackgroundColor(),
        text_color = data.text_color or object.term_object.getTextColor(),
        symbol=data.symbol or " ",
        texture = data.tex,
        text=data.text,
        visible=data.visible,
        reactive=data.reactive,
        react_to_events={
            mouse_click=true,
            monitor_touch=true,
        },
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        tags={},
        btn=data.btn,
        value=(data.value ~= nil) and data.value or true,
        blocking = data.blocking,
        always_update = data.always_update
    }
    return btn
end
