local api = require("GuiH.api")

return function(object,event)
    local term = object.canvas.term_object
    if event.name == "mouse_click" then
        if api.is_within_field(
            event.x,
            event.y,
            object.positioning.x,
            object.positioning.y,
            object.positioning.width+1,
            1
        ) then
            if object.selected then
                object.cursor_pos = math.min(object.cursor_pos + (event.x-object.cursor_x),#object.input)
            else
                object.on_change_select(object,event,true)
            end
            object.selected = true
        else
            if object.selected then object.on_change_select(object,event,false) end
            object.selected = false
        end
    end
    local a = object.input:sub(1,object.cursor_pos)
    local b = object.input:sub(object.cursor_pos+1,#object.input)
    if event.name == "char" and object.selected then
        if #object.input < object.char_limit then
            object.input = a..event.character..b
            object.cursor_pos = object.cursor_pos + 1
            object.on_change_input(object,event,object.input)
        end
    end
    if event.name == "key" and object.selected then
        if event.key == keys.backspace then
            object.input = a:gsub(".$","")..b
            object.cursor_pos = math.max(object.cursor_pos-1,0)
            object.on_change_input(object,event,object.input)
        end
        if event.key == keys.left then
            object.cursor_pos = math.max(object.cursor_pos-1,0)
        end
        if event.key == keys.right then
            object.cursor_pos = math.min(math.max(object.cursor_pos+1,0),#object.input)
        end
        if event.key == keys.tab and not object.ignore_tab then
            if #object.input < object.char_limit then
                object.input = a.."\t"..b
                object.cursor_pos = object.cursor_pos + 1
                object.on_change_input(object,event,object.input)
            end
        end
    end
end