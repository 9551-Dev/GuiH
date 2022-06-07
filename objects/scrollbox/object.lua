local e=require("api")return function(t,a)a=a or{}if
type(a.visible)~="boolean"then a.visible=true end if
type(a.reactive)~="boolean"then a.reactive=true end local o={name=a.name or
e.uuid4(),positioning={x=a.x or 1,y=a.y or 1,width=a.width or 1,height=a.height
or
1},visible=a.visible,reactive=a.reactive,react_to_events={["mouse_scroll"]=true},order=a.order
or 1,logic_order=a.logic_order,graphic_order=a.graphic_order,value=a.value or
1,limit_min=a.limit_min or-math.huge,limit_max=a.limit_max or
math.huge,on_change_value=a.on_change_value or function()end,on_up=a.on_up or
function()end,on_down=a.on_down or function()end}return o
end