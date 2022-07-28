local api = require("util")

local types = {
    ["left-right"]=true,
    ["right-left"]=true,
    ["top-down"]=true,
    ["down-top"]=true,
}

return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.drag_texture) ~= "boolean" then data.drag_texture = false end
    if type(data.blocking) ~= "boolean" then data.blocking = false end
    if type(data.always_update) ~= "boolean" then data.always_update = false end
    local btn = {
        name=data.name or api.uuid4(),
        positioning = {
            x=data.x or 1,
            y=data.y or 1,
            width=data.width or 0,
            height=data.height or 0
        },
        visible=data.visible,
        fg=data.fg or colors.white,
        bg=data.bg or colors.black,
        texture=data.tex,
        value=data.value or 0,
        direction=types[data.direction] and data.direction or "left-right",
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        drag_texture=data.drag_texture,
        tex_offset_x=data.tex_offset_x or 0,
        tex_offset_y=data.tex_offset_y or 0,
        blocking = data.blocking,
        always_update = data.always_update
    }
    return btn
end
