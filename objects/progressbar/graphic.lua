local e=require("graphic_handle")return function(t)local a=t.canvas.term_object
local
o=math.floor(math.max(math.min(t.positioning.width*(t.value/100),t.positioning.width),0))local
i=math.ceil(math.min(math.max(t.positioning.width-o,0),t.positioning.width))if
t.direction=="left-right"then if not t.texture then for
n=t.positioning.y,t.positioning.height+t.positioning.y-1 do
a.setCursorPos(t.positioning.x,n)a.blit((" "):rep(o)..(" "):rep(i),("f"):rep(o)..("f"):rep(i),e.code.to_blit[t.fg]:rep(o)..e.code.to_blit[t.bg]:rep(i))end
else if not t.drag_texture then
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y,o,t.positioning.height,t.bg,t.fg,t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)else
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y,o,t.positioning.height,t.bg,t.fg,-o+1+t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)end
for s=t.positioning.y,t.positioning.height+t.positioning.y-1 do
a.setCursorPos(t.positioning.x+o,s)a.blit((" "):rep(i),("f"):rep(i),e.code.to_blit[t.bg]:rep(i))end
end end if t.direction=="right-left"then if not t.texture then for
h=t.positioning.y,t.positioning.height+t.positioning.y-1 do
a.setCursorPos(t.positioning.x,h)a.blit((" "):rep(i)..(" "):rep(o),("f"):rep(i)..("f"):rep(o),e.code.to_blit[t.bg]:rep(i)..e.code.to_blit[t.fg]:rep(o))end
else if t.drag_texture then
e.code.draw_box_tex(a,t.texture,t.positioning.x+t.positioning.width-o,t.positioning.y,o,t.positioning.height,t.bg,t.fg,t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)else
e.code.draw_box_tex(a,t.texture,t.positioning.x+t.positioning.width-o,t.positioning.y,o,t.positioning.height,t.bg,t.fg,-o+1+t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)end
for r=t.positioning.y,t.positioning.height+t.positioning.y-1 do
a.setCursorPos(t.positioning.x,r)a.blit((" "):rep(i),("f"):rep(i),e.code.to_blit[t.bg]:rep(i))end
end end local
o=math.floor(math.min(t.positioning.height,math.max(0,math.floor(t.positioning.height*(math.floor(t.value))/100))))local
i=math.ceil(math.min(t.positioning.height,math.max(0,t.positioning.height-o)))if
t.direction=="top-down"then if not t.texture then for
d=t.positioning.y,t.positioning.y+t.positioning.height-1 do
a.setCursorPos(t.positioning.x,d)if d<=o+t.positioning.y-0.5 then
a.blit((" "):rep(t.positioning.width),("f"):rep(t.positioning.width),e.code.to_blit[t.fg]:rep(t.positioning.width))else
a.blit((" "):rep(t.positioning.width),("f"):rep(t.positioning.width),e.code.to_blit[t.bg]:rep(t.positioning.width))end
end else if not t.drag_texture then
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y,t.positioning.width,o,t.bg,t.fg,t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)else
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y,t.positioning.width,o,t.bg,t.fg,t.tex_offset_x,-o+1+t.tex_offset_y,t.canvas.texture_cache)end
for l=t.positioning.y+o,t.positioning.y+t.positioning.height-1 do
a.setCursorPos(t.positioning.x,l)a.blit((" "):rep(t.positioning.width),("f"):rep(t.positioning.width),e.code.to_blit[t.bg]:rep(t.positioning.width))end
end end local
o=math.min(t.positioning.height,math.max(0,math.floor(t.positioning.height*(100-math.floor(t.value))/100)))local
i=math.min(t.positioning.height,math.max(0,t.positioning.height-o))if
t.direction=="down-top"then if not t.texture then for
u=t.positioning.y,t.positioning.y+t.positioning.height-1 do
a.setCursorPos(t.positioning.x,u)if u<=o+t.positioning.y-0.5 then
a.blit((" "):rep(t.positioning.width),("f"):rep(t.positioning.width),e.code.to_blit[t.bg]:rep(t.positioning.width))else
a.blit((" "):rep(t.positioning.width),("f"):rep(t.positioning.width),e.code.to_blit[t.fg]:rep(t.positioning.width))end
end else if t.drag_texture then
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y+o,t.positioning.width,i,t.bg,t.fg,t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)else
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y+o,t.positioning.width,i,t.bg,t.fg,t.tex_offset_x,-i+1+t.tex_offset_y,t.canvas.texture_cache)end
for c=t.positioning.y,t.positioning.y+o-1 do
a.setCursorPos(t.positioning.x,c)a.blit((" "):rep(t.positioning.width),("f"):rep(t.positioning.width),e.code.to_blit[t.bg]:rep(t.positioning.width))end
end end
end