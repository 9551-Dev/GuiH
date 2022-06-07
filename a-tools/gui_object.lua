local e=require("object_loader")local t=require("graphic_handle")local
a=require("a-tools.update")local o=require("api")local function
i(n,s,h,r,d)local l={}local u="term_object"local c=s if not r or not d then
r,d=0,0 pcall(function()local function m(f)local
w,y=f.getPosition()r=r+(w-1)d=d+(y-1)local
p,v=debug.getupvalue(f.reposition,5)if v.reposition and v~=term.current()then
c=v m(v)elseif v~=nil then c=v end end m(n)end)end
pcall(function()u=peripheral.getType(c)end)for b,g in pairs(e.types)do
l[g]={}end local k,q=n.getSize()local
j={term_object=n,term=n,gui=l,update=a,visible=true,id=o.uuid4(),task_schedule={},update_delay=0.05,held_keys={},log=h,task_routine={},paused_task_routine={},w=k,h=q,width=k,height=q,event_listeners={},paused_listeners={},background=n.getBackgroundColor(),cls=false,key={},texture_cache={},debug=false,event_offset_x=r,event_offset_y=d,}j.elements=j.gui
h("set up updater",h.update)local function x(z,E,T,A,O,I)return
a(j,z,E,T,A,O,I)end local N local S=false j.schedule=function(H,R,D,L)local
U=o.uuid4()if L or j.debug then
h("created new thread: "..tostring(U),h.info)end local C={}local
M={c=coroutine.create(function()local F,W=pcall(function()if R then
o.precise_sleep(R)end H(j,j.term_object)end)if not F then if D==true then N=W
end C.err=W if L or j.debug then
h("error in thread: "..tostring(U).."\n"..tostring(W),h.error)h:dump()end end
end),dbug=L}j.task_routine[U]=M local function Y(...)local
P=j.task_routine[U]or j.paused_task_routine[U]if P then local
V,N=coroutine.resume(P.c,...)if not V then C.err=N if L or j.debug then
h("task "..tostring(U).." error: "..tostring(N),h.error)h:dump()end end return
true,V,N else if L or j.debug then
h("task "..tostring(U).." not found",h.error)h:dump()end return false end end
return setmetatable(M,{__index={kill=function()j.task_routine[U]=nil
j.paused_task_routine[U]=nil if L or j.debug then
h("killed task: "..tostring(U),h.info)h:dump()end return true
end,alive=function()local B=j.task_routine[U]or j.paused_task_routine[U]if not
B then return false end return
coroutine.status(B.c)~="dead"end,step=Y,update=Y,pause=function()local
G=j.task_routine[U]or j.paused_task_routine[U]if G then
j.paused_task_routine[U]=G j.task_routine[U]=nil if L or j.debug then
h("paused task: "..tostring(U),h.info)h:dump()end return true else if L or
j.debug then h("task "..tostring(U).." not found",h.error)h:dump()end return
false end end,resume=function()local K=j.paused_task_routine[U]or
j.task_routine[U]if K then j.task_routine[U]=K j.paused_task_routine[U]=nil if
L or j.debug then h("resumed task: "..tostring(U),h.info)h:dump()end return
true else if L or j.debug then
h("task "..tostring(U).." not found",h.error)h:dump()end return false end
end,get_error=function()return C.err end,set_running=function(Q,L)local
J=j.task_routine[U]or j.paused_task_routine[U]local S=j.task_routine[U]~=nil if
J then if S and Q then return true end if not S and not Q then return true end
if S and not Q then j.paused_task_routine[U]=J j.task_routine[U]=nil if L or
j.debug then h("paused task: "..tostring(U),h.info)h:dump()end return true end
if not S and Q then j.task_routine[U]=J j.paused_task_routine[U]=nil if L or
j.debug then h("resumed task: "..tostring(U),h.info)h:dump()end return true end
end end},__tostring=function()return"GuiH.SCHEDULED_THREAD."..U end})end
j.async=j.schedule j.add_listener=function(X,Z,et,tt)if not
_G.type(Z)=="function"then return end if not(_G.type(X)=="table"or
_G.type(X)=="string")then X={}end local at=et or o.uuid4()local
ot={filter=X,code=Z}j.event_listeners[at]=ot if tt or j.debug then
h("created event listener: "..at,h.success)h:dump()end return
setmetatable(ot,{__index={kill=function()j.event_listeners[at]=nil
j.paused_listeners[at]=nil if tt or j.debug then
h("killed event listener: "..at,h.success)h:dump()end
end,pause=function()j.paused_listeners[at]=ot j.event_listeners[at]=nil if tt
or j.debug then h("paused event listener: "..at,h.success)h:dump()end
end,resume=function()local ot=j.paused_listeners[at]or j.event_listeners[at]if
ot then j.event_listeners[at]=ot j.paused_listeners[at]=nil if tt or j.debug
then h("resumed event listener: "..at,h.success)h:dump()end elseif tt or
j.debug then h("event listener not found: "..at,h.error)h:dump()end
end},__tostring=function()return"GuiH.EVENT_LISTENER."..at end})end
j.cause_exeption=function(it)N=it end j.stop=function()S=false end
j.kill=j.stop j.error=j.cause_exeption j.clear=function(nt)if nt or j.debug
then h("clearing the gui..",h.update)end local st={}for ht,rt in
pairs(e.types)do st[rt]={}end j.gui=st j.elements=st local
dt=e.main(j,st,h)j.create=dt j.new=dt end j.isHeld=function(...)local
lt={...}local ut,ct=true,true for mt,ft in pairs(lt)do local
wt=j.held_keys[ft]or{}if wt[1]then ut=ut and true ct=ct and wt[2]else return
false,false,j.held_keys end end return ut,ct,j.held_keys end
j.key.held=j.isHeld
j.execute=setmetatable({},{__call=function(yt,pt,vt,bt,gt)if S then
h("Coulnt execute. Gui is already running",h.error)h:dump()return false end
N=nil S=true h("")h("loading execute..",h.update)local kt=j.term_object local
qt local jt=kt.getBackgroundColor()local xt=coroutine.create(function()local
zt,Et=pcall(function()kt.setVisible(true)x(0)kt.redraw()while true do
kt.setVisible(false)kt.setBackgroundColor(j.background or jt)kt.clear();(bt or
function()end)(kt)local qt=a(j,nil,true,false,nil);(vt or
function()end)(kt,qt);(gt or function()end)(kt)kt.setVisible(true);end end)if
not zt then N=Et h:dump()end end)h("created graphic routine 1",h.update)local
Tt=pt or function()end local function At()local Ot,It=pcall(Tt,kt)if not Ot
then N=It h:dump()end end h("created custom updater",h.update)local
Nt=coroutine.create(function()while true do
kt.setVisible(false)j.update(0,true,nil,{type="mouse_click",x=-math.huge,y=-math.huge,button=-math.huge});(gt
or function()end)(kt)kt.setVisible(true)kt.setVisible(false)if
j.update_delay<0.05 then os.queueEvent("waiting")os.pullEvent()else
sleep(j.update_delay)end end
end)h("created event listener handle",h.update)local
St=coroutine.create(function()local Ht,Rt=pcall(function()while true do local
Dt=table.pack(os.pullEventRaw())for Lt,Ut in pairs(j.event_listeners)do local
Ct=Ut.filter if _G.type(Ct)=="string"then Ct={[Ut.filter]=true}end if
Ct[Dt[1]]or Ct==Dt[1]or(not next(Ct))then
Ut.code(table.unpack(Dt,_G.type(Ut.filter)~="table"and 2 or 1,Dt.n))end end end
end)if not Ht then N=Rt h:dump()end
end)h("created graphic routine 2",h.update)local
Mt=coroutine.create(function()while true do local Ft,Wt,Yt=os.pullEvent()if
Ft=="key"then j.held_keys[Wt]={true,Yt}end if Ft=="key_up"then
j.held_keys[Wt]=nil end end end)h("created key handler")local
Pt=coroutine.create(At)coroutine.resume(Pt)coroutine.resume(xt,"mouse_click",math.huge,-math.huge,-math.huge)coroutine.resume(xt,"mouse_click",math.huge,-math.huge,-math.huge)coroutine.resume(xt,"mouse_click",math.huge,-math.huge,-math.huge)h("")h("Started execution..",h.success)h("")h:dump()while((coroutine.status(Pt)~="dead"or
not(_G.type(pt)=="function"))and coroutine.status(xt)~="dead"and N==nil)and S
do local qt=table.pack(os.pullEventRaw())if o.events_with_cords[qt[1]]then
qt[3]=qt[3]-(j.event_offset_x)qt[4]=qt[4]-(j.event_offset_y)end if
qt[1]=="terminate"then N="Terminated"break end if qt[1]~="guih_data_event"then
coroutine.resume(St,table.unpack(qt,1,qt.n))end
coroutine.resume(Pt,table.unpack(qt,1,qt.n))if qt[1]=="key"or
qt[1]=="key_up"then coroutine.resume(Mt,table.unpack(qt,1,qt.n))end for Vt,Bt
in pairs(j.task_routine)do if coroutine.status(Bt.c)~="dead"then if
Bt.filter==qt[1]or Bt.filter==nil then local
Gt,Kt=coroutine.resume(Bt.c,table.unpack(qt,1,qt.n))if Gt then Bt.filter=Kt end
end else j.task_routine[Vt]=nil j.task_schedule[Vt]=nil if Bt.dbug then
h("Finished sheduled task: "..tostring(Vt),h.success)end end end
coroutine.resume(xt,table.unpack(qt,1,qt.n))coroutine.resume(Nt,table.unpack(qt,1,qt.n))local
k,q=s.getSize()if k~=j.w or q~=j.h then if(qt[1]=="monitor_resize"and
j.monitor==qt[2])or j.monitor=="term_object"then
j.term_object.reposition(1,1,k,q)coroutine.resume(xt,"mouse_click",math.huge,-math.huge,-math.huge)j.w,j.h=k,q
j.width,j.height=k,q end end end if N then j.last_err=N end
kt.setVisible(true)if N then
h("a Fatal error occured: "..N..debug.traceback(),h.fatal)else
h("finished execution",h.success)end h:dump()N=nil return j.last_err,true
end,__tostring=function()return"GuiH.main_gui_executor"end})j.run=j.execute if
u=="monitor"then
h("Display object: monitor",h.info)j.monitor=peripheral.getName(c)else
h("Display object: term",h.info)j.monitor="term_object"end
j.load_texture=function(Qt)h("Loading nimg texture.. ",h.update)local
Jt=t.load_texture(Qt)return Jt end j.load_ppm_texture=function(Xt,Zt)local
ea,ta,aa=pcall(t.load_ppm_texture,j.term_object,Xt,Zt,h)if ea then return ta,aa
else h("Failed to load texture: "..ta,h.error)end end
j.load_cimg_texture=function(oa)h("Loading cimg texture.. ",h.update)local
ia=t.load_cimg_texture(oa)return ia end
j.load_blbfor_texture=function(na)h("Loading blbfor texture.. ",h.update)local
sa,ha=t.load_blbfor_texture(na)return sa,ha end
j.load_limg_texture=function(ra,da,la)h("Loading limg texture.. ",h.update)local
ua,ca=t.load_limg_texture(ra,da,la)return ua,ca end
j.load_limg_animation=function(ma,fa)h("Loading limg animation.. ",h.update)local
wa=t.load_limg_animation(ma,fa)return wa end
j.load_blbfor_animation=function(ya)h("Loading blbfor animation.. ",h.update)local
pa=t.load_blbfor_animation(ya)return pa end
j.set_event_offset=function(va,ba)j.event_offset_x,j.event_offset_y=va or
j.event_offset_x,ba or j.event_offset_y end
h("")h("Starting creator..",h.info)local ga=e.main(j,j.gui,h)j.create=ga
j.new=ga h("")j.update=x
h("loading text object...",h.update)h("")j.get_blit=function(ka,qa,ja)local xa
pcall(function()xa={j.term_object.getLine(ka)}end)if not xa then return false
end return xa[1]:sub(qa,ja),xa[2]:sub(qa,ja),xa[3]:sub(qa,ja)end
j.text=function(za)za=za or{}if _G.type(za.centered)~="boolean"then
za.centered=false end local
Ea=(_G.type(za.text)=="string")and("0"):rep(#za.text)or("0"):rep(13)local
Ta=(_G.type(za.text)=="string")and("f"):rep(#za.text)or("f"):rep(13)if
_G.type(za.blit)~="table"then za.blit={Ea,Ta}end za.blit[1]=(za.blit[1]or
Ea):lower()za.blit[2]=(za.blit[2]or
Ta):lower()h("created new text object",h.info)return setmetatable({text=za.text
or"<TEXT OBJECT>",centered=za.centered,x=za.x or 1,y=za.y or
1,offset_x=za.offset_x or 0,offset_y=za.offset_y or 0,blit=za.blit
or{Ea,Ta},transparent=za.transparent,bg=za.bg,fg=za.fg,width=za.width,height=za.height},{__call=function(Aa,Oa,Ia,Na,k,q)Ia,Na=Ia
or Aa.x,Na or Aa.y if Aa.width then k=Aa.width end if Aa.height then
q=Aa.height end local Sa=Oa or j.term_object local Ha if
_G.type(Ia)=="number"and _G.type(Na)=="number"then Ha=1 end if
_G.type(Ia)~="number"then Ia=1 end if _G.type(Na)~="number"then Na=1 end local
Ra,Da=Ia,Na local La={}for Ua in Aa.text:gmatch("[^\n]+")do
table.insert(La,Ua)end if Aa.centered then Da=Da-#La/2 else Da=Da-1 end for
Ca=1,#La do local Ma=La[Ca]Da=Da+1 if Aa.centered then local Fa=(q or
j.h)/2-0.5 local Wa=math.ceil(((k or
j.w)/2)-(#Ma/2)-0.5)Sa.setCursorPos(Wa+Aa.offset_x+Ra,Fa+Aa.offset_y+Da)Ia,Na=Wa+Aa.offset_x+Ra,Fa+Aa.offset_y+Da
else Sa.setCursorPos((Ha or Aa.x)+Aa.offset_x+Ra-1,(Ha or
Aa.y)+Aa.offset_y+Da-1)Ia,Na=(Ha or Aa.x)+Aa.offset_x+Ra-1,(Ha or
Aa.y)+Aa.offset_y+Da-1 end if Aa.transparent==true then local Ya=-1 if Ia<1
then Ya=math.abs(math.min(Ia+1,3)-2)Sa.setCursorPos(1,Na)Ia=1
Ma=Ma:sub(Ya+1)end local Ea,Ta=table.unpack(Aa.blit)if Aa.bg then
Ta=t.code.to_blit[Aa.bg]:rep(#Ma)end if Aa.fg then
Ea=t.code.to_blit[Aa.fg]:rep(#Ma)end local Pa
pcall(function()_,_,Pa=Sa.getLine(math.floor(Na))end)if not Pa then return end
local Va=Pa:sub(Ia,math.min(Ia+#Ma-1,j.w))local Ba=#Ma-#Va-1 if#Ea~=#Ma then
Ea=("0"):rep(#Ma)end
Sa.blit(Ma,Ea:sub(math.min(Ia,1)),Va..Ta:sub(#Ta-Ba,#Ta))else local
Ea,Ta=table.unpack(Aa.blit)if Aa.bg then Ta=t.code.to_blit[Aa.bg]:rep(#Ma)end
if Aa.fg then Ea=t.code.to_blit[Aa.fg]:rep(#Ma)end if#Ea~=#Ma then
Ea=("0"):rep(#Ma)end if#Ta~=#Ma then Ta=("f"):rep(#Ma)end Sa.blit(Ma,Ea,Ta)end
end end,__tostring=function()return"GuiH.primitive.text"end})end return j end
return
i