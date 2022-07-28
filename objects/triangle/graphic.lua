local algo = require("core.algo")
local graphic = require("graphic_handle").code

return function(object)
    local term = object.canvas.term_object
    local draw_map = {}
    local x_map = {}
    if object.filled then
        local points = algo.get_triangle_points(
            object.positioning.p1,
            object.positioning.p2,
            object.positioning.p3
        )
        for k,v in ipairs(points) do
            draw_map[v.y] = (draw_map[v.y] or "").."*"
            x_map[v.y] = math.min(x_map[v.y] or math.huge,v.x)
        end
        for y,data in pairs(draw_map) do
            term.setCursorPos(x_map[y],y)
            term.blit(
                data:gsub("%*",object.symbol),
                data:gsub("%*",graphic.to_blit[object.fg]),
                data:gsub("%*",graphic.to_blit[object.bg])
            )
        end
    else
        local points = algo.get_triangle_outline_points(
            object.positioning.p1,
            object.positioning.p2,
            object.positioning.p3
        )
        for k,v in pairs(points) do
            term.setCursorPos(v.x,v.y)
            term.blit(
                object.symbol,
                graphic.to_blit[object.fg],
                graphic.to_blit[object.bg]
            )
        end
    end
end