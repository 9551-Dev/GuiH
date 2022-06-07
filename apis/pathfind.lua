local e=false local t if not e then t=require("cc.expect").expect end local
function a(o,i,n,s)if not e then
t(1,o,"number")t(2,i,"number")t(3,n,"number")t(4,s,"boolean","nil")end if
s==nil then s=true end local h=0 local r=0 return
setmetatable({passable=s,gCost=h,hCost=r,pos=vector.new(o,i,n),},{__index=function(d,l)if
l=="fCost"then return d.gCost+d.hCost end end})end local function u(c,m)m=m
or{}if c==0 then return m end setmetatable(m,{__index=function(f,w)local
y=u(c-1)f[w]=y return y end})return m end local function p(v,b)local g={}local
k={}for q,j in pairs(v)do local x=math.abs(q-b)g[#g+1],k[x]=x,q end local
z=math.min(table.unpack(g))return v[k[z]]end local function E(T,A)return
math.sqrt((T.pos.x-A.pos.x)^2+(T.pos.y-A.pos.y)^2+(T.pos.z-A.pos.z)^2)end local
function O(I)local N={}for S,H in pairs(I)do N[(#I-S+1)]=H end return N end
local function R(D,L,U,C,M,F)if not e then
t(1,D,"number")t(2,L,"number")t(3,U,"number")t(4,C,"number","nil")t(5,M,"number","nil")t(6,F,"number","nil")end
C,M,F=C or 1,M or 1,F or 1 local W=u(3,{})for Y=C,C+D do for P=M,M+L do for
V=F,F+U do W[Y][P][V]=a(Y,P,V,true)end end end
return{grid=W,size={w=D,h=L,d=U}}end local function
B(G,K,Q)table.insert(G,Q)K[Q.pos.x][Q.pos.y][Q.pos.z]=#G end local function
J(X,Z,a)return X[Z[a.pos.x][a.pos.y][a.pos.z]]or{}end local function
et(tt,at)local ot,it=tt.pos,at.pos return ot.x==it.x and ot.y==it.y and
ot.z==it.z end local function nt(st)for ht,rt in pairs(st)do for dt,lt in
pairs(rt)do for ut,a in pairs(lt)do st[ht][dt][ut]=st[ht][dt][ut]-1 end end end
end local function ct(a,mt)local ft={}for wt=-1,1 do for yt=-1,1 do for pt=-1,1
do local vt=vector.new(math.abs(wt),math.abs(yt),math.abs(pt))if not(wt==0 and
yt==0 and pt==0)and(vt.x+vt.y+vt.z==1)then local bt=a.pos.x+wt local
gt=a.pos.y+yt local kt=a.pos.z+pt if bt<mt.size.w+1 and gt<mt.size.h+1 and
kt<mt.size.d+1 then local qt=mt.grid[bt][gt][kt]if next(qt)then
table.insert(ft,qt)end end end end end end return ft end local function
jt(xt)local zt={}local Et=xt[#xt]while Et do
table.insert(zt,vector.new(Et.pos.x,Et.pos.y,Et.pos.z))Et=Et.parent end return
O(zt)end local function Tt(At,Ot,It)if not e then
t(1,At,"table")t(2,Ot,"table")t(3,It,"table")end local Nt=Ot local St=It local
Ht={}local Rt={}local Dt=u(2)local Lt=u(2)B(Ht,Dt,Nt)while next(Ht)do local
Ut=Ht[1]for Ct,Mt in ipairs(Ht)do
if(Mt.fCost<Ut.fCost)or((Mt.fCost==Ut.fCost)and Mt.hCost<Ut.hCost)then Ut=Mt
end end B(Rt,Lt,Ut)table.remove(Ht,1)nt(Dt)Dt[Ut.pos.x][Ut.pos.y][Ut.pos.z]=nil
if et(Ut,St)then return jt(Rt)end for Ft,Wt in pairs(ct(Ut,At))do if not(not
Wt.passable or next(J(Rt,Lt,Wt)))then local
Yt=Ut.gCost+E(Ut,Wt)if(Yt<Wt.gCost)or not next(J(Ht,Dt,Wt))then Wt.gCost=Yt
Wt.hCost=E(Wt,St)Wt.parent=Ut if not next(J(Ht,Dt,Wt))then B(Ht,Dt,Wt)end end
end end os.queueEvent("pathfinding")os.pullEvent("pathfinding")end return false
end local function Pt(Vt)if not e then t(1,Vt,"table")end local
Bt,Gt=math.huge,-math.huge local Kt,Qt=math.huge,-math.huge local
Jt,Xt=math.huge,-math.huge for Zt,ea in pairs(Vt)do
Bt,Gt=math.min(Bt,Zt),math.max(Gt,Zt)for ta,aa in pairs(ea)do
Kt,Qt=math.min(Kt,ta),math.max(Qt,ta)for oa,ia in pairs(aa)do
Jt,Xt=math.min(Jt,oa),math.max(Xt,oa)end end end
return{w=math.abs(Bt)+Gt,h=math.abs(Kt)+Qt,d=math.abs(Jt)+Xt}end
return{pathfind=Tt,node=a,createField=R,get_array_whd=Pt,index_proximal=p,createNDarray=u}