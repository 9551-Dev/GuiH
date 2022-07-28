local api = require("util")
return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.reactive) ~= "boolean" then data.reactive = true end
    if type(data.blocking) ~= "boolean" then data.blocking = false end
    if type(data.always_update) ~= "boolean" then data.always_update = true end
    local base = {
        name=data.name or api.uuid4(),
        positioning = {
            x=data.x or 1,
            y=data.y or 1,
            width=data.width or 1,
            height=data.height or 1
        },
        visible=data.visible,
        reactive=data.reactive,
        react_to_events={["mouse_scroll"]=true},
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        value=data.value or 1,
        limit_min=data.limit_min or -math.huge,
        limit_max=data.limit_max or math.huge,
        on_change_value=data.on_change_value or function() end,
        on_up=data.on_up or function() end,
        on_down=data.on_down or function() end,
        blocking = data.blocking,
        always_update = data.always_update
    }
    return base
end