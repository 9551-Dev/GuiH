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
    if type(data.symbols) ~= "table" then data.symbols = {} end
    if type(data.blocking) ~= "boolean" then data.blocking = true end
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
        color=data.color or colors.white,
        filled=data.filled,
        symbols={
            ["top_left"]=data.symbols.top_left or {sym=" ",bg=data.color or colors.white,fg=colors.black},
            ["top_right"]=data.symbols.top_right or {sym=" ",bg=data.color or colors.white,fg=colors.black},
            ["bottom_left"]=data.symbols.bottom_left or {sym=" ",bg=data.color or colors.white,fg=colors.black},
            ["bottom_right"]=data.symbols.bottom_right or {sym=" ",bg=data.color or colors.white,fg=colors.black},
            ["side_left"]=data.symbols.side_left or {sym=" ",bg=data.color or colors.white,fg=colors.black},
            ["side_right"]=data.symbols.side_right or {sym=" ",bg=data.color or colors.white,fg=colors.black},
            ["side_top"]=data.symbols.side_top or {sym=" ",bg=data.color or colors.white,fg=colors.black},
            ["side_bottom"]=data.symbols.side_bottom or {sym=" ",bg=data.color or colors.white,fg=colors.black},
            ["inside"]=data.symbols.inside or {sym=" ",bg=data.color or colors.white,fg=colors.black}
        },
        order=data.order or 1,
        logic_order=data.logic_order or -1,
        graphic_order=data.graphic_order,
        blocking = data.blocking,
        always_update = data.always_update
    }
    return btn
end
