return function(object,data)
    data = data or {}
    local btn = setmetatable({
        canvas=object,
        name=data.name or "",
        positioning = {
            x=data.x or 1,
            y=data.y or 1,
            width=data.width or 0,
            height=data.height or 0
        },
        visible=(data.visible ~= nil) and data.visible or true,
        reactive=(data.reactive ~= nil) and data.reactive or true,
        react_to_events={
            events
        },
    },{
        __index = {
            logic=require("GuiH.objects.<name>.logic"),
            graphic=require("GuiH.objects.<name>.graphic")
        }
    })
    object.gui.button[btn.name] = btn
    return btn
end
