local main = require("guiH.a-tools.gui_object")

return function(object,data)
    data = data or {}
    local btn = setmetatable({
        canvas=object,
        name=data.name or "",
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
        on_move=data.on_move or function() end,
        on_select=data.on_select or function() end,
        on_any=data.on_any or function() end,
        on_graphic=data.on_graphic or function() end
    },{
        __index = {
            logic=require("GuiH.objects.frame.logic"),
            graphic=require("GuiH.objects.frame.graphic")
        }
    })
    local window = window.create(
        btn.canvas.term_object,
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
    object.gui.frame[btn.name] = btn
    return btn
end
