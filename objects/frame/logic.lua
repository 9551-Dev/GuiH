local api = require("util")
return function(object,event)
    object.on_any(object,event)
    local x,y = object.window.getPosition()
    local dragger_x = object.dragger.x+x
    local dragger_y = object.dragger.y+y
    if event.name == "mouse_click" or event.name == "monitor_touch" then
        if api.is_within_field(
            event.x,
            event.y,
            dragger_x-1,
            dragger_y-1,
            object.dragger.width,
            object.dragger.height
        ) then
            object.dragged = true
            object.last_click = event
            object.on_select(object,event)
        end
    elseif event.name == "mouse_up" then
        object.dragged = false
        object.on_select(object,event)
    elseif event.name == "mouse_drag" and object.dragged and object.dragable then
        local wx,wy = object.window.getPosition()
        local change_x,change_y = event.x-object.last_click.x,event.y-object.last_click.y
        object.last_click = event
        local nx,ny = wx+change_x,wy+change_y
        if not object.on_move(object,{x=nx,y=ny}) then
            object.window.reposition(nx,ny)
        end
        local cx,cy = object.window.getPosition()
        local w,h = object.window.getSize()
        object.last_known_position = {
            x = cx,
            y = cy,
            width = w,
            height = h
        }
        object.positioning = {
            x = cx,
            y = cy,
            width = w,
            height = h
        }
    end
end
