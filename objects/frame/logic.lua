local api = require("GuiH.api")
return function(object,event,self)
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
    elseif event.name == "mouse_drag" and object.dragged and object.dragable then
        local wx,wy = object.window.getPosition()
        local ww,wh = object.window.getSize()
        local change_x,change_y = event.x-object.last_click.x,event.y-object.last_click.y
        if object.clear then
            for h=1,wh do
                local trm = object.canvas.term_object
                trm.setCursorPos(wx,h+wy-1)
                trm.write((" "):rep(ww))
            end
        end
        object.last_click = event
        local nx,ny = wx+change_x,wy+change_y
        if not object.on_move(object,{x=nx,y=ny}) then
            object.window.reposition(nx,ny)
        end
    end
end
