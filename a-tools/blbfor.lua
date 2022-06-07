local e=require("cc.expect").expect local t=0x0A local a=0x30 local
o={INTERNAL={STRING={}}}local i={}local n={}function
o.INTERNAL.STRING.FORMAT_BLIT(s)return("%x"):format(s)end function
o.INTERNAL.STRING.TO_BLIT(h,r)local d=(not
r)and(o.INTERNAL.STRING.FORMAT_BLIT(select(2,math.frexp(h))-1))or(select(2,math.frexp(h))-1)return
d end function o.INTERNAL.STRING.FROM_HEX(l)return tonumber(l,16)end function
o.INTERNAL.READ_BYTES_STREAM(u,c,m)local f={}u.seek("set",c)for w=c,c+m-1 do
local y=u.read()table.insert(f,y)end return table.unpack(f)end function
o.INTERNAL.STRING_TO_BYTES(p)local v={}for b=1,#p do v[b]=p:byte(b)end return
table.unpack(v)end function o.INTERNAL.WRITE_BYTES_STREAM(g,k,...)local
q={...}for j=1,#q do g.seek("set",k+j-1)g.write(q[j])end end function
o.INTERNAL.READ_STRING_UNTIL_SEP(x,z)local E=""x.seek("set",z)local
T=x.read()if not T then return false end while T~=t do
E=E..string.char(T)T=x.read()end return E end function
o.INTERNAL.READ_INT(A,O)local I=0 A.seek("set",O)local N=A.read()while N~=t do
I=I*10+(N-a)N=A.read()end return I end function
o.INTERNAL.COLORS_TO_BYTE(S,H)local R=select(2,math.frexp(S))-1 local
D=select(2,math.frexp(H))-1 return R*16+D end function
o.INTERNAL.BYTE_TO_COLORS(L)return
bit32.rshift(bit32.band(0xF0,L),4),bit32.band(0x0F,L)end function
o.INTERNAL.WRITE_HEADER(U)U.stream.seek("set",0)local
C=textutils.serialiseJSON(U.meta):gsub("\n","NEWLINE")o.INTERNAL.WRITE_BYTES_STREAM(U.stream,0,o.INTERNAL.STRING_TO_BYTES(("BLBFOR1\n%d\n%d\n%d\n%d\n%s\n"):format(U.width,U.height,U.layers,os.epoch("utc"),C)))end
function o.INTERNAL.ASSERT(M,F)if not M then error(F,3)else return M end end
function o.INTERNAL.createNDarray(W,Y)Y=Y or{}if W==0 then return Y end
setmetatable(Y,{__index=function(P,V)local
B=o.INTERNAL.createNDarray(W-1)P[V]=B return B end})return Y end function
o.INTERNAL.ENCODE(G)o.INTERNAL.WRITE_HEADER(G)for K,Q in ipairs(G.data)do for
J,X in ipairs(Q)do local Z={}for et,tt in ipairs(X)do
table.insert(Z,tt[1])table.insert(Z,o.INTERNAL.COLORS_TO_BYTE(2^tt[2],2^tt[3]))end
o.INTERNAL.WRITE_BYTES_STREAM(G.stream,G.stream.seek("cur"),table.unpack(Z))end
end end function o.INTERNAL.DECODE(at)at.stream.seek("set",0)local
ot=o.INTERNAL.READ_STRING_UNTIL_SEP(at.stream,0)local
it=o.INTERNAL.createNDarray(2)o.INTERNAL.ASSERT(ot=="BLBFOR1","Invalid header",2)local
nt=o.INTERNAL.READ_INT(at.stream,at.stream.seek("cur"))local
st=o.INTERNAL.READ_INT(at.stream,at.stream.seek("cur"))local
ht=o.INTERNAL.READ_INT(at.stream,at.stream.seek("cur"))local
rt=o.INTERNAL.READ_INT(at.stream,at.stream.seek("cur"))local
dt=textutils.unserializeJSON(o.INTERNAL.READ_STRING_UNTIL_SEP(at.stream,at.stream.seek("cur")))at.width=nt
at.height=st at.layers=ht at.meta=dt at.last_flushed=rt
at.data=o.INTERNAL.createNDarray(3,at.data)for lt=1,at.layers do for ut=1,st do
if not next(it[lt][ut])then it[lt][ut]={"","",""}end local ct={}for mt=1,nt do
local ft={}local
wt,yt=o.INTERNAL.READ_BYTES_STREAM(at.stream,at.stream.seek("cur"),2)ft[1]=wt
ft[2],ft[3]=o.INTERNAL.BYTE_TO_COLORS(yt)ct[mt]=ft
it[lt][ut]={it[lt][ut][1]..string.char(ft[1]),it[lt][ut][2]..o.INTERNAL.STRING.FORMAT_BLIT(ft[2]),it[lt][ut][3]..o.INTERNAL.STRING.FORMAT_BLIT(ft[3])}end
at.data[lt][ut]=ct end end at.lines=it end function
i:set_pixel(pt,vt,bt,gt,kt,qt)o.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")o.INTERNAL.ASSERT(not
self.closed,"Image handle closed")e(1,pt,"number")e(2,vt,"number")e(3,bt,"number")e(4,gt,"string")e(5,kt,"number")e(6,qt,"number")o.INTERNAL.ASSERT(not(vt<1
or bt<1 or vt>self.width or
bt>self.height),"pixel out of range")self.data[pt][bt][vt]={gt:byte(),o.INTERNAL.STRING.TO_BLIT(kt,true),o.INTERNAL.STRING.TO_BLIT(qt,true)}end
function
n:get_pixel(jt,xt,zt,Et)o.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")e(1,jt,"number")e(2,xt,"number")e(3,zt,"number")e(4,Et,"boolean","nil")o.INTERNAL.ASSERT(not(xt<1
or zt<1 or xt>self.width or zt>self.height),"pixel out of range")local
Tt=self.data[jt][zt][xt]local At={string.char(Tt[1]),2^Tt[2],2^Tt[3]}local
Ot={string.char(Tt[1]),o.INTERNAL.STRING.FORMAT_BLIT(Tt[2]),o.INTERNAL.STRING.FORMAT_BLIT(Tt[3])}return
table.unpack(Et and Ot or At)end function
n:get_line(It,Nt)o.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")e(1,It,"number")e(2,Nt,"number")o.INTERNAL.ASSERT(not(Nt<1
or Nt>self.height),"line out of range")return
self.lines[It][Nt][1],self.lines[It][Nt][2],self.lines[It][Nt][3]end function
i:set_line(St,Ht,Rt,Dt,Lt)o.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")o.INTERNAL.ASSERT(not
self.closed,"Image handle closed")e(1,St,"number")e(2,Ht,"number")e(3,Rt,"string")e(4,Dt,"string")e(5,Lt,"string")o.INTERNAL.ASSERT(#Dt==#Rt
and#Lt==#Rt,"line length mismatch")o.INTERNAL.ASSERT(#Rt<=self.width,"line too long")o.INTERNAL.ASSERT(Ht<=self.height
and Ht>0,"line out of range")for Ut=1,#Rt do
self:set_pixel(St,Ut,Ht,Rt:sub(Ut,Ut),2^o.INTERNAL.STRING.FROM_HEX(Dt:sub(Ut,Ut)),2^o.INTERNAL.STRING.FROM_HEX(Lt:sub(Ut,Ut)))end
end function
i:close()o.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")o.INTERNAL.ASSERT(not
self.closed,"Image handle closed")o.INTERNAL.ENCODE(self)self.stream.close()self.closed=true
end function
i:flush()o.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")o.INTERNAL.ASSERT(not
self.closed,"Image handle closed")o.INTERNAL.ENCODE(self)self.stream.flush()end
i.write_pixel=i.set_pixel i.write_line=i.set_line n.read_pixel=n.get_pixel
n.read_line=n.get_line function
o.open(Ct,Mt,Ft,Wt,Yt,Pt,Vt,Bt,Gt)e(1,Ct,"string")e(2,Mt,"string")local
Kt=Ct:match("%.%a+$")o.INTERNAL.ASSERT(Kt==".bbf","file must be a .bbf file")local
Qt={}if Mt:sub(1,1):lower()=="w"then
e(3,Ft,"number")e(4,Wt,"number")e(5,Yt,"number","nil")e(6,Pt,"string","nil")e(7,Vt,"string","nil")e(8,Bt,"string","nil")e(9,Gt,"table","nil")Yt=Yt
or 1 local Jt=fs.open(Ct,"wb")if not Jt then error("Could not open file",2)end
Qt.meta=Gt or{}Qt.width=Ft Qt.height=Wt Qt.layers=Yt
Qt.data=o.INTERNAL.createNDarray(3)Qt.stream=Jt for Xt=1,Yt do for Zt=1,Ft do
for ea=1,Wt do Qt.data[Xt][ea][Zt]={(Bt or
string.char(0)):byte(),o.INTERNAL.STRING.TO_BLIT(Pt or
colors.black,true),o.INTERNAL.STRING.TO_BLIT(Vt or colors.black,true)}end end
end return setmetatable(Qt,{__index=i})elseif Mt:sub(1,1):lower()=="r"then
local ta=fs.open(Ct,"rb")if not ta then error("Could not open file",2)end local
aa=ta.seek("cur")Qt.raw=ta.readAll()ta.seek("set",aa)Qt.stream=ta
o.INTERNAL.DECODE(Qt)Qt.closed=true ta.close()return
setmetatable(Qt,{__index=n})else
stream.close()error("invalid mode. please use \"w\" or \"r\" (Write/Read)",2)end
end return
o