local types = {
    ["left-right"]=true,
    ["right-left"]=true,
    ["top-down"]=true,
    ["down-top"]=true,
}

return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    local btn = {
        name=data.name or tostring(os.epoch("utc")),
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
    }
    return btn
end
