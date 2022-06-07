local e=require"a-tools.luappm"local t=require"a-tools.blbfor".open local
a=require"api"local o=require"cc.expect"local i="0123456789abcdef"local
n,s={},{}for h=0,15 do n[2^h]=i:sub(h+1,h+1)s[i:sub(h+1,h+1)]=2^h end local
r=function(d)local l=a.tables.createNDarray(2)l["offset"]=d["offset"]for u,c in
pairs(d)do for m,f in pairs(c)do if type(f)=="table"then l[u][m]={}if f then
l[u][m].t=s[f.t]l[u][m].b=s[f.b]l[u][m].s=f.s end end end end return
setmetatable(l,getmetatable(d))end local function w(y)local
p,v=math.huge,-math.huge local b,g=math.huge,-math.huge for k,q in pairs(y)do
p,v=math.min(p,k),math.max(v,k)for j,x in pairs(q)do
b,g=math.min(b,j),math.max(g,j)end end return math.abs(p)+v,math.abs(b)+g end
local function z(E,T)local A={}local O={}for I,N in pairs(E)do local
S=math.abs(I-T)A[#A+1],O[S]=S,I end local H=math.min(table.unpack(A))return
E[O[H]]end local function R(D,L)if not next(D)then return nil end if D[L]then
return D[L]end local U=math.floor(L+0.5)if D[U]then return D[U]end for
C=1,math.huge do if D[U+C]then return D[U+C]end if D[U-C]then return D[U-C]end
end end local function M(F)local W,Y if
not(type(F)=="table")and(F:match(".nimg$")and fs.exists(F))then
W=fs.open(F,"r")if not W then error("file doesnt exist",2)end
Y=textutils.unserialise(W.readAll())else Y=F end local
P=a.tables.createNDarray(2,r(Y))local V=a.tables.createNDarray(2)for B,G in
pairs(P)do if type(B)~="string"then for K,Y in pairs(G)do
V[B-P.offset[1]+1][K-P.offset[2]+5]={text_color=Y.t,background_color=Y.b,symbol=Y.s}end
end end V.scale={w(V)}return
setmetatable({tex=V,offset=P.offset,id=a.uuid4()},{__tostring=function()return"GuiH.texture"end})end
local function Q(J)local X o(1,J,"string","table")if type(J)=="table"then X=J
else local
Z=fs.open(J,"r")assert(Z,"file doesnt exist")X=textutils.unserialise(Z.readAll())Z.close()end
local et=a.tables.createNDarray(2,{offset={5,13,11,4}})for tt,at in pairs(X)do
for ot,it in pairs(at)do et[tt+4][ot+7]={s=" ",b=it,t="0"}end end return
M(et)end local function nt(st)local ht,rt=pcall(t,st,"r")if not ht then
error(rt,3)end local dt={}for lt=1,rt.layers do local
ut=a.tables.createNDarray(2,{offset={5,13,11,4}})for ct=1,rt.width do for
mt=1,rt.height do local
ft,wt,yt=rt:read_pixel(lt,ct,mt,true)ut[ct+4][mt+8]={s=ft,b=yt,t=wt}end end
dt[lt]=M(ut)end return dt end local function pt(vt,bt)bt=bt or colors.black
local gt=fs.open(vt,"r")if not gt then error("file doesnt exist",2)end local
kt=textutils.unserialise(gt.readAll())gt.close()assert(kt.type=="lImg"or
kt.type==nil,"not an limg image")local qt={}for jt,xt in pairs(kt)do if
jt~="type"and xt~="lImg"then local
zt=a.tables.createNDarray(2,{offset={5,13,11,4}})for Et,Tt in pairs(xt)do local
At,Ot,It=Tt[3]:gsub("T",n[bt]),Tt[2]:gsub("T",n[bt]),Tt[1]local
Nt=a.piece_string(At)local St=a.piece_string(Ot)local Ht=a.piece_string(It)for
Rt,Dt in pairs(Ht)do zt[Rt+4][Et+8]={s=Dt,b=Nt[Rt],t=St[Rt]}end end
qt[jt]=M(zt)end end return qt end local function Lt(Ut,Ct,Mt)local
Ft=pt(Ut,Ct)return Ft[Mt or 1],Ft end local function Wt(Yt)local
Pt=nt(Yt)return Pt[1],Pt end local function Vt(Bt,Gt)local Kt={}for Qt=0,15 do
local
Jt,Xt,Zt=Bt.getPaletteColor(2^Qt)table.insert(Kt,{dist=math.sqrt((Jt-Gt.r)^2+(Xt-Gt.g)^2+(Zt-Gt.b)^2),color=2^Qt})end
table.sort(Kt,function(ea,ta)return ea.dist<ta.dist end)return
Kt[1].color,Kt[1].dist,Kt end local function aa(oa,ia)local
na,sa,ha,ra={},{},{},{}local da=0 for la,ua in pairs(oa)do na[ua]=na[ua]~=nil
and{count=na[ua].count+1,c=na[ua].c}or(function()da=da+1
return{count=1,c=ua}end)()end for ca,ma in pairs(na)do if not ra[ma.c]then
ra[ma.c]=true if da==1 then table.insert(sa,ma)end table.insert(sa,ma)end end
table.sort(sa,function(fa,wa)return fa.count>wa.count end)for ya=1,6 do if
oa[ya]==sa[1].c then ha[ya]=1 elseif oa[ya]==sa[2].c then ha[ya]=0 else
ha[ya]=ia and 0 or 1 end end if ha[6]==1 then for pa=1,5 do ha[pa]=1-ha[pa]end
end local va=128 for ba=0,4 do va=va+ha[ba+1]*2^ba end return
string.char(va),ha[6]==1 and sa[2].c or sa[1].c,ha[6]==1 and sa[1].c or sa[2].c
end local function ga(ka,qa,ja,xa)ka[qa+ja*2-2]=xa return ka end local function
za(Ea,Ta,Aa,Oa)local
Ia=term.current()Oa("loading ppm texture.. ",Oa.update)Oa("decoding ppm.. ",Oa.update)local
Na=e(Ta)Oa("decoding finished. ",Oa.success)if Na then local
Sa={}Oa("transforming pixels to characters..",Oa.update)for Ha=1,Na.width do
for Ra=1,Na.height do local Da=Vt(Ea or Ia,Na.get_pixel(Ha,Ra))local
La,Ua=math.ceil(Ha/2),math.ceil(Ra/3)local Ca,Ma=(Ha-1)%2+1,(Ra-1)%3+1 if not
Sa[La]then Sa[La]={}end
Sa[La][Ua]=ga(Sa[La][Ua]or{},Ca,Ma,Da)os.queueEvent("")os.pullEvent("")end end
Oa("transformation finished. "..tostring((Na.width/2)*(Na.height/3)).." characters",Oa.success)local
Fa=a.tables.createNDarray(2,{offset={5,13,11,4}})Oa("building nimg format..",Oa.update)for
Wa,Ya in pairs(Sa)do for Pa,Va in pairs(Ya)do local
Ba,Ga,Ka=aa(Va,Aa)Fa[Wa+4][Pa+8]={s=Ba,t=n[Ga],b=n[Ka]}end end
Oa("building finished. texture loaded.",Oa.success)Oa("")Oa:dump()return
setmetatable(M(Fa),{__tostring=function()return"GuiH.texture"end}),Na end end
local function Qa(Ja,Xa,Za,eo)local to=Za.tex local
ao,oo=math.floor(to.scale[1]-0.5),math.floor(to.scale[2]-0.5)Ja=((Ja-1)%ao)+1
Xa=((Xa-1)%oo)+1 local io=to[Ja][Xa]local no=to.scale to.scale=nil if not io
and eo then local so=z(to,Ja)io=R(so or{},Xa)end to.scale=no return io end
local function ho(ro,lo,uo,co,mo,fo,wo,yo,po,vo,bo)local
go,ko,qo={},{},{}po,vo=po or 0,vo or 0 local jo=false if type(bo)=="table"and
bo[lo.id]then local xo=bo[lo.id].args jo=xo.x==uo and xo.y==co and xo.width==mo
and xo.height==fo and xo.bg==wo and xo.tg==yo and xo.offsetx==po and
xo.offsety==vo end if type(bo)=="table"and bo[lo.id]and jo then
go=bo[lo.id].bg_layers ko=bo[lo.id].fg_layers qo=bo[lo.id].text_layers else for
zo=1,fo do for Eo=1,mo do local To=Qa(Eo+po,zo+vo,lo)if To and next(To)then
go[zo]=(go[zo]or"")..n[To.background_color]ko[zo]=(ko[zo]or"")..n[To.text_color]qo[zo]=(qo[zo]or"")..To.symbol:match(".$")else
go[zo]=(go[zo]or"")..n[wo]ko[zo]=(ko[zo]or"")..n[yo]qo[zo]=(qo[zo]or"").." "end
end end if type(bo)=="table"then
bo[lo.id]={bg_layers=go,fg_layers=ko,text_layers=qo,args={term=ro,x=uo,y=co,width=mo,height=fo,bg=wo,tg=yo,offsetx=po,offsety=vo}}end
end for Ao,Oo in pairs(go)do
ro.setCursorPos(uo,co+Ao-1)ro.blit(qo[Ao],ko[Ao],go[Ao])end end
return{load_nimg_texture=M,load_ppm_texture=za,load_cimg_texture=Q,load_blbfor_texture=Wt,load_blbfor_animation=nt,load_limg_texture=Lt,load_limg_animation=pt,code={get_pixel=Qa,draw_box_tex=ho,to_blit=n,to_color=s,build_drawing_char=aa},load_texture=M}