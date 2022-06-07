local e=require("graphic_handle").code return function(t)local
a=t.canvas.term_object local o,i=t.positioning.x,t.positioning.y if not
t.texture and not t.texture_on then a.setBackgroundColor(t.value and
t.background_color_on or t.background_color)a.setTextColor(t.value and
t.text_color_on or t.text_color)for n=i,t.positioning.height+i-1 do
a.setCursorPos(o,n)a.write(t.symbol:rep(t.positioning.width))end else
e.draw_box_tex(a,(t.value and t.texture_on or t.texture)or(t.texture or
t.texture_on),t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height,(t.value
and t.background_color_on or t.background_color)or colors.red,(t.value and
t.text_color_on or t.text_color)or
colors.black,nil,nil,t.canvas.texture_cache)end if t.text and((not t.value)or
not t.text_on)then
t.text(a,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)elseif
t.text_on and t.value then
t.text_on(a,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)end
end