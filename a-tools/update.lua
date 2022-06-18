local e=require("api")local
t={["mouse_click"]=true,["mouse_drag"]=true,["monitor_touch"]=true,["mouse_scroll"]=true,["mouse_up"]=true,["key"]=true,["key_up"]=true,["char"]=true,["guih_data_event"]=true,["paste"]=true}local
a={["key"]=true,["key_up"]=true,["char"]=true,["paste"]=true}local
o={[1]=true,[2]=true}local
i={["mouse_click"]=true,["mouse_drag"]=true,["mouse_up"]=true,["mouse_scroll"]=true}return
function(n,s,h,r,d,l,u)if h==nil then h=true end local c="none"local m=d local
f=d local w=n.gui local y,p,v,b local g,k={},{}local q=true if((s or
math.huge)>0)and not l then if not f or not r then local j=os.startTimer(s or
0)if s==0 then os.queueEvent("mouse_click",math.huge,-math.huge,-math.huge)end
while not t[c]or(c=="timer"and y==j)do c,y,p,v,b=os.pullEvent()end if
c=="monitor_touch"then m={name=c,monitor=y,x=p,y=v}end if c=="mouse_click"or
c=="mouse_up"then m={name=c,button=y,x=p,y=v}end if c=="mouse_drag"then
m={name=c,button=y,x=p,y=v}end if c=="mouse_scroll"then
m={name=c,direction=y,x=p,y=v}end if c=="key"then
m={name=c,key=y,held=p,x=math.huge,y=math.huge}end if c=="key_up"then
m={name=c,key=y,x=math.huge,y=math.huge}end if c=="paste"then
m={name=c,text=y,x=math.huge,y=math.huge}end if c=="char"then
m={name=c,character=y,x=math.huge,y=math.huge}end if c=="guih_data_event"then
m=y end if not m.monitor then m.monitor="term_object"end if p~=n.id and
c~="guih_data_event"then os.queueEvent("guih_data_event",m,n.id)else q=false
end end local x={}if q and m.monitor==n.monitor and not u then for z,E in
pairs(w)do for T,A in pairs(E)do if(A.reactive and A.react_to_events[m.name])or
not next(A.react_to_events)then if not x[A.logic_order or A.order]then
x[A.logic_order or A.order]={}end table.insert(x[A.logic_order or
A.order],function()if a[m.name]then if A.logic then A.logic(A,m,n)end else
if((A.btn or o)[m.button])or m.monitor==n.monitor then if A.logic then
A.logic(A,m,n)end end end end)end end end end for O,I in
e.tables.iterate_order(x)do parallel.waitForAll(unpack(I))end end local
N,S=n.term_object.getCursorPos()if h and n.visible then for H,R in pairs(w)do
for D,L in pairs(R)do if not k[L.graphic_order or L.order]then
k[L.graphic_order or L.order]={}end table.insert(k[L.graphic_order or
L.order],function()if not(L.gui or L.child)then if L.visible and L.graphic then
L.graphic(L,n)end else if L.visible and L.graphic then L.graphic(L,n);(L.gui or
L.child).term_object.redraw()end end end)end end end for U,C in
e.tables.iterate_order(k)do parallel.waitForAll(table.unpack(C))end local
M={}for F,W in pairs(w)do for Y,P in pairs(W)do if not M[P.graphic_order or
P.order]then M[P.graphic_order or P.order]={}end table.insert(M[P.graphic_order
or P.order],function()if P.gui or P.child then table.insert(g,P)end end)end end
for V,B in e.tables.iterate_order(M)do for G,K in pairs(B)do K()end end if not
q then return m,table.pack(c,y,p,v,b)end for Q,J in ipairs(g)do local
X,Z=J.window.getPosition()local et,tt=J.window.getSize()local f=f or d or m if
f then local
at={x=(f.x-X)+1,y=(f.y-Z)+1,name=f.name,monitor=f.monitor,button=f.button,direction=f.direction,held=f.held,key=f.key,character=f.character,text=f.text}if
(J.gui or J.child) and J.gui.cls then
J.gui.term_object.setBackgroundColor(J.gui.background)J.gui.term_object.clear()end
if e.is_within_field(f.x,f.y,X,Z,X+et,Z+tt)then(J.child or
J.gui).update(math.huge,J.visible,true,at,not J.reactive,not J.visible)else
at.x=-math.huge at.y=-math.huge;(J.child or
J.gui).update(math.huge,J.visible,true,at,not J.reactive,not J.visible)end if
(J.gui or J.child) and J.gui.cls then J.gui.term_object.redraw()end end end
n.term_object.setCursorPos(N,S)return
m,table.pack(c,y,p,v,b)end
