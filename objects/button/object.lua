return function(object,data)
    data = data or {}
    local btn = setmetatable({
        canvas=object,
        name=data.name or "",
        positioning = {
            x=data.x or 1,
            y=data.y or 1,
            width=(data.x or 1)+(data.width or 1),
            height=(data.y or 1)+(data.height or 1),
        },
        execute=data.execute or function() end,
        background_color = data.background_color or object.term_object.getBackgroundColor(),
        text_color = data.text_color or object.term_object.getTextColor(),
        texture = data.texture,
        text=data.text,
        visible=true,
        reactive=true,
        react_to_events={
            mouse_click=true,
            monitor_touch=true
        },
        tags={},
        value=true
    },{
        __index = {
            logic=require("GuiH.objects.button.logic"),
            graphic=require("GuiH.objects.button.graphic")
        }
    })
    object.gui.button[btn.name] = btn
    return btn
end
