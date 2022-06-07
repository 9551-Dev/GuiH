local e=require("api")local t=require("a-tools.gui_object")return
function(a,o)o=o or{}if type(o.visible)~="boolean"then o.visible=true end if
type(o.reactive)~="boolean"then o.reactive=true end local i={name=o.name or
e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or 0,height=o.height
or 0},visible=o.visible,order=o.order or
1,logic_order=o.logic_order,graphic_order=o.graphic_order,dragable=o.draggable,bef_draw=o.bef_draw
or function()end}local
n=window.create(a.term_object,i.positioning.x,i.positioning.y,i.positioning.width,i.positioning.height)i.gui=t(n,a.term_object,a.log)i.window=n
return i
end