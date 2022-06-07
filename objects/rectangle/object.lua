local e=require("api")local
t={["left-right"]=true,["right-left"]=true,["top-down"]=true,["down-top"]=true,}return
function(a,o)o=o or{}if type(o.visible)~="boolean"then o.visible=true end if
type(o.symbols)~="table"then o.symbols={}end local i={name=o.name or
e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or 0,height=o.height
or 0},visible=o.visible,color=o.color or
colors.white,filled=o.filled,symbols={["top_left"]=o.symbols.top_left
or{sym=" ",bg=o.color or
colors.white,fg=colors.black},["top_right"]=o.symbols.top_right
or{sym=" ",bg=o.color or
colors.white,fg=colors.black},["bottom_left"]=o.symbols.bottom_left
or{sym=" ",bg=o.color or
colors.white,fg=colors.black},["bottom_right"]=o.symbols.bottom_right
or{sym=" ",bg=o.color or
colors.white,fg=colors.black},["side_left"]=o.symbols.side_left
or{sym=" ",bg=o.color or
colors.white,fg=colors.black},["side_right"]=o.symbols.side_right
or{sym=" ",bg=o.color or
colors.white,fg=colors.black},["side_top"]=o.symbols.side_top
or{sym=" ",bg=o.color or
colors.white,fg=colors.black},["side_bottom"]=o.symbols.side_bottom
or{sym=" ",bg=o.color or
colors.white,fg=colors.black},["inside"]=o.symbols.inside or{sym=" ",bg=o.color
or colors.white,fg=colors.black}},order=o.order or
1,logic_order=o.logic_order,graphic_order=o.graphic_order,}return i
end