local api = require("GuiH.api")
local main = require("GuiH.a-tools.gui_object")

return function(object,data)
    data = data or {}
    if type(data.clear) ~= "boolean" then data.clear = true end
    if type(data.draggable) ~= "boolean" then data.draggable = true end
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
        reactive=data.reactive,
        react_to_events={
            mouse_drag=true,
            mouse_click=true,
            mouse_up=true
        },
        dragged=false,
        dragger=data.dragger,
        last_click={
            x=1,
            y=1
        },
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        btn=data.btn,
        dragable=data.draggable,
        on_move=data.on_move or function() end,
        on_select=data.on_select or function() end,
        on_any=data.on_any or function() end,
        on_graphic=data.on_graphic or function() end,
        on_deselect=data.on_deselect or function() end
    }
    local window = window.create(
        object.term_object,
        btn.positioning.x,
        btn.positioning.y,
        btn.positioning.width,
        btn.positioning.height
    )
    if not btn.dragger then
        btn.dragger = {
            x=1,
            y=1,
            width=btn.positioning.width,
            height=1
        }
    end
    btn.child = main(window,object.term_object,object.log)
    btn.window = window
    return btn
end
