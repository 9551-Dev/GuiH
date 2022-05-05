local texture = require("GuiH.texture-wrapper").code

return function(object)
    local term = object.canvas.term_object
    local x,y = object.positioning.x,object.positioning.y
    if not object.texture or not object.texture_on then
        term.setBackgroundColor(object.value and object.background_color_on or object.background_color)
        term.setTextColor(object.value and object.text_color_on or object.text_color)
        for i=y,object.positioning.height+y-1 do
            term.setCursorPos(x,i)
            term.write(object.symbol:rep(object.positioning.width))
        end
    else
        local bg_layers = {}
        local fg_layers = {}
        local text_layers = {}
        for yis=1,object.positioning.height do
            for xis=1,object.positioning.width do
                local pixel = texture.get_pixel(xis,yis,object.value and object.texture_on or object.texture,false)
                if pixel then
                    bg_layers[yis] = (bg_layers[yis] or "")..texture.to_blit[pixel.background_color]
                    fg_layers[yis] = (fg_layers[yis] or "")..texture.to_blit[pixel.text_color]
                    text_layers[yis] = (text_layers[yis] or "")..pixel.symbol
                else
                    bg_layers[yis] = (bg_layers[yis] or "")..texture.to_blit[object.value and object.background_color_on or object.background_color]
                    fg_layers[yis] = (fg_layers[yis] or "")..texture.to_blit[object.value and object.text_color_on or object.text_color]
                    text_layers[yis] = (text_layers[yis] or "").." "
                end
            end
        end
        for k,v in pairs(bg_layers) do
            term.setCursorPos(x,y+k-1)
            term.blit(text_layers[k],fg_layers[k],bg_layers[k])
        end
    end
    if object.text and not object.value then
        object.text(term,object.positioning.x,object.positioning.y,object.positioning.width,object.positioning.height)
    elseif object.text_on and object.value then
        object.text_on(term,object.positioning.x,object.positioning.y,object.positioning.width,object.positioning.height)
    end
