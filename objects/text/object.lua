local api = require("GuiH.api")
return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.reactive) ~= "boolean" then data.reactive = true end
    local base = {
        name=data.name or api.uuid4(),
        visible=data.visible,
        text=data.text or {text="none",x=1,y=1,offset_x=0,offset_y=0,blit={"0000","eeee"}},
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
    }
    return base
end