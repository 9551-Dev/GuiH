return function(object)

    local lp = object.last_known_position
    local p  = object.positioning

    if lp.x ~= p.x or lp.y ~= p.y or lp.width ~= p.width or lp.height ~= p.height then
        object.child.w,object.child.width  = p.width,p.width
        object.child.h,object.child.height = p.height,p.height
        object.window.reposition(p.x, p.y, p.width, p.height)
        object.last_known_position = {
            x = p.x,
            y = p.y,
            width = p.width,
            height = p.height
        }
    end

    object.on_graphic(object)
end