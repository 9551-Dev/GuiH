local types = {
    ["left-right"]=true,
    ["right-left"]=true,
    ["top-down"]=true,
    ["down-top"]=true,
}

return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(object.symbols) ~= "table" then data.symbols = {} end
    if type(data.filled) ~= "boolean" then data.filled = true end
    if type(data.p1) ~= "table" then data.p1 = {} end
    if type(data.p2) ~= "table" then data.p2 = {} end
    if type(data.p3) ~= "table" then data.p3 = {} end
    local btn = {
        name=data.name or tostring(os.epoch("utc")),
        positioning = {
            x=data.x or 1,
            y=data.y or 1,
            width=data.width or 1,
            height=data.height or 1
        },
        symbol=data.symbol or " ",
        bg=data.background_color or colors.white,
        fg=data.text_color or colors.black,
        visible=data.visible,
        filled=data.filled,
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
    }
    return btn
end
