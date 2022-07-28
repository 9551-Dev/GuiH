local api = require("util")
local main = require("core.gui_object")

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
        visible=data.visible,
        last_known_position={
            x=data.x or 1,
            y=data.y or 1,
            width=data.width or 0,
            height=data.height or 0
        },
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        bef_draw=data.bef_draw or function() end,
        blocking = data.blocking,
        always_update = data.always_update
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
    btn.gui.inherit(object,btn)
    return btn
end