local
e={{colors.red},{colors.yellow},{colors.white,colors.red},{colors.white,colors.lime},{colors.white,colors.lime},{colors.white},{colors.green},{colors.gray},}local
t={error=1,warn=2,fatal=3,success=4,message=6,update=7,info=8}local a={}for o,i
in pairs(t)do a[i]=o end local function n(s)local
s=s:gsub("^%[%d-%:%d-% %a-]","")return s end local function h(r,d,l,u)local
c,m=r.getSize()local f,w={},math.ceil(#d/c)local y=0 for p=1,w do local
v,b=r.getCursorPos()if b>m then r.scroll(1)r.setCursorPos(1,b-1)b=b-1 end
r.write(d:sub(y+1,p*c))r.setCursorPos(1,b+1)y=p*c end return w end local
function g(k,q)local j=k.getSize()local x,z={},math.ceil(#q/j)local E=0 local T
for A=1,z do local O=q:sub(E+1,A*j)E=A*j T=#O end return T end function
t:dump(I)local N=""local S=1 local H={}local R=""for D,L in
ipairs(self.history)do if N==n(L.str)..L.type then S=S+1 table.remove(H,#H)else
S=1 end
H[#H+1]=L.str.."("..tostring(S)..") type: "..(a[L.type]or"info")N=n(L.str)..L.type
end for U,C in ipairs(H)do R=R..C.."\n"end if type(I)=="string"then local
M=fs.open(I..".log","w")M.write(R)M.close()end return R end local function
F(W,Y,P)local V,B=W.term.getSize()local G,K=W.term.getCursorPos()local
Y=tostring(Y)P=P or"info"if W.lastLog==Y..P then W.nstr=W.nstr+1 local
Q=K-W.maxln W.term.setCursorPos(G,Q)else W.nstr=1 end W.lastLog=Y..P local
J="["..textutils.formatTime(os.time()).."] "local
X,Z=W.term.getBackgroundColor(),W.term.getTextColor()local
et,tt=unpack(e[P]or{})W.term.setBackgroundColor(tt or X);W.term.setTextColor(et
or colors.gray)local at=J..Y.."("..tostring(W.nstr)..")"local ot=#at if ot<1
then ot=1 end local it=V-ot if it<1 then it=1 end it=V-(g(W.term,at))local
nt=J..Y..(" "):rep(it)table.insert(W.history,{str=nt,type=P})W.maxln=h(W.term,nt.."("..tostring(W.nstr)..")",X,W.title)local
G,K=W.term.getCursorPos()W.term.setBackgroundColor(W.sbg);W.term.setTextColor(W.sfg)if
W.title then
W.term.setCursorPos(1,1)W.term.write((W.tsym):rep(V))W.term.setCursorPos(math.ceil((V/2)-(#W.title/2)),1)W.term.write(W.title)W.term.setCursorPos(G,K)end
W.term.setBackgroundColor(X);W.term.setTextColor(Z)end local function
st(ht,rt,dt,lt,ut)dt=dt or"-"local ct,mt=ht.getSize()local
ft=setmetatable({lastLog="",nstr=1,maxln=1,term=ht,history={},title=rt,tsym=(#dt<4)and
dt
or"-",sbg=ht.getBackgroundColor(),sfg=ht.getTextColor(),auto_dump=lt},{__index=t,__call=F})if
ft.title then
ft.term.setCursorPos(1,1)ft.term.write((ft.tsym):rep(ct))ft.term.setCursorPos(math.ceil((ct/2)-(#ft.title/2)),1)ft.term.write(ft.title)ft.term.setCursorPos(1,2)end
ft.lastLog=nil return ft end
return{create_log=st}