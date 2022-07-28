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
        object.value = not object.value
        object.on_change_state(object,event)
    end
end 