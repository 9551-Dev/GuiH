return function(object,input_data)
    local btn = {
        name=input_data.name or "",
        visible=(input_data.visible ~= nil) and input_data.visible or true,
        reactive=(input_data.reactive ~= nil) and input_data.reactive or true,
        react_to_events={}, --a look up table with the event names
        --btn={} --optional LUT table with the keys this object should respond to
    }
    return btn
end