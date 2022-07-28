local api = require("util")
return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.reactive) ~= "boolean" then data.reactive = true end
    if type(data.blocking) ~= "boolean" then data.blocking = false end
    if type(data.always_update) ~= "boolean" then data.always_update = false end
    local base = {
        name=data.name or api.uuid4(),
        visible=data.visible,
        text=data.text or object.text{text="none",x=1,y=1,bg=colors.red,fg=colors.white},
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        update=data.update or function() end,
        blocking = data.blocking,
        always_update = data.always_update
    }
    return base
end
