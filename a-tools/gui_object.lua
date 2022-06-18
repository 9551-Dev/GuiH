local e=require("object_loader")local t=require("graphic_handle")local
a=require("a-tools.update")local o=require("api") local
function i(n,s,h,r,d)local l={}local u="term_object"local c=s local function
m(f)r,d=0,0 pcall(function()local function w(y)local
p,v=y.getPosition()r=r+(p-1)d=d+(v-1)local
b,g=debug.getupvalue(y.reposition,5)if g.reposition and g~=term.current()then
c=g w(g)elseif g~=nil then c=g end end w(n)end)if f then f.event_offset_x=r
f.event_offset_y=d end end if not r or not d then m()end
pcall(function()u=peripheral.getType(c)end)for k,q in pairs(e.types)do
l[q]={}end local j,x=n.getSize()local
z={term_object=n,term=n,gui=l,update=a,visible=true,id=o.uuid4(),task_schedule={},update_delay=0.05,held_keys={},log=h,task_routine={},paused_task_routine={},w=j,h=x,width=j,height=x,event_listeners={},paused_listeners={},background=n.getBackgroundColor(),cls=false,key={},texture_cache={},debug=false,event_offset_x=r,event_offset_y=d,}z.elements=z.gui
z.calibrate=function()m(z)end z.getSize=function()return z.w,z.h end
h("set up updater",h.update)local function E(T,A,O,I,N,S)return
a(z,T,A,O,I,N,S)end local H local R=false z.schedule=function(D,L,U,C)local
M=o.uuid4()if C or z.debug then
h("created new thread: "..tostring(M),h.info)end local F={}local
W={c=coroutine.create(function()local Y,P=pcall(function()if L then
o.precise_sleep(L)end D(z,z.term_object)end)if not Y then if U==true then H=P
end F.err=P if C or z.debug then
h("error in thread: "..tostring(M).."\n"..tostring(P),h.error)h:dump()end end
end),dbug=C}z.task_routine[M]=W local function V(...)local
B=z.task_routine[M]or z.paused_task_routine[M]if B then local
G,H=coroutine.resume(B.c,...)if not G then F.err=H if C or z.debug then
h("task "..tostring(M).." error: "..tostring(H),h.error)h:dump()end end return
true,G,H else if C or z.debug then
h("task "..tostring(M).." not found",h.error)h:dump()end return false end end
return setmetatable(W,{__index={kill=function()z.task_routine[M]=nil
z.paused_task_routine[M]=nil if C or z.debug then
h("killed task: "..tostring(M),h.info)h:dump()end return true
end,alive=function()local K=z.task_routine[M]or z.paused_task_routine[M]if not
K then return false end return
coroutine.status(K.c)~="dead"end,step=V,update=V,pause=function()local
Q=z.task_routine[M]or z.paused_task_routine[M]if Q then
z.paused_task_routine[M]=Q z.task_routine[M]=nil if C or z.debug then
h("paused task: "..tostring(M),h.info)h:dump()end return true else if C or
z.debug then h("task "..tostring(M).." not found",h.error)h:dump()end return
false end end,resume=function()local J=z.paused_task_routine[M]or
z.task_routine[M]if J then z.task_routine[M]=J z.paused_task_routine[M]=nil if
C or z.debug then h("resumed task: "..tostring(M),h.info)h:dump()end return
true else if C or z.debug then
h("task "..tostring(M).." not found",h.error)h:dump()end return false end
end,get_error=function()return F.err end,set_running=function(X,C)local
Z=z.task_routine[M]or z.paused_task_routine[M]local R=z.task_routine[M]~=nil if
Z then if R and X then return true end if not R and not X then return true end
if R and not X then z.paused_task_routine[M]=Z z.task_routine[M]=nil if C or
z.debug then h("paused task: "..tostring(M),h.info)h:dump()end return true end
if not R and X then z.task_routine[M]=Z z.paused_task_routine[M]=nil if C or
z.debug then h("resumed task: "..tostring(M),h.info)h:dump()end return true end
end end},__tostring=function()return"GuiH.SCHEDULED_THREAD."..M end})end
z.async=z.schedule z.add_listener=function(et,tt,at,ot)if not
_G.type(tt)=="function"then return end if not(_G.type(et)=="table"or
_G.type(et)=="string")then et={}end local it=at or o.uuid4()local
nt={filter=et,code=tt}z.event_listeners[it]=nt if ot or z.debug then
h("created event listener: "..it,h.success)h:dump()end return
setmetatable(nt,{__index={kill=function()z.event_listeners[it]=nil
z.paused_listeners[it]=nil if ot or z.debug then
h("killed event listener: "..it,h.success)h:dump()end
end,pause=function()z.paused_listeners[it]=nt z.event_listeners[it]=nil if ot
or z.debug then h("paused event listener: "..it,h.success)h:dump()end
end,resume=function()local nt=z.paused_listeners[it]or z.event_listeners[it]if
nt then z.event_listeners[it]=nt z.paused_listeners[it]=nil if ot or z.debug
then h("resumed event listener: "..it,h.success)h:dump()end elseif ot or
z.debug then h("event listener not found: "..it,h.error)h:dump()end
end},__tostring=function()return"GuiH.EVENT_LISTENER."..it end})end
z.cause_exeption=function(st)H=tostring(st)end z.stop=function()R=false end
z.kill=z.stop z.error=z.cause_exeption z.clear=function(ht)if ht or z.debug
then h("clearing the gui..",h.update)end local rt={}for dt,lt in
pairs(e.types)do rt[lt]={}end z.gui=rt z.elements=rt local
ut=e.main(z,rt,h)z.create=ut z.new=ut end z.isHeld=function(...)local
ct={...}local mt,ft=true,true for wt,yt in pairs(ct)do local
pt=z.held_keys[yt]or{}if pt[1]then mt=mt and true ft=ft and pt[2]else return
false,false,z.held_keys end end return mt,ft,z.held_keys end
z.key.held=z.isHeld
z.execute=setmetatable({},{__call=function(vt,bt,gt,kt,qt)if R then
h("Coulnt execute. Gui is already running",h.error)h:dump()return false end
H=nil R=true h("")h("loading execute..",h.update)local jt=z.term_object local
xt local zt=jt.getBackgroundColor()local Et=coroutine.create(function()local
Tt,At=pcall(function()jt.setVisible(true)E(0)jt.redraw()while true do
jt.setVisible(false)jt.setBackgroundColor(z.background or zt)jt.clear();(kt or
function()end)(jt)local xt=a(z,nil,true,false,nil);(gt or
function()end)(jt,xt);(qt or function()end)(jt)jt.setVisible(true);end end)if
not Tt then H=At h:dump()end end)h("created graphic routine 1",h.update)local
Ot=bt or function()end local function It()local Nt,St=pcall(Ot,jt)if not Nt
then H=St h:dump()end end h("created custom updater",h.update)local
Ht=coroutine.create(function()while true do
jt.setVisible(false)z.update(0,true,nil,{type="mouse_click",x=-math.huge,y=-math.huge,button=-math.huge});(qt
or function()end)(jt)jt.setVisible(true)jt.setVisible(false)if
z.update_delay<0.05 then os.queueEvent("waiting")os.pullEvent()else
sleep(z.update_delay)end end
end)h("created event listener handle",h.update)local
Rt=coroutine.create(function()local Dt,Lt=pcall(function()while true do local
Ut=table.pack(os.pullEventRaw())for Ct,Mt in pairs(z.event_listeners)do local
Ft=Mt.filter if _G.type(Ft)=="string"then Ft={[Mt.filter]=true}end if
Ft[Ut[1]]or Ft==Ut[1]or(not next(Ft))then
Mt.code(table.unpack(Ut,_G.type(Mt.filter)~="table"and 2 or 1,Ut.n))end end end
end)if not Dt then H=Lt h:dump()end
end)h("created graphic routine 2",h.update)local
Wt=coroutine.create(function()while true do local Yt,Pt,Vt=os.pullEvent()if
Yt=="key"then z.held_keys[Pt]={true,Vt}end if Yt=="key_up"then
z.held_keys[Pt]=nil end end end)h("created key handler")local
Bt=coroutine.create(It)coroutine.resume(Bt)coroutine.resume(Et,"mouse_click",math.huge,-math.huge,-math.huge)coroutine.resume(Et,"mouse_click",math.huge,-math.huge,-math.huge)coroutine.resume(Et,"mouse_click",math.huge,-math.huge,-math.huge)h("")h("Started execution..",h.success)h("")h:dump()while((coroutine.status(Bt)~="dead"or
not(_G.type(bt)=="function"))and coroutine.status(Et)~="dead"and H==nil)and R
do local xt=table.pack(os.pullEventRaw())if o.events_with_cords[xt[1]]then
xt[3]=xt[3]-(z.event_offset_x)xt[4]=xt[4]-(z.event_offset_y)end if
xt[1]=="terminate"then H="Terminated"break end if xt[1]~="guih_data_event"then
coroutine.resume(Rt,table.unpack(xt,1,xt.n))end
coroutine.resume(Bt,table.unpack(xt,1,xt.n))if xt[1]=="key"or
xt[1]=="key_up"then coroutine.resume(Wt,table.unpack(xt,1,xt.n))end for Gt,Kt
in pairs(z.task_routine)do if coroutine.status(Kt.c)~="dead"then if
Kt.filter==xt[1]or Kt.filter==nil then local
Qt,Jt=coroutine.resume(Kt.c,table.unpack(xt,1,xt.n))if Qt then Kt.filter=Jt end
end else z.task_routine[Gt]=nil z.task_schedule[Gt]=nil if Kt.dbug then
h("Finished sheduled task: "..tostring(Gt),h.success)end end end
coroutine.resume(Et,table.unpack(xt,1,xt.n))coroutine.resume(Ht,table.unpack(xt,1,xt.n))local
j,x=s.getSize()if j~=z.w or x~=z.h then if(xt[1]=="monitor_resize"and
z.monitor==xt[2])or z.monitor=="term_object"then
z.term_object.reposition(1,1,j,x)coroutine.resume(Et,"mouse_click",math.huge,-math.huge,-math.huge)z.w,z.h=j,x
z.width,z.height=j,x end end end if H then z.last_err=H end
jt.setVisible(true)if H then
h("a Fatal error occured: "..H..debug.traceback(),h.fatal)else
h("finished execution",h.success)end h:dump()H=nil return z.last_err,true
end,__tostring=function()return"GuiH.main_gui_executor"end})z.run=z.execute if
u=="monitor"then
h("Display object: monitor",h.info)z.monitor=peripheral.getName(c)else
h("Display object: term",h.info)z.monitor="term_object"end
z.load_texture=function(Xt)h("Loading nimg texture.. ",h.update)local
Zt=t.load_texture(Xt)return Zt end z.load_ppm_texture=function(ea,ta)local
aa,oa,ia=pcall(t.load_ppm_texture,z.term_object,ea,ta,h)if aa then return oa,ia
else h("Failed to load texture: "..oa,h.error)end end
z.load_cimg_texture=function(na)h("Loading cimg texture.. ",h.update)local
sa=t.load_cimg_texture(na)return sa end
z.load_blbfor_texture=function(ha)h("Loading blbfor texture.. ",h.update)local
ra,da=t.load_blbfor_texture(ha)return ra,da end
z.load_limg_texture=function(la,ua,ca)h("Loading limg texture.. ",h.update)local
ma,fa=t.load_limg_texture(la,ua,ca)return ma,fa end
z.load_limg_animation=function(wa,ya)h("Loading limg animation.. ",h.update)local
pa=t.load_limg_animation(wa,ya)return pa end
z.load_blbfor_animation=function(va)h("Loading blbfor animation.. ",h.update)local
ba=t.load_blbfor_animation(va)return ba end
z.set_event_offset=function(ga,ka)z.event_offset_x,z.event_offset_y=ga or
z.event_offset_x,ka or z.event_offset_y end
h("")h("Starting creator..",h.info)local qa=e.main(z,z.gui,h)z.create=qa
z.new=qa h("")z.update=E
h("loading text object...",h.update)h("")z.get_blit=function(ja,xa,za)local Ea
pcall(function()Ea={z.term_object.getLine(ja)}end)if not Ea then return false
end return Ea[1]:sub(xa,za),Ea[2]:sub(xa,za),Ea[3]:sub(xa,za)end
z.text=function(Ta)Ta=Ta or{}if _G.type(Ta.centered)~="boolean"then
Ta.centered=false end local
Aa=(_G.type(Ta.text)=="string")and("0"):rep(#Ta.text)or("0"):rep(13)local
Oa=(_G.type(Ta.text)=="string")and("f"):rep(#Ta.text)or("f"):rep(13)if
_G.type(Ta.blit)~="table"then Ta.blit={Aa,Oa}end Ta.blit[1]=(Ta.blit[1]or
Aa):lower()Ta.blit[2]=(Ta.blit[2]or
Oa):lower()h("created new text object",h.info)return setmetatable({text=Ta.text
or"<TEXT OBJECT>",centered=Ta.centered,x=Ta.x or 1,y=Ta.y or
1,offset_x=Ta.offset_x or 0,offset_y=Ta.offset_y or 0,blit=Ta.blit
or{Aa,Oa},transparent=Ta.transparent,bg=Ta.bg,fg=Ta.fg,width=Ta.width,height=Ta.height},{__call=function(Ia,Na,Sa,Ha,j,x)Sa,Ha=Sa
or Ia.x,Ha or Ia.y if Ia.width then j=Ia.width end if Ia.height then
x=Ia.height end local Ra=Na or z.term_object local Da if
_G.type(Sa)=="number"and _G.type(Ha)=="number"then Da=1 end if
_G.type(Sa)~="number"then Sa=1 end if _G.type(Ha)~="number"then Ha=1 end local
La,Ua=Sa,Ha local Ca={}for Ma in Ia.text:gmatch("[^\n]+")do
table.insert(Ca,Ma)end if Ia.centered then Ua=Ua-#Ca/2 else Ua=Ua-1 end for
Fa=1,#Ca do local Wa=Ca[Fa]Ua=Ua+1 if Ia.centered then local Ya=(x or
z.h)/2-0.5 local Pa=math.ceil(((j or
z.w)/2)-(#Wa/2)-0.5)Ra.setCursorPos(Pa+Ia.offset_x+La,Ya+Ia.offset_y+Ua)Sa,Ha=Pa+Ia.offset_x+La,Ya+Ia.offset_y+Ua
else Ra.setCursorPos((Da or Ia.x)+Ia.offset_x+La-1,(Da or
Ia.y)+Ia.offset_y+Ua-1)Sa,Ha=(Da or Ia.x)+Ia.offset_x+La-1,(Da or
Ia.y)+Ia.offset_y+Ua-1 end if Ia.transparent==true then local Va=-1 if Sa<1
then Va=math.abs(math.min(Sa+1,3)-2)Ra.setCursorPos(1,Ha)Sa=1
Wa=Wa:sub(Va+1)end local Aa,Oa=table.unpack(Ia.blit)if Ia.bg then
Oa=t.code.to_blit[Ia.bg]:rep(#Wa)end if Ia.fg then
Aa=t.code.to_blit[Ia.fg]:rep(#Wa)end local Ba
pcall(function()_,_,Ba=Ra.getLine(math.floor(Ha))end)if not Ba then return end
local Ga=Ba:sub(Sa,math.min(Sa+#Wa-1,z.w))local Ka=#Wa-#Ga-1 if#Aa~=#Wa then
Aa=("0"):rep(#Wa)end
pcall(Ra.blit,Wa,Aa:sub(math.min(Sa,1)),Ga..Oa:sub(#Oa-Ka,#Oa))else local
Aa,Oa=table.unpack(Ia.blit)if Ia.bg then Oa=t.code.to_blit[Ia.bg]:rep(#Wa)end
if Ia.fg then Aa=t.code.to_blit[Ia.fg]:rep(#Wa)end if#Aa~=#Wa then
Aa=("0"):rep(#Wa)end if#Oa~=#Wa then Oa=("f"):rep(#Wa)end pcall(Ra.blit,Wa,Aa,Oa)end
end end,__tostring=function()return"GuiH.primitive.text"end})end return z end
return i
