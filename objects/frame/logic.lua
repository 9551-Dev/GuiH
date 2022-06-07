local e=require("api")return function(t,a,o)t.on_any(t,a)local
i,n=t.window.getPosition()local s=t.dragger.x+i local h=t.dragger.y+n if
a.name=="mouse_click"or a.name=="monitor_touch"then if
e.is_within_field(a.x,a.y,s-1,h-1,t.dragger.width,t.dragger.height)then
t.dragged=true t.last_click=a t.on_select(t,a)end elseif a.name=="mouse_up"then
t.dragged=false t.on_select(t,a)elseif a.name=="mouse_drag"and t.dragged and
t.dragable then local r,d=t.window.getPosition()local
l,u=t.window.getSize()local c,m=a.x-t.last_click.x,a.y-t.last_click.y
t.last_click=a local f,w=r+c,d+m if not t.on_move(t,{x=f,y=w})then
t.window.reposition(f,w)end end
end