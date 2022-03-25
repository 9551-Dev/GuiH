local texture = require("GuiH.texture-wrapper").code

return function(object)
    local term = object.canvas.term_object
    local x,y = object.positioning.x,object.positioning.y
    if not object.texture then
        term.setBackgroundColor(object.background_color)
        term.setTextColor(object.text_color)
        for i=y,object.positioning.height+y do
            term.setCursorPos(x,i)
            term.write(object.symbol:rep(object.positioning.width))
        end
    else
        local bg_layers = {}
        local fg_layers = {}
        local text_layers = {}
        for yis=1,object.positioning.height do
            for xis=1,object.positioning.width do
                local pixel = texture.get_pixel(xis,yis,object.texture,false)
                if pixel then
                    bg_layers[yis] = (bg_layers[yis] or "")..texture.to_blit[pixel.background_color]
                    fg_layers[yis] = (fg_layers[yis] or "")..texture.to_blit[pixel.text_color]
                    text_layers[yis] = (text_layers[yis] or "")..pixel.symbol
                else
                    bg_layers[yis] = (bg_layers[yis] or "")..texture.to_blit[object.background_color]
                    fg_layers[yis] = (fg_layers[yis] or "")..texture.to_blit[object.text_color]
                    text_layers[yis] = (text_layers[yis] or "").." "
                end
            end
        end
        for k,v in pairs(bg_layers) do
            term.setCursorPos(x,y+k-1)
            term.blit(text_layers[k],fg_layers[k],bg_layers[k])
        end
    end
    if object.text then
        if object.text.centered then
            local centered_y = y+object.positioning.height/2
            local centered_x = x+object.positioning.width/2-(#object.text.text/2)
            term.setCursorPos(math.ceil(centered_x+object.text.offset_x),math.floor(centered_y)+object.text.offset_y)
        else
            term.setCursorPos(x+object.text.offset_x,y+object.text.offset_y)
        end
        if (#object.text.blit[1]+#object.text.blit[2])/2 == #object.text.text then
            term.blit(object.text.text,object.text.blit[1],object.text.blit[2])
        else
            term.setBackgroundColor(object.background_color)
            term.setTextColor(object.text_color)
            term.write(object.text.text)
        end
    end
end