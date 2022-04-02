local main = require("GuiH.a-tools.gui_object")

return function(object,data)
    data = data or {}
    if data.clear == nil then data.clear = true end
    local btn = {
        name=data.name or tostring(os.epoch("utc")),
        positioning = {
            x=data.x or 1,
            y=data.y or 1,
            width=data.width or 0,
            height=data.height or 0
        },
        visible=(data.visible ~= nil) and data.visible or true,
        reactive=(data.reactive ~= nil) and data.reactive or true,
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
        btn=data.btn,
        dragable=data.dragable or true,
        on_move=data.on_move or function() end,
        on_select=data.on_select or function() end,
        on_any=data.on_any or function() end,
        on_graphic=data.on_graphic or function() end,
        clear=data.clear
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
    btn.child = main(window)
    btn.window = window
    return btn
end
