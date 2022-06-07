local function e(t,a,o)local i={}for n=a,o do
t.seek("set",n)table.insert(i,t.read())end return
string.char(table.unpack(i))end local function s(h,r)local d=r local l={}for
u=1,3 do local c={}local m=""while not(m==0x20 or m==0x0A)do
h.seek("set",d)m=h.read()table.insert(c,m)d=d+1 end
table.insert(l,tonumber(string.char(table.unpack(c))))end return l,d end local
function f(w,y,p)local v=y local b={}local g=0 w.seek("set",y)while w.read()do
g=g+1 end w.seek("set",v)for k=1,math.floor(g/3)do local q=""for k=1,3 do local
j=0 local x={}while q and j<3 do w.seek("set",v)q=w.read()if q~=nil then
q=q/p[3]end table.insert(x,q)v=v+1 j=j+1 end if not next(x)then break end
table.insert(b,{r=x[1],g=x[2],b=x[3]})end end return b,g/3 end local function
z(E,T,A)local O={}for I,N in pairs(E)do local S=math.floor((I-1)%T+1)local
H=math.ceil(I/T)if not O[A and S or H]then O[A and S or H]={}end O[A and S or
H][A and H or S]=N end return O end local function R(D)local
L=fs.open(D,"rb")if not L then error("File: "..(D or"").." doesnt exist",3)end
if e(L,0,2)=="P6\x0A"then local U=-math.huge while true do local C=L.read()if
string.char(C)=="#"then while true do local M=L.read()if M==0x0A then break end
U=L.seek("cur")+1 end else local F,U=s(L,U)local W,Y=f(L,U,F)local
C=z(W,F[1],true)local
P=L.readAll()L.close()return{data=P,meta=F,pixels=C,pixel_count=Y,width=F[1],height=F[2],color_type=F[3],get_pixel=function(V,B)local
G=C[math.floor(V+0.5)]if G then return G[math.floor(B+0.5)]end
end,get_palette=function()local K={}local Q=0 local J={}local X={}for Z,et in
pairs(W)do local tt=colors.packRGB(et.r,et.g,et.b)if not K[tt]then Q=Q+1
K[tt]={c=tt,count=0}end K[tt].count=K[tt].count+1 end for at,ot in pairs(K)do
table.insert(J,ot)end table.sort(J,function(it,nt)return it.count>nt.count
end)for st,ht in ipairs(J)do local
rt,dt,lt=colors.unpackRGB(ht.c)table.insert(X,{r=rt,g=dt,b=lt,c=ht.count})end
return X,Q end}end end else
L.close()error("File is unsupported format: "..e(L,0,1),2)end end return
R