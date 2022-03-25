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
    if object.text or object.text_on then
        local text = (object.value and object.text_on or object.text)
        if text.centered then
            local centered_y = y+object.positioning.height/2
            local centered_x = x+object.positioning.width/2-(#text.text/2)
            term.setCursorPos(math.ceil(centered_x+text.offset_x),math.floor(centered_y)+text.offset_y)
        else
            term.setCursorPos(x+text.offset_x,y+text.offset_y)
        end
        if (#text.blit[1]+#text.blit[2])/2 == #text.text then
            term.blit(text.text,text.blit[1],text.blit[2])
        else
            term.setBackgroundColor(object.value and object.background_color_on or object.background_color)
            term.setTextColor(object.value and object.text_color_on or object.text_color)
            term.write(text.text)
        end
    end
end