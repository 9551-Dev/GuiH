local types = {
    ["left-right"]=true,
    ["right-left"]=true,
    ["top-down"]=true,
    ["down-top"]=true,
}

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
        fg=data.fg or colors.white,
        bg=data.bg or colors.black,
        texture=data.tex,
        value=data.value or 0,
        direction=types[data.direction] and data.direction or "left-right"
    },{
        __index = {
            logic=require("GuiH.objects.progressbar.logic"),
            graphic=require("GuiH.objects.progressbar.graphic")
        }
    })
    object.gui.progressbar[btn.name] = btn
    return btn
end
