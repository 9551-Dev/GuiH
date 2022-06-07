local e=require("api")return function(t,a)a=a or{}if
type(a.visible)~="boolean"then a.visible=true end if
type(a.reactive)~="boolean"then a.reactive=true end local o={name=a.name or
e.uuid4(),visible=a.visible,text=a.text
or{text="none",x=1,y=1,offset_x=0,offset_y=0,blit={"0000","eeee"}},order=a.order
or 1,logic_order=a.logic_order,graphic_order=a.graphic_order,}return o
end