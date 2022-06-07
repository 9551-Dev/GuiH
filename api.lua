local function e(t,a,o,i,n,s)return t>=o and t<o+n and a>=i and a<i+s end local
h=function(r,d,l)if d==0 then return l,l,l end local u=math.floor(r/60)local
c=(r/60)-u local m=l*(1-d)local f=l*(1-d*c)local w=l*(1-d*(1-c))if u==0 then
return l,w,m elseif u==1 then return f,l,m elseif u==2 then return m,l,w elseif
u==3 then return m,f,l elseif u==4 then return w,m,l elseif u==5 then return
l,m,f end end local function y(p,v)v=v or{}if p==0 then return v end
setmetatable(v,{__index=function(b,g)local k=y(p-1)b[g]=k return k end})return
v end local q=function(j)return setmetatable(j or{},{__index=function(x,z)local
E={}x[z]=E return E end})end local T=function(A)return setmetatable(A
or{},{__index=function(O,I)local N=q()O[I]=N return N end})end local function
S(...)local H={}for R,D in pairs({...})do for L,U in pairs(D)do
table.insert(H,U)end end return H end local function C(M,F,W)local Y=W-M.y
local P=F.y-M.y local V=M.x+(Y*(F.x-M.x))/P local B=M.z+(Y*(F.z-M.z))/P return
V,B end local function G(K,Q,J)local
X=K.z+(J-K.x)*(((Q.z-K.z)/(Q.x-K.x)))return X end local function
Z(et,tt,at,ot,it,nt,st,ht)local rt=(ot-st)/(ot-et)*at+(st-et)/(ot-et)*nt
return(it-ht)/(it-tt)*rt+(ht-tt)/(it-tt)*rt end local function dt(lt)local
ut=createSelfIndexArray()for ct,mt in pairs(lt)do if type(mt)=="table"then for
ft,wt in pairs(mt)do ut[ft][ct]=wt end end end return ut end local
yt=function(pt)local vt=0 for bt,gt in pairs(pt)do vt=vt+1 end return vt,#pt
end local kt=function(qt,jt)local xt=true local zt=yt(qt)local Et=yt(jt)for
Tt,At in pairs(qt)do if At~=jt[Tt]then xt=false end end if xt and zt==Et then
return true end end local function Ot(It)local Ot={}for Nt,St in pairs(It)do
table.insert(Ot,Nt)end return Ot end local function Ht(Rt)local Dt=0 local
Ot=Ot(Rt)table.sort(Ot,function(Lt,Ut)return Lt<Ut end)return function()Dt=Dt+1
if Rt[Ot[Dt]]then return Ot[Dt],Rt[Ot[Dt]]else return end end end local
function Ct()local Mt=math.random local
Ft='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'return
string.gsub(Ft,'[xy]',function(Wt)return string.format('%x',Wt=='x'and
Mt(0,0xf)or Mt(8,0xb))end)end local function Yt(Pt)local
Vt=os.epoch("utc")+Pt*1000 while os.epoch("utc")<Vt do
os.queueEvent("waiting")os.pullEvent()end end local function Bt(Gt)local
Kt={}Gt:gsub(".",function(Qt)table.insert(Kt,Qt)end)return Kt end local
function Jt(Xt)local Zt={}for ea=1,Xt do Zt[ea]={"","",""}end return Zt end
local
ta={monitor_touch=true,mouse_click=true,mouse_drag=true,mouse_scroll=true,mouse_up=true}return{is_within_field=e,tables={createNDarray=y,get_true_table_len=yt,compare_table=kt,switchXYArray=dt,create2Darray=q,create3Darray=T,iterate_order=Ht,merge=S},math={interpolateY=C,interpolateZ=G,interpolate_on_line=Z},HSVToRGB=h,uuid4=Ct,precise_sleep=Yt,piece_string=Bt,create_blit_array=Jt,events_with_cords=ta}