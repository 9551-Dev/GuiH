local e=require("api")local
t={["left-right"]=true,["right-left"]=true,["top-down"]=true,["down-top"]=true,}return
function(a,o)o=o or{}if type(o.visible)~="boolean"then o.visible=true end if
type(a.symbols)~="table"then o.symbols={}end if type(o.filled)~="boolean"then
o.filled=true end local i={name=o.name or e.uuid4(),positioning={x=o.x or
1,y=o.y or 1,width=o.width or 1,height=o.height or 1},symbol=o.symbol
or" ",bg=o.background_color or colors.white,fg=o.text_color or
colors.black,visible=o.visible,filled=o.filled,order=o.order or
1,logic_order=o.logic_order,graphic_order=o.graphic_order,}return i
end