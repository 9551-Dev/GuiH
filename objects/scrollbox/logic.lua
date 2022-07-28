local api = require("util")

return function(object,event)
    if api.is_within_field(
        event.x,
        event.y,
        object.positioning.x,
        object.positioning.y,
        object.positioning.width,
        object.positioning.height
    ) then
        if event.direction == -1 then
            object.value = object.value + 1
            if object.value > object.limit_max then object.value = object.limit_max end
            object.on_change_value(object)
            object.on_up(object)
        elseif event.direction == 1 then
            object.value = object.value - 1
            if object.value < object.limit_min then object.value = object.limit_min end
            object.on_change_value(object)
            object.on_down(object)
        end
    end
end