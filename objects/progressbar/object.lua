local e=require("api")local
t={["left-right"]=true,["right-left"]=true,["top-down"]=true,["down-top"]=true,}return
function(a,o)o=o or{}if type(o.visible)~="boolean"then o.visible=true end if
type(o.drag_texture)~="boolean"then o.drag_texture=false end local
i={name=o.name or e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or
0,height=o.height or 0},visible=o.visible,fg=o.fg or colors.white,bg=o.bg or
colors.black,texture=o.tex,value=o.value or 0,direction=t[o.direction]and
o.direction or"left-right",order=o.order or
1,logic_order=o.logic_order,graphic_order=o.graphic_order,drag_texture=o.drag_texture,tex_offset_x=o.tex_offset_x
or 0,tex_offset_y=o.tex_offset_y or 0,}return i
end