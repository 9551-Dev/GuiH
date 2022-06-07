local e=require("api")return function(t,a)a=a or{}if
type(a.visible)~="boolean"then a.visible=true end if
type(a.reactive)~="boolean"then a.reactive=true end local o={name=a.name or
e.uuid4(),visible=a.visible,reactive=a.reactive,react_to_events={},btn={},order=a.order
or 1,logic_order=a.logic_order,graphic_order=a.graphic_order,}return o
end