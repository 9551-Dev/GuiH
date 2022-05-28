local graphic = require("graphic_handle")

return function(object)
    local term = object.canvas.term_object
    local pointValue = math.floor(math.max(math.min(object.positioning.width*(object.value/100),object.positioning.width),0))
    local left = math.ceil(math.min(math.max(object.positioning.width-pointValue,0),object.positioning.width))
    if object.direction == "left-right"  then
        if not object.texture then
            for y=object.positioning.y,object.positioning.height+object.positioning.y-1 do
                term.setCursorPos(object.positioning.x,y)
                term.blit(
                    (" "):rep(pointValue)..(" "):rep(left),
                    ("f"):rep(pointValue)..("f"):rep(left),
                    graphic.code.to_blit[object.fg]:rep(pointValue)..graphic.code.to_blit[object.bg]:rep(left)
                )
            end
        else
            if not object.drag_texture then
                graphic.code.draw_box_tex(
                    term,
                    object.texture,
                    object.positioning.x,
                    object.positioning.y,
                    pointValue,
                    object.positioning.height,object.bg,object.fg,
                    object.tex_offset_x,
                    object.tex_offset_y,
                    object.canvas.texture_cache
                )
            else
                graphic.code.draw_box_tex(
                    term,
                    object.texture,
                    object.positioning.x,
                    object.positioning.y,
                    pointValue,
                    object.positioning.height,object.bg,object.fg,
                    -pointValue+1+object.tex_offset_x,
                    object.tex_offset_y,
                    object.canvas.texture_cache
                )
            end
            for y=object.positioning.y,object.positioning.height+object.positioning.y-1 do
                term.setCursorPos(object.positioning.x+pointValue,y)
                term.blit(
                    (" "):rep(left),
                    ("f"):rep(left),
                    graphic.code.to_blit[object.bg]:rep(left)
                )
            end
        end
    end
    if object.direction == "right-left" then
        if not object.texture then
            for y=object.positioning.y,object.positioning.height+object.positioning.y-1 do
                term.setCursorPos(object.positioning.x,y)
                term.blit(
                    (" "):rep(left)..(" "):rep(pointValue),
                    ("f"):rep(left)..("f"):rep(pointValue),
                    graphic.code.to_blit[object.bg]:rep(left)..graphic.code.to_blit[object.fg]:rep(pointValue)
                )
            end
        else
            if object.drag_texture then
                graphic.code.draw_box_tex(
                    term,
                    object.texture,
                    object.positioning.x+object.positioning.width-pointValue,
                    object.positioning.y,
                    pointValue,
                    object.positioning.height,object.bg,object.fg,
                    object.tex_offset_x,
                    object.tex_offset_y,
                    object.canvas.texture_cache
                )
            else
                graphic.code.draw_box_tex(
                    term,
                    object.texture,
                    object.positioning.x+object.positioning.width-pointValue,
                    object.positioning.y,
                    pointValue,
                    object.positioning.height,object.bg,object.fg,
                    -pointValue+1+object.tex_offset_x,
                    object.tex_offset_y,
                    object.canvas.texture_cache
                )
            end
            for y=object.positioning.y,object.positioning.height+object.positioning.y-1 do
                term.setCursorPos(object.positioning.x,y)
                term.blit(
                    (" "):rep(left),
                    ("f"):rep(left),
                    graphic.code.to_blit[object.bg]:rep(left)
                )
            end
        end
    end
    local pointValue = math.floor(math.min(object.positioning.height,math.max(0,math.floor(object.positioning.height*(math.floor(object.value))/100))))
    local left = math.ceil(math.min(object.positioning.height,math.max(0,object.positioning.height-pointValue)))
    if object.direction == "top-down" then
        if not object.texture then
            for y=object.positioning.y,object.positioning.y+object.positioning.height-1 do
                term.setCursorPos(object.positioning.x,y)
                if y <= pointValue+object.positioning.y-0.5 then
                    term.blit(
                        (" "):rep(object.positioning.width),
                        ("f"):rep(object.positioning.width),
                        graphic.code.to_blit[object.fg]:rep(object.positioning.width)
                    )
                else
                    term.blit(
                        (" "):rep(object.positioning.width),
                        ("f"):rep(object.positioning.width),
                        graphic.code.to_blit[object.bg]:rep(object.positioning.width)
                    )
                end
            end
        else
            if not object.drag_texture then
                graphic.code.draw_box_tex(
                    term,
                    object.texture,
                    object.positioning.x,
                    object.positioning.y,
                    object.positioning.width,
                    pointValue,object.bg,object.fg,
                    object.tex_offset_x,
                    object.tex_offset_y,
                    object.canvas.texture_cache
                )
            else
                graphic.code.draw_box_tex(
                    term,
                    object.texture,
                    object.positioning.x,
                    object.positioning.y,
                    object.positioning.width,
                    pointValue,object.bg,object.fg,object.tex_offset_x,
                    -pointValue+1+object.tex_offset_y,
                    object.canvas.texture_cache
                )
            end
            for y=object.positioning.y+pointValue,object.positioning.y+object.positioning.height-1 do
                term.setCursorPos(object.positioning.x,y)
                term.blit(
                    (" "):rep(object.positioning.width),
                    ("f"):rep(object.positioning.width),
                    graphic.code.to_blit[object.bg]:rep(object.positioning.width)
                )
            end
        end
    end
    local pointValue = math.min(object.positioning.height,math.max(0,math.floor(object.positioning.height*(100-math.floor(object.value))/100)))
    local left = math.min(object.positioning.height,math.max(0,object.positioning.height-pointValue))
    if object.direction == "down-top" then
        if not object.texture then
            for y=object.positioning.y,object.positioning.y+object.positioning.height-1 do
                term.setCursorPos(object.positioning.x,y)
                if y <= pointValue+object.positioning.y-0.5 then
                    term.blit(
                        (" "):rep(object.positioning.width),
                        ("f"):rep(object.positioning.width),
                        graphic.code.to_blit[object.bg]:rep(object.positioning.width)
                    )
                else
                    term.blit(
                        (" "):rep(object.positioning.width),
                        ("f"):rep(object.positioning.width),
                        graphic.code.to_blit[object.fg]:rep(object.positioning.width)
                    )
                end
            end
        else
            if object.drag_texture then
                graphic.code.draw_box_tex(
                    term,
                    object.texture,
                    object.positioning.x,
                    object.positioning.y+pointValue,
                    object.positioning.width,
                    left,object.bg,object.fg,
                    object.tex_offset_x,
                    object.tex_offset_y,object.canvas.texture_cache
                )
            else
                graphic.code.draw_box_tex(
                    term,
                    object.texture,
                    object.positioning.x,
                    object.positioning.y+pointValue,
                    object.positioning.width,
                    left,object.bg,object.fg,object.tex_offset_x,
                    -left+1+object.tex_offset_y,
                    object.canvas.texture_cache
                )
            end
            for y=object.positioning.y,object.positioning.y+pointValue-1 do
                term.setCursorPos(object.positioning.x,y)
                term.blit(
                    (" "):rep(object.positioning.width),
                    ("f"):rep(object.positioning.width),
                    graphic.code.to_blit[object.bg]:rep(object.positioning.width)
                )
            end
        end
    end
end