return function(object,data)
    data = data or {}
    local btn = {
        name=data.name or "",
        positioning = {
            x=data.x or 1,
            y=data.y or 1,
            width=data.width or 0,
            height=data.height or 0
        },
        on_change_state=data.on_change_state or function() end,
        background_color = data.background_color or object.term_object.getBackgroundColor(),
        background_color_on = data.background_color_on or object.term_object.getBackgroundColor(),
        text_color = data.text_color or object.term_object.getTextColor(),
        text_color_on = data.text_color_on or object.term_object.getTextColor(),
        symbol=data.symbol or " ",
        texture = data.tex,
        texture_on = data.tex_on,
        text=data.text,
        text_on=data.text_on,
        visible=(data.visible ~= nil) and data.visible or true,
        reactive=(data.reactive ~= nil) and data.reactive or true,
        react_to_events={
            mouse_click=true,
            monitor_touch=true
        },
        tags={},
        value=(data.value ~= nil) and data.value or false
    },{
        __index = {
            logic=require("GuiH.objects.switch.logic"),
            graphic=require("GuiH.objects.switch.graphic")
        }
    }
    return btn
end
