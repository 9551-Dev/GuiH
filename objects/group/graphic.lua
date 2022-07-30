return function(object)
    
    local lp = object.last_known_position
    local p  = object.positioning

    if lp.x ~= p.x or lp.y ~= p.y or lp.width ~= p.width or lp.height ~= p.height then
        object.window.reposition(p.x, p.y, p.width, p.height)
        object.gui.w,object.gui.width  = p.width,p.width
        object.gui.h,object.gui.height = p.height,p.height
        object.last_known_position = {
            x = p.x,
            y = p.y,
            width = p.width,
            height = p.height
        }
    end

    object.window.redraw()
end