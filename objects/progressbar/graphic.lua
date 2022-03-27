local graphic = require("guiH.texture-wrapper")

return function(object)
    local term = object.canvas.term_object
    local pointValue = object.positioning.width*object.value/100
    local left = object.positioning.width-pointValue
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
            graphic.code.draw_box_tex(term,object.texture,object.positioning.x,object.positioning.y,pointValue,object.positioning.height)
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
            graphic.code.draw_box_tex(
                term,
                object.texture,
                object.positioning.x+object.positioning.width-pointValue,
                object.positioning.y,
                pointValue,
                object.positioning.height
            )
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
    local pointValue = math.floor(object.positioning.height*(object.value)/100)
    local left = object.positioning.height-pointValue
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
            graphic.code.draw_box_tex(
                term,
                object.texture,
                object.positioning.x,
                object.positioning.y,
                object.positioning.width,
                pointValue
            )
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
    local pointValue = math.floor(object.positioning.height*(100-object.value)/100)
    local left = object.positioning.height-pointValue
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
            graphic.code.draw_box_tex(
                term,
                object.texture,
                object.positioning.x,
                object.positioning.y+pointValue,
                object.positioning.width,
                left
            )
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