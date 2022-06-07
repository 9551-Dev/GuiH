local e=require("api")return function(t,a)a=a or{}if
type(a.visible)~="boolean"then a.visible=true end if
type(a.reactive)~="boolean"then a.reactive=true end local o={name=a.name or
e.uuid4(),visible=a.visible,reactive=a.reactive,code=a.code or function()return
false end,graphic=a.graphic or function()return false end,order=a.order or
1,logic_order=a.logic_order,graphic_order=a.graphic_order,react_to_events={mouse_click=true,mouse_drag=true,monitor_touch=true,mouse_scroll=true,mouse_up=true,key=true,key_up=true,char=true,paste=true}}return
o
end