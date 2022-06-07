local e=require("api")return function(t,a)a=a or{}if
type(a.visible)~="boolean"then a.visible=true end if
type(a.reactive)~="boolean"then a.reactive=true end local o={name=a.name or
e.uuid4(),positioning={x=a.x or 1,y=a.y or 1,width=a.width or 0,height=a.height
or 0},on_click=a.on_click or function()end,background_color=a.background_color
or t.term_object.getBackgroundColor(),text_color=a.text_color or
t.term_object.getTextColor(),symbol=a.symbol
or" ",texture=a.tex,text=a.text,visible=a.visible,reactive=a.reactive,react_to_events={mouse_click=true,monitor_touch=true,},order=a.order
or
1,logic_order=a.logic_order,graphic_order=a.graphic_order,tags={},btn=a.btn,value=(a.value~=nil)and
a.value or true}return o
end