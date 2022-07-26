local api = require("api")
return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.reactive) ~= "boolean" then data.reactive = true end
    local base = {
        name=data.name or api.uuid4(),
        visible=data.visible,
        text=data.text or object.text{text="none",x=1,y=1,bg=colors.red,fg=colors.white},
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        update=data.update or function() end
    }
    return base
end
