local e=require("graphic_handle").code return function(t)local
a=t.canvas.term_object local o,i=t.positioning.x,t.positioning.y if not
t.texture then
a.setBackgroundColor(t.background_color)a.setTextColor(t.text_color)for
n=i,t.positioning.height+i-1 do
a.setCursorPos(o,n)a.write(t.symbol:rep(t.positioning.width))end else
e.draw_box_tex(a,t.texture,o,i,t.positioning.width,t.positioning.height,t.background_color,t.text_color,nil,nil,t.canvas.texture_cache)end
if t.text then
t.text(a,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)end
end