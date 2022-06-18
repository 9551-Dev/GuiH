local e=require("object_loader")local t=require("graphic_handle")local
a=require("a-tools.update")local o=require("api") local
function i(n,s,h,r,d)local l={}local u="term_object"local c=s local function
m()r,d=0,0 pcall(function()local function f(w)local
y,p=w.getPosition()r=r+(y-1)d=d+(p-1)local
v,b=debug.getupvalue(w.reposition,5)if b.reposition and b~=term.current()then
c=b f(b)elseif b~=nil then c=b end end f(n)end)end if not r or not d then
m()end pcall(function()u=peripheral.getType(c)end)for g,k in pairs(e.types)do
l[k]={}end local q,j=n.getSize()local
x={term_object=n,term=n,gui=l,update=a,visible=true,id=o.uuid4(),task_schedule={},update_delay=0.05,held_keys={},log=h,task_routine={},paused_task_routine={},w=q,h=j,width=q,height=j,event_listeners={},paused_listeners={},background=n.getBackgroundColor(),cls=false,key={},texture_cache={},debug=false,event_offset_x=r,event_offset_y=d,calibrate=m}x.elements=x.gui
h("set up updater",h.update)local function z(E,T,A,O,I,N)return
a(x,E,T,A,O,I,N)end local S local H=false x.schedule=function(R,D,L,U)local
C=o.uuid4()if U or x.debug then
h("created new thread: "..tostring(C),h.info)end local M={}local
F={c=coroutine.create(function()local W,Y=pcall(function()if D then
o.precise_sleep(D)end R(x,x.term_object)end)if not W then if L==true then S=Y
end M.err=Y if U or x.debug then
h("error in thread: "..tostring(C).."\n"..tostring(Y),h.error)h:dump()end end
end),dbug=U}x.task_routine[C]=F local function P(...)local
V=x.task_routine[C]or x.paused_task_routine[C]if V then local
B,S=coroutine.resume(V.c,...)if not B then M.err=S if U or x.debug then
h("task "..tostring(C).." error: "..tostring(S),h.error)h:dump()end end return
true,B,S else if U or x.debug then
h("task "..tostring(C).." not found",h.error)h:dump()end return false end end
return setmetatable(F,{__index={kill=function()x.task_routine[C]=nil
x.paused_task_routine[C]=nil if U or x.debug then
h("killed task: "..tostring(C),h.info)h:dump()end return true
end,alive=function()local G=x.task_routine[C]or x.paused_task_routine[C]if not
G then return false end return
coroutine.status(G.c)~="dead"end,step=P,update=P,pause=function()local
K=x.task_routine[C]or x.paused_task_routine[C]if K then
x.paused_task_routine[C]=K x.task_routine[C]=nil if U or x.debug then
h("paused task: "..tostring(C),h.info)h:dump()end return true else if U or
x.debug then h("task "..tostring(C).." not found",h.error)h:dump()end return
false end end,resume=function()local Q=x.paused_task_routine[C]or
x.task_routine[C]if Q then x.task_routine[C]=Q x.paused_task_routine[C]=nil if
U or x.debug then h("resumed task: "..tostring(C),h.info)h:dump()end return
true else if U or x.debug then
h("task "..tostring(C).." not found",h.error)h:dump()end return false end
end,get_error=function()return M.err end,set_running=function(J,U)local
X=x.task_routine[C]or x.paused_task_routine[C]local H=x.task_routine[C]~=nil if
X then if H and J then return true end if not H and not J then return true end
if H and not J then x.paused_task_routine[C]=X x.task_routine[C]=nil if U or
x.debug then h("paused task: "..tostring(C),h.info)h:dump()end return true end
if not H and J then x.task_routine[C]=X x.paused_task_routine[C]=nil if U or
x.debug then h("resumed task: "..tostring(C),h.info)h:dump()end return true end
end end},__tostring=function()return"GuiH.SCHEDULED_THREAD."..C end})end
x.async=x.schedule x.add_listener=function(Z,et,tt,at)if not
_G.type(et)=="function"then return end if not(_G.type(Z)=="table"or
_G.type(Z)=="string")then Z={}end local ot=tt or o.uuid4()local
it={filter=Z,code=et}x.event_listeners[ot]=it if at or x.debug then
h("created event listener: "..ot,h.success)h:dump()end return
setmetatable(it,{__index={kill=function()x.event_listeners[ot]=nil
x.paused_listeners[ot]=nil if at or x.debug then
h("killed event listener: "..ot,h.success)h:dump()end
end,pause=function()x.paused_listeners[ot]=it x.event_listeners[ot]=nil if at
or x.debug then h("paused event listener: "..ot,h.success)h:dump()end
end,resume=function()local it=x.paused_listeners[ot]or x.event_listeners[ot]if
it then x.event_listeners[ot]=it x.paused_listeners[ot]=nil if at or x.debug
then h("resumed event listener: "..ot,h.success)h:dump()end elseif at or
x.debug then h("event listener not found: "..ot,h.error)h:dump()end
end},__tostring=function()return"GuiH.EVENT_LISTENER."..ot end})end
x.cause_exeption=function(nt)S=tostring(nt)end x.stop=function()H=false end
x.kill=x.stop x.error=x.cause_exeption x.clear=function(st)if st or x.debug
then h("clearing the gui..",h.update)end local ht={}for rt,dt in
pairs(e.types)do ht[dt]={}end x.gui=ht x.elements=ht local
lt=e.main(x,ht,h)x.create=lt x.new=lt end x.isHeld=function(...)local
ut={...}local ct,mt=true,true for ft,wt in pairs(ut)do local
yt=x.held_keys[wt]or{}if yt[1]then ct=ct and true mt=mt and yt[2]else return
false,false,x.held_keys end end return ct,mt,x.held_keys end
x.key.held=x.isHeld
x.execute=setmetatable({},{__call=function(pt,vt,bt,gt,kt)if H then
h("Coulnt execute. Gui is already running",h.error)h:dump()return false end
S=nil H=true h("")h("loading execute..",h.update)local qt=x.term_object local
jt local xt=qt.getBackgroundColor()local zt=coroutine.create(function()local
Et,Tt=pcall(function()qt.setVisible(true)z(0)qt.redraw()while true do
qt.setVisible(false)qt.setBackgroundColor(x.background or xt)qt.clear();(gt or
function()end)(qt)local jt=a(x,nil,true,false,nil);(bt or
function()end)(qt,jt);(kt or function()end)(qt)qt.setVisible(true);end end)if
not Et then S=Tt h:dump()end end)h("created graphic routine 1",h.update)local
At=vt or function()end local function Ot()local It,Nt=pcall(At,qt)if not It
then S=Nt h:dump()end end h("created custom updater",h.update)local
St=coroutine.create(function()while true do
qt.setVisible(false)x.update(0,true,nil,{type="mouse_click",x=-math.huge,y=-math.huge,button=-math.huge});(kt
or function()end)(qt)qt.setVisible(true)qt.setVisible(false)if
x.update_delay<0.05 then os.queueEvent("waiting")os.pullEvent()else
sleep(x.update_delay)end end
end)h("created event listener handle",h.update)local
Ht=coroutine.create(function()local Rt,Dt=pcall(function()while true do local
Lt=table.pack(os.pullEventRaw())for Ut,Ct in pairs(x.event_listeners)do local
Mt=Ct.filter if _G.type(Mt)=="string"then Mt={[Ct.filter]=true}end if
Mt[Lt[1]]or Mt==Lt[1]or(not next(Mt))then
Ct.code(table.unpack(Lt,_G.type(Ct.filter)~="table"and 2 or 1,Lt.n))end end end
end)if not Rt then S=Dt h:dump()end
end)h("created graphic routine 2",h.update)local
Ft=coroutine.create(function()while true do local Wt,Yt,Pt=os.pullEvent()if
Wt=="key"then x.held_keys[Yt]={true,Pt}end if Wt=="key_up"then
x.held_keys[Yt]=nil end end end)h("created key handler")local
Vt=coroutine.create(Ot)coroutine.resume(Vt)coroutine.resume(zt,"mouse_click",math.huge,-math.huge,-math.huge)coroutine.resume(zt,"mouse_click",math.huge,-math.huge,-math.huge)coroutine.resume(zt,"mouse_click",math.huge,-math.huge,-math.huge)h("")h("Started execution..",h.success)h("")h:dump()while((coroutine.status(Vt)~="dead"or
not(_G.type(vt)=="function"))and coroutine.status(zt)~="dead"and S==nil)and H
do local jt=table.pack(os.pullEventRaw())if o.events_with_cords[jt[1]]then
jt[3]=jt[3]-(x.event_offset_x)jt[4]=jt[4]-(x.event_offset_y)end if
jt[1]=="terminate"then S="Terminated"break end if jt[1]~="guih_data_event"then
coroutine.resume(Ht,table.unpack(jt,1,jt.n))end
coroutine.resume(Vt,table.unpack(jt,1,jt.n))if jt[1]=="key"or
jt[1]=="key_up"then coroutine.resume(Ft,table.unpack(jt,1,jt.n))end for Bt,Gt
in pairs(x.task_routine)do if coroutine.status(Gt.c)~="dead"then if
Gt.filter==jt[1]or Gt.filter==nil then local
Kt,Qt=coroutine.resume(Gt.c,table.unpack(jt,1,jt.n))if Kt then Gt.filter=Qt end
end else x.task_routine[Bt]=nil x.task_schedule[Bt]=nil if Gt.dbug then
h("Finished sheduled task: "..tostring(Bt),h.success)end end end
coroutine.resume(zt,table.unpack(jt,1,jt.n))coroutine.resume(St,table.unpack(jt,1,jt.n))local
q,j=s.getSize()if q~=x.w or j~=x.h then if(jt[1]=="monitor_resize"and
x.monitor==jt[2])or x.monitor=="term_object"then
x.term_object.reposition(1,1,q,j)coroutine.resume(zt,"mouse_click",math.huge,-math.huge,-math.huge)x.w,x.h=q,j
x.width,x.height=q,j end end end if S then x.last_err=S end
qt.setVisible(true)if S then
h("a Fatal error occured: "..S..debug.traceback(),h.fatal)else
h("finished execution",h.success)end h:dump()S=nil return x.last_err,true
end,__tostring=function()return"GuiH.main_gui_executor"end})x.run=x.execute if
u=="monitor"then
h("Display object: monitor",h.info)x.monitor=peripheral.getName(c)else
h("Display object: term",h.info)x.monitor="term_object"end
x.load_texture=function(Jt)h("Loading nimg texture.. ",h.update)local
Xt=t.load_texture(Jt)return Xt end x.load_ppm_texture=function(Zt,ea)local
ta,aa,oa=pcall(t.load_ppm_texture,x.term_object,Zt,ea,h)if ta then return aa,oa
else h("Failed to load texture: "..aa,h.error)end end
x.load_cimg_texture=function(ia)h("Loading cimg texture.. ",h.update)local
na=t.load_cimg_texture(ia)return na end
x.load_blbfor_texture=function(sa)h("Loading blbfor texture.. ",h.update)local
ha,ra=t.load_blbfor_texture(sa)return ha,ra end
x.load_limg_texture=function(da,la,ua)h("Loading limg texture.. ",h.update)local
ca,ma=t.load_limg_texture(da,la,ua)return ca,ma end
x.load_limg_animation=function(fa,wa)h("Loading limg animation.. ",h.update)local
ya=t.load_limg_animation(fa,wa)return ya end
x.load_blbfor_animation=function(pa)h("Loading blbfor animation.. ",h.update)local
va=t.load_blbfor_animation(pa)return va end
x.set_event_offset=function(ba,ga)x.event_offset_x,x.event_offset_y=ba or
x.event_offset_x,ga or x.event_offset_y end
h("")h("Starting creator..",h.info)local ka=e.main(x,x.gui,h)x.create=ka
x.new=ka h("")x.update=z
h("loading text object...",h.update)h("")x.get_blit=function(qa,ja,xa)local za
pcall(function()za={x.term_object.getLine(qa)}end)if not za then return false
end return za[1]:sub(ja,xa),za[2]:sub(ja,xa),za[3]:sub(ja,xa)end
x.text=function(Ea)Ea=Ea or{}if _G.type(Ea.centered)~="boolean"then
Ea.centered=false end local
Ta=(_G.type(Ea.text)=="string")and("0"):rep(#Ea.text)or("0"):rep(13)local
Aa=(_G.type(Ea.text)=="string")and("f"):rep(#Ea.text)or("f"):rep(13)if
_G.type(Ea.blit)~="table"then Ea.blit={Ta,Aa}end Ea.blit[1]=(Ea.blit[1]or
Ta):lower()Ea.blit[2]=(Ea.blit[2]or
Aa):lower()h("created new text object",h.info)return setmetatable({text=Ea.text
or"<TEXT OBJECT>",centered=Ea.centered,x=Ea.x or 1,y=Ea.y or
1,offset_x=Ea.offset_x or 0,offset_y=Ea.offset_y or 0,blit=Ea.blit
or{Ta,Aa},transparent=Ea.transparent,bg=Ea.bg,fg=Ea.fg,width=Ea.width,height=Ea.height},{__call=function(Oa,Ia,Na,Sa,q,j)Na,Sa=Na
or Oa.x,Sa or Oa.y if Oa.width then q=Oa.width end if Oa.height then
j=Oa.height end local Ha=Ia or x.term_object local Ra if
_G.type(Na)=="number"and _G.type(Sa)=="number"then Ra=1 end if
_G.type(Na)~="number"then Na=1 end if _G.type(Sa)~="number"then Sa=1 end local
Da,La=Na,Sa local Ua={}for Ca in Oa.text:gmatch("[^\n]+")do
table.insert(Ua,Ca)end if Oa.centered then La=La-#Ua/2 else La=La-1 end for
Ma=1,#Ua do local Fa=Ua[Ma]La=La+1 if Oa.centered then local Wa=(j or
x.h)/2-0.5 local Ya=math.ceil(((q or
x.w)/2)-(#Fa/2)-0.5)Ha.setCursorPos(Ya+Oa.offset_x+Da,Wa+Oa.offset_y+La)Na,Sa=Ya+Oa.offset_x+Da,Wa+Oa.offset_y+La
else Ha.setCursorPos((Ra or Oa.x)+Oa.offset_x+Da-1,(Ra or
Oa.y)+Oa.offset_y+La-1)Na,Sa=(Ra or Oa.x)+Oa.offset_x+Da-1,(Ra or
Oa.y)+Oa.offset_y+La-1 end if Oa.transparent==true then local Pa=-1 if Na<1
then Pa=math.abs(math.min(Na+1,3)-2)Ha.setCursorPos(1,Sa)Na=1
Fa=Fa:sub(Pa+1)end local Ta,Aa=table.unpack(Oa.blit)if Oa.bg then
Aa=t.code.to_blit[Oa.bg]:rep(#Fa)end if Oa.fg then
Ta=t.code.to_blit[Oa.fg]:rep(#Fa)end local Va
pcall(function()_,_,Va=Ha.getLine(math.floor(Sa))end)if not Va then return end
local Ba=Va:sub(Na,math.min(Na+#Fa-1,x.w))local Ga=#Fa-#Ba-1 if#Ta~=#Fa then
Ta=("0"):rep(#Fa)end
Ha.blit(Fa,Ta:sub(math.min(Na,1)),Ba..Aa:sub(#Aa-Ga,#Aa))else local
Ta,Aa=table.unpack(Oa.blit)if Oa.bg then Aa=t.code.to_blit[Oa.bg]:rep(#Fa)end
if Oa.fg then Ta=t.code.to_blit[Oa.fg]:rep(#Fa)end if#Ta~=#Fa then
Ta=("0"):rep(#Fa)end if#Aa~=#Fa then Aa=("f"):rep(#Fa)end Ha.blit(Fa,Ta,Aa)end
end end,__tostring=function()return"GuiH.primitive.text"end})end return x end
return
i
