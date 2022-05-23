local api = require("api")
local main = require("a-tools.gui_object")

return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.reactive) ~= "boolean" then data.reactive = true end
    local btn = {
        name=data.name or api.uuid4(),
        positioning = {
            x=data.x or 1,
            y=data.y or 1,
            width=data.width or 0,
            height=data.height or 0
        },
        visible=data.visible,
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        dragable=data.draggable,
        bef_draw=data.bef_draw or function() end
    }
    local window = window.create(
        object.term_object,
        btn.positioning.x,
        btn.positioning.y,
        btn.positioning.width,
        btn.positioning.height
    )
    btn.gui = main(window,object.term_object,object.log)
    btn.window = window
    return btn
end
