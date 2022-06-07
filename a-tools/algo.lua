local e=require("api")local function t(a,o,i,n,s)local
h,r=math.ceil(math.floor(a-0.5)/2),math.ceil(math.floor(o-0.5)/2)local d,l=0,r
local u=((r*r)-(h*h*r)+(0.25*h*h))local c=2*r^2*d local m=2*h^2*l local
f={}while c<m do
table.insert(f,{x=d+i,y=l+n})table.insert(f,{x=-d+i,y=l+n})table.insert(f,{x=d+i,y=-l+n})table.insert(f,{x=-d+i,y=-l+n})if
s then for l=-l+n+1,l+n-1 do
table.insert(f,{x=d+i,y=l})table.insert(f,{x=-d+i,y=l})end end if u<0 then
d=d+1 c=c+2*r^2 u=u+c+r^2 else d,l=d+1,l-1 c=c+2*r^2 m=m-2*h^2 u=u+c-m+r^2 end
end local w=(((r*r)*((d+0.5)*(d+0.5)))+((h*h)*((l-1)*(l-1)))-(h*h*r*r))while
l>=0 do
table.insert(f,{x=d+i,y=l+n})table.insert(f,{x=-d+i,y=l+n})table.insert(f,{x=d+i,y=-l+n})table.insert(f,{x=-d+i,y=-l+n})if
s then for l=-l+n,l+n do
table.insert(f,{x=d+i,y=l})table.insert(f,{x=-d+i,y=l})end end if w>0 then
l=l-1 m=m-2*h^2 w=w+h^2-m else l=l-1 d=d+1 m=m-2*h^2 c=c+2*r^2 w=w+c-m+h^2 end
end return f end local function y(p,v,b,g)local k=(g.x-v.x)/(g.y-v.y)local
q=(g.x-b.x)/(g.y-b.y)local j=math.ceil(v.y-0.5)local x=math.ceil(g.y-0.5)-1 for
z=j,x do local E=k*(z+0.5-v.y)+v.x local T=q*(z+0.5-b.y)+b.x local
A=math.ceil(E-0.5)local O=math.ceil(T-0.5)for I=A,O do
table.insert(p,{x=I,y=z})end end end local function N(S,H,R,D)local
L=(R.x-H.x)/(R.y-H.y)local U=(D.x-H.x)/(D.y-H.y)local C=math.ceil(H.y-0.5)local
M=math.ceil(D.y-0.5)-1 for F=C,M do local W=L*(F+0.5-H.y)+H.x local
Y=U*(F+0.5-H.y)+H.x local P=math.ceil(W-0.5)local V=math.ceil(Y-0.5)for B=P,V
do table.insert(S,{x=B,y=F})end end end local function G(K,Q,J)local X={}if
Q.y<K.y then K,Q=Q,K end if J.y<Q.y then Q,J=J,Q end if Q.y<K.y then K,Q=Q,K
end if K.y==Q.y then if Q.x<K.x then K,Q=Q,K end y(X,K,Q,J)elseif Q.y==J.y then
if J.x<Q.x then J,Q=Q,J end N(X,K,Q,J)else local Z=(Q.y-K.y)/(J.y-K.y)local
et={x=K.x+((J.x-K.x)*Z),y=K.y+((J.y-K.y)*Z),}if Q.x<et.x then
N(X,K,Q,et)y(X,Q,et,J)else N(X,K,et,Q)y(X,et,Q,J)end end return X end local
function tt(at,ot,it,nt)local st={}for at=at,at+it do for ot=ot,ot+nt do
table.insert(st,{x=at,y=ot})end end end local function ht(rt,dt,lt,ut)local
ct={}rt,dt,lt,ut=math.floor(rt),math.floor(dt),math.floor(lt),math.floor(ut)if
rt==lt and dt==ut then return{x=rt,y=dt}end local mt=math.min(rt,lt)local
ft,wt,yt if mt==rt then wt,ft,yt=dt,lt,ut else wt,ft,yt=ut,rt,dt end local
pt,vt=ft-mt,yt-wt if pt>math.abs(vt)then local bt=wt local gt=vt/pt for
kt=mt,ft do table.insert(ct,{x=kt,y=math.floor(bt+0.5)})bt=bt+gt end else local
qt,jt=mt,pt/vt if yt>=wt then for xt=wt,yt do
table.insert(ct,{x=math.floor(qt+0.5),y=xt})qt=qt+jt end else for zt=wt,yt,-1
do table.insert(ct,{x=math.floor(qt+0.5),y=zt})qt=qt-jt end end end return ct
end local function Et(Tt,At,Ot)local It={}local Nt=ht(Tt.x,Tt.y,At.x,At.y)local
St=ht(At.x,At.y,Ot.x,Ot.y)local Ht=ht(Ot.x,Ot.y,Tt.x,Tt.y)return
e.tables.merge(Nt,St,Ht)end
return{get_elipse_points=t,get_triangle_points=G,get_triangle_outline_points=Et,get_line_points=ht}