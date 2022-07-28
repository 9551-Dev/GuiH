local api = require("util")
return function(object,event)
    --* if a click happens on the buttons area
    --* run on_click function
    if api.is_within_field(
        event.x,
        event.y,
        object.positioning.x,
        object.positioning.y,
        object.positioning.width,
        object.positioning.height
    ) then
        object.on_click(object,event)
    end
end