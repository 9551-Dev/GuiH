local texture = require("graphic_handle").code

return function(object)
    local term = object.canvas.term_object
    local x,y = object.positioning.x,object.positioning.y
    if not object.texture then

        --* draw a colored box for the button
        term.setBackgroundColor(object.background_color)
        term.setTextColor(object.text_color)
        for i=y,object.positioning.height+y-1 do
            term.setCursorPos(x,i)
            term.write(object.symbol:rep(object.positioning.width))
        end
    else

        --* draw the texture for the button
        texture.draw_box_tex(
            term,
            object.texture,
            x,y,object.positioning.width,object.positioning.height,
            object.background_color,object.text_color,nil,nil,object.canvas.texture_cache
        )
    end
    if object.text then

        --* draw the text for the button
        object.text(term,object.positioning.x,object.positioning.y,object.positioning.width,object.positioning.height)
    end
end