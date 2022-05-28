local texture = require("graphic_handle").code

return function(object)
    local term = object.canvas.term_object
    local x,y = object.positioning.x,object.positioning.y
    if not object.texture and not object.texture_on then
        term.setBackgroundColor(object.value and object.background_color_on or object.background_color)
        term.setTextColor(object.value and object.text_color_on or object.text_color)
        for i=y,object.positioning.height+y-1 do
            term.setCursorPos(x,i)
            term.write(object.symbol:rep(object.positioning.width))
        end
    else
        texture.draw_box_tex(
            term,
            (object.value and object.texture_on or object.texture) or (object.texture or object.texture_on),
            object.positioning.x,
            object.positioning.y,
            object.positioning.width,
            object.positioning.height,
            (object.value and object.background_color_on or object.background_color) or colors.red,
            (object.value and object.text_color_on or object.text_color) or colors.black,nil,nil,
            object.canvas.texture_cache
        )
    end
    if object.text and ((not object.value ) or not object.text_on) then
        object.text(term,object.positioning.x,object.positioning.y,object.positioning.width,object.positioning.height)
    elseif object.text_on and object.value then
        object.text_on(term,object.positioning.x,object.positioning.y,object.positioning.width,object.positioning.height)
    end
end
