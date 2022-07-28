local api = require("util")
return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.reactive) ~= "boolean" then data.reactive = true end
    if type(data.blocking) ~= "boolean" then data.blocking = false end
    if type(data.always_update) ~= "boolean" then data.always_update = true end
    local base = {
        name=data.name or api.uuid4(),
        visible=data.visible,
        reactive=data.reactive,
        code=data.code or function() return false end,
        graphic=data.graphic or function() return false end,
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        react_to_events={
            mouse_click=true,
            mouse_drag=true,
            monitor_touch=true,
            mouse_scroll=true,
            mouse_up=true,
            key=true,
            key_up=true,
            char=true,
            paste=true
        },
        blocking = data.blocking,
        always_update = data.always_update
    }
    return base
end
