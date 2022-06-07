local e=require("api")return function(t,a)if
e.is_within_field(a.x,a.y,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)then
if a.direction==-1 then t.value=t.value+1 if t.value>t.limit_max then
t.value=t.limit_max end t.on_change_value(t)t.on_up(t)elseif a.direction==1
then t.value=t.value-1 if t.value<t.limit_min then t.value=t.limit_min end
t.on_change_value(t)t.on_down(t)end end
end