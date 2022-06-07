local e=require("api")return function(t,a)if
e.is_within_field(a.x,a.y,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)then
t.on_click(t,a)end
end