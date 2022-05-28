local graphics = require("graphic_handle").code

return function(object)
    local term = object.canvas.term_object
    local x,y = object.positioning.x,object.positioning.y
    local w,h = object.positioning.width,object.positioning.height
    term.setCursorPos(x,y)
    term.blit(
        object.symbols.top_left.sym..object.symbols.side_top.sym:rep(w-2)..object.symbols.top_right.sym,
        graphics.to_blit[object.symbols.top_left.fg]..graphics.to_blit[object.symbols.side_top.fg]:rep(w-2)..graphics.to_blit[object.symbols.top_right.fg],
        graphics.to_blit[object.symbols.top_left.bg]..graphics.to_blit[object.symbols.side_top.bg]:rep(w-2)..graphics.to_blit[object.symbols.top_right.bg]
    )
    for i=1,h-2 do
        term.setCursorPos(x,y+i)
        term.blit(
            object.symbols.side_left.sym..object.symbols.inside.sym:rep(w-2)..object.symbols.side_right.sym,
            graphics.to_blit[object.symbols.side_left.fg]..graphics.to_blit[object.symbols.inside.fg]:rep(w-2)..graphics.to_blit[object.symbols.side_right.fg],
            graphics.to_blit[object.symbols.side_left.bg]..graphics.to_blit[object.symbols.inside.bg]:rep(w-2)..graphics.to_blit[object.symbols.side_right.bg]
        )
    end
    term.setCursorPos(x,y+h-1)
    term.blit(
        object.symbols.bottom_left.sym..object.symbols.side_bottom.sym:rep(w-2)..object.symbols.bottom_right.sym,
        graphics.to_blit[object.symbols.bottom_left.fg]..graphics.to_blit[object.symbols.side_bottom.fg]:rep(w-2)..graphics.to_blit[object.symbols.bottom_right.fg],
        graphics.to_blit[object.symbols.bottom_left.bg]..graphics.to_blit[object.symbols.side_bottom.bg]:rep(w-2)..graphics.to_blit[object.symbols.bottom_right.bg]
    )
end