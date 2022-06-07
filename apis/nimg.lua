local e=require("cc.expect").expect local t={}local a={}local o={}local
i="0123456789abcdef"local n,s={},{}for h=0,15 do
n[2^h]=i:sub(h+1,h+1)s[i:sub(h+1,h+1)]=2^h end local r=function(d)local
l=setmetatable({},{__index=function(u,c)local m={}u[c]=m return m
end})l["offset"]=d["offset"]for f,w in pairs(d)do for y,p in pairs(w)do if
type(p)=="table"then l[f][y]={}if p then
l[f][y].t=s[p.t]l[f][y].b=s[p.b]l[f][y].s=p.s end end end end return
setmetatable(l,getmetatable(d))end local v=function(b)local
g=setmetatable({},{__index=function(k,q)local j={}k[q]=j return j
end})g["offset"]=b["offset"]for x,z in pairs(b)do for E,T in pairs(z)do if
type(T)=="table"then g[x][E]={}if T then
g[x][E].t=n[T.t]g[x][E].b=n[T.b]g[x][E].s=T.s end end end end return
setmetatable(g,getmetatable(b))end local function A(O,I,N)if
type(I)=="number"and type(N)=="number"then local S={}local H={}local R local
D=1 local L=1 S["offset"]=O.offset H["offset"]=O.offset for U,C in pairs(O)do
if type(U)=="number"then for M,F in pairs(C)do for W=1,I do if I>1 then D=I end
if not S[U*D+W]then S[U*D+W]={}end if not S[U*D+W][M]then S[U*D+W][M]={}end
S[U*D+W][M]=O[U][M]end end end end if N>1 then for Y,P in pairs(S)do if
type(Y)=="number"then for V,B in pairs(P)do for G=1,N do if N>1 then L=N end if
not H[Y]then H[Y]={}end if not H[Y][V*L+G]then H[Y][V*L+G]={}end
H[Y][V*L+G]=S[Y][V]end end end end end if not next(S)then S=O end if N>1 then
R=H else R=S end return setmetatable(R,getmetatable(O))else return O end end
function t:strech(K,Q)local J=self if not self then
error("try using : instead of .",0)end if type(K)=="number"and
type(Q)=="number"then local X={}local Z={}local et local tt=1 local at=1
X["offset"]=J.offset Z["offset"]=J.offset for ot,it in pairs(J)do if
type(ot)=="number"then for nt,st in pairs(it)do for ht=1,K do if K>1 then tt=K
end if not X[ot*tt+ht]then X[ot*tt+ht]={}end if not X[ot*tt+ht][nt]then
X[ot*tt+ht][nt]={}end X[ot*tt+ht][nt]=J[ot][nt]end end end end if Q>1 then for
rt,dt in pairs(X)do if type(rt)=="number"then for lt,ut in pairs(dt)do for
ct=1,Q do if Q>1 then at=Q end if not Z[rt]then Z[rt]={}end if not
Z[rt][lt*at+ct]then Z[rt][lt*at+ct]={}end Z[rt][lt*at+ct]=X[rt][lt]end end end
end end if not next(X)then X=J end if Q>1 then et=Z else et=X end return
setmetatable(et,getmetatable(J))else return J end end function
t:draw(mt,ft,wt,yt,pt)e(1,mt,"table","nil")e(2,ft,"number","nil")e(3,wt,"number","nil")local
self=A(self,yt,pt)local vt=mt or term local ft=ft or 0 local wt=wt or 0 local
bt=vt.getBackgroundColor()local gt=vt.getTextColor()for kt,qt in pairs(self)do
if type(kt)=="number"then for jt,xt in pairs(qt)do
vt.setCursorPos(kt-(self.offset[1])+ft,jt-(self.offset[2]/2)+wt)vt.setBackgroundColor(xt.b)vt.setTextColor(xt.t)vt.write(xt.s)end
end end vt.setBackgroundColor(bt)vt.setTextColor(gt)end function
a:drawImage(zt,Et,Tt,At,Ot,It)e(1,zt,"table","nil")e(2,Et,"number")e(3,Tt,"number","nil")e(4,At,"number","nil")if
not self then return false end local Et=Et or 1 local
Nt=self[1][math.min(Et,#self[1])]local Nt=A(Nt,Ot,It)if Nt then local St=zt or
term if not Tt then Tt=0 end if not At then At=0 end local
Ht=St.getBackgroundColor()local Rt=St.getTextColor()for Dt,Lt in pairs(Nt)do if
type(Dt)=="number"then for Ut,Ct in pairs(Lt)do
St.setCursorPos(Dt-(Nt.offset[1])+Tt,Ut-(Nt.offset[2]/2)+At)St.setBackgroundColor(Ct.b)St.setTextColor(Ct.t)St.write(Ct.s)end
end end St.setBackgroundColor(Ht)St.setTextColor(Rt)end end function
a:animate(Mt,Ft,Wt,Yt,Pt,Vt,Bt,Gt)e(1,Mt,"table")e(2,Ft,"number")e(3,Wt,"number")e(4,Yt,"number")e(5,Pt,"boolean")e(6,Vt,"boolean")local
Kt=Mt or term.current()local Qt,Jt=Kt.getSize()if Pt then
Kt=window.create(Kt,1,1,Qt,Jt)end local Ft=Ft or 0 local Wt=Wt or 0 if not Yt
then Yt=1 end if Vt==nil then Vt=false end if Pt==nil then Pt=false end local
Xt=Kt.getBackgroundColor()local Zt=Kt.getTextColor()for ea,ta in
ipairs(self[1])do local ta=A(ta,Bt,Gt)if Pt then Kt.setVisible(false)end
Kt.setBackgroundColor(Xt)Kt.setTextColor(Zt)if Vt then Kt.clear()end local aa=0
local oa=0 for ia,na in pairs(ta)do aa=aa+1 end for sa,ha in pairs(ta)do if
type(sa)=="number"then for ra,da in pairs(ha)do
Kt.setCursorPos(sa-(ta.offset[1])+Ft,ra-(ta.offset[2]/2)+Wt)Kt.setBackgroundColor(da.b)Kt.setTextColor(da.t)Kt.write(da.s)end
end end if Pt then Kt.setVisible(true)end oa=oa+1 if oa<#self[1]then
sleep(Yt)end end Kt.setBackgroundColor(Xt)Kt.setTextColor(Zt)end function
a:slide(la,ua,ca,ma,fa)e(1,la,"table")e(2,ua,"number")e(3,ca,"number")local
wa=self[1]local ya=self[2]+1 if not wa[ya]then return
setmetatable({wa,0,false},{__index=a})end local pa=la or term local ua=ua or 0
local ca=ca or 0 local va=pa.getBackgroundColor()local
ba=pa.getTextColor()wa[ya]=A(wa[ya],ma,fa)for ga,ka in pairs(wa[ya])do if
type(ga)=="number"then for qa,ja in pairs(ka)do
pa.setCursorPos(ga-(wa[ya].offset[1])+ua,qa-(wa[ya].offset[2]/2)+ca)pa.setBackgroundColor(ja.b)pa.setTextColor(ja.t)pa.write(ja.s)end
end end pa.setBackgroundColor(va)pa.setTextColor(ba)return
setmetatable({wa,ya,true},{__index=a})end function a:iterate()local xa=0 local
za=self[1]return function()xa=xa+1 if za[xa]then return
setmetatable(za[xa],{__index=t}),za,xa end end end local function
Ea(Ta)e(1,Ta,"string")local Ta=Ta or""if not fs.exists(Ta..".nimg")then
error("not found. try using file name wihnout .nimg note that all files need to have .nimg extension to work",2)end
local Aa=fs.open(Ta..".nimg","r")local
Oa=textutils.unserialize(Aa.readAll())local Ia=r(Oa)Aa.close()return
setmetatable(Ia,{__index=t})end local function Na(Sa)local
Ha={}e(1,Sa,"string")local Sa=Sa or""if not fs.isDir(Sa..".animg")then
error("not found. try using file name wihnout .animg note that all image sets need to have .animg as extension to work!",2)end
for Ra,Da in pairs(fs.list(Sa..".animg"))do local
La,Ua=Da:match("^(%d+).+(%..-)$")if Ua==".nimg"then local
Ca=fs.open(Sa..".animg/"..Da,"r")Ha[tonumber(La)]=textutils.unserialise(Ca.readAll())Ha[tonumber(La)]=r(Ha[tonumber(La)])Ca.close()end
end return setmetatable({Ha,0},{__index=a})end function
o:startBuffer(Ma)e(1,Ma,"boolean","nil")self.setVisible(false)if not Ma then
buffer.clear()end end function o:endBuffer()self.setVisible(true)end local
function Fa(Wa)e(1,Wa,"table")local Ya=Wa or term.current()local
Pa,Va=Ya.getSize()return
setmetatable(window.create(Ya,1,1,Pa,Va),{__index=o})end local function
Ba()return require("ButtonH")end local function Ga(Ka)local
Qa,Ja=http.get("https://pastebin.com/raw/"..Ka)if Ja then error(Ja,0)end local
Xa=tostring(math.random(1,1000000))local
Za=fs.open("9551_NIMG_MAIN_API_TEMP_PASTKAGE_"..Xa,"w")Za.write(Qa.readAll())Za.close()Qa.close()local
eo=0 for to in io.lines("9551_NIMG_MAIN_API_TEMP_PASTKAGE_"..Xa)do eo=eo+1 if
eo==1 then if to~="**PASTEKAGE**"then error("not an pastekage!",0)end end if
eo>1 then local ao,oo=to:match("^%[(.+)%]:(.+)")local
no,Ja=http.get("https://pastebin.com/raw/"..oo)if Ja then error(Ja,0)end local
so=fs.open(ao,"w")so.write(no.readAll())so.close()no.close()end end
fs.delete("9551_NIMG_MAIN_API_TEMP_PASTKAGE_"..Xa)end
return{loadImage=Ea,loadImageSet=Na,getButtonH=Ba,createBuffer=Fa,stretch2DMap=A,downloadPastekage=Ga,encode=v,decode=r}