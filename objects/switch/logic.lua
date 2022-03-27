local api = require("guiH.api")
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
        object.execute(object,event)
    end
end 