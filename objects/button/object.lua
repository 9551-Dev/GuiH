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
        on_click=data.on_click or function() end,
        background_color = data.background_color or object.term_object.getBackgroundColor(),
        text_color = data.text_color or object.term_object.getTextColor(),
        symbol=data.symbol or " ",
        texture = data.tex,
        text=data.text,
        visible=(data.visible ~= nil) and data.visible or true,
        reactive=(data.reactive ~= nil) and data.reactive or true,
        react_to_events={
            mouse_click=true,
            monitor_touch=true,
        },
        tags={},
        btn=data.btn,
        value=(data.value ~= nil) and data.value or true
    }
    return btn
end
