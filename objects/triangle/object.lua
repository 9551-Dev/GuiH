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
    if type(object.symbols) ~= "table" then data.symbols = {} end
    if type(data.filled) ~= "boolean" then data.filled = true end
    if type(data.p1) ~= "table" then data.p1 = {} end
    if type(data.p2) ~= "table" then data.p2 = {} end
    if type(data.p3) ~= "table" then data.p3 = {} end
    if type(data.blocking) ~= "boolean" then data.blocking = false end
    if type(data.always_update) ~= "boolean" then data.always_update = false end
    local btn = {
        name=data.name or api.uuid4(),
        positioning = {
            p1 = {
                x=data.p1[1] or 1,
                y=data.p1[2] or 1
            },
            p2 = {
                x=data.p2[1] or 1,
                y=data.p2[2] or 1
            },
            p3 = {
                x=data.p3[1] or 1,
                y=data.p3[2] or 1
            }
        },
        symbol=data.symbol or " ",
        bg=data.background_color or colors.white,
        fg=data.text_color or colors.black,
        visible=data.visible,
        filled=data.filled,
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
        blocking = data.blocking,
        always_update = data.always_update
    }
    return btn
end
