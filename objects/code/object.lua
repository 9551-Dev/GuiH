local api = require("GuiH.api")
return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.reactive) ~= "boolean" then data.reactive = true end
    local base = {
        name=data.name or api.uuid4(),
        visible=data.visible,
        code=data.code or function() return false end,
        graphic=data.graphic or function() return false end,
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
    }
    return base
end
