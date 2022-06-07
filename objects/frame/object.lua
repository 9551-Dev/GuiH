local e=require("api")local t=require("a-tools.gui_object")return
function(a,o)o=o or{}if type(o.clear)~="boolean"then o.clear=true end if
type(o.draggable)~="boolean"then o.draggable=true end if
type(o.visible)~="boolean"then o.visible=true end if
type(o.reactive)~="boolean"then o.reactive=true end local i={name=o.name or
e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or 0,height=o.height
or
0},visible=o.visible,reactive=o.reactive,react_to_events={mouse_drag=true,mouse_click=true,mouse_up=true},dragged=false,dragger=o.dragger,last_click={x=1,y=1},order=o.order
or
1,logic_order=o.logic_order,graphic_order=o.graphic_order,btn=o.btn,dragable=o.draggable,on_move=o.on_move
or function()end,on_select=o.on_select or function()end,on_any=o.on_any or
function()end,on_graphic=o.on_graphic or
function()end,on_deselect=o.on_deselect or function()end}local
n=window.create(a.term_object,i.positioning.x,i.positioning.y,i.positioning.width,i.positioning.height)if
not i.dragger then i.dragger={x=1,y=1,width=i.positioning.width,height=1}end
i.child=t(n,a.term_object,a.log)i.window=n return i
end