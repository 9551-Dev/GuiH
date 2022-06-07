local e=require("api")local
t={["left-right"]=true,["right-left"]=true,["top-down"]=true,["down-top"]=true,}return
function(a,o)o=o or{}if type(o.visible)~="boolean"then o.visible=true end if
type(a.symbols)~="table"then o.symbols={}end if type(o.filled)~="boolean"then
o.filled=true end if type(o.p1)~="table"then o.p1={}end if
type(o.p2)~="table"then o.p2={}end if type(o.p3)~="table"then o.p3={}end local
i={name=o.name or e.uuid4(),positioning={p1={x=o.p1[1]or 1,y=o.p1[2]or
1},p2={x=o.p2[1]or 1,y=o.p2[2]or 1},p3={x=o.p3[1]or 1,y=o.p3[2]or
1}},symbol=o.symbol or" ",bg=o.background_color or colors.white,fg=o.text_color
or colors.black,visible=o.visible,filled=o.filled,order=o.order or
1,logic_order=o.logic_order,graphic_order=o.graphic_order,}return i
end