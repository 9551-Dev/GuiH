local e=require("api")local function t(a)local o=type(a)local i if
o=="table"then i={}for n,s in next,a,nil do if n=="canvas"then i.canvas=s else
i[t(n)]=t(s)end end setmetatable(i,t(getmetatable(a)))else i=a end return i end
return{main=function(h,r,d)local l=h local u={}local c=fs.list("objects")for
m,f in pairs(c)do d("loading object: "..f,d.update)local
w,y=pcall(require,"objects."..f..".object")if w and type(y)=="function"then
local p,v=pcall(require,"objects."..f..".logic")local
b,g=pcall(require,"objects."..f..".graphic")if p and b
and(type(v)=="function")and(type(g)=="function")then local
k=fs.list(fs.combine("objects",f))local q={}local j={}for x,z in pairs(k)do
local E=z:match("(.*)%.")or z if not(E=="logic"or E=="graphic"or
E=="object")and(not fs.isDir("objects/"..f.."/"..E))then
d("objects."..f.."."..E)local T,A=pcall(require,"objects."..f.."."..E)if T then
d("found custom object flag \""..E.."\" for: "..f,d.update)q[E]=require("objects."..f.."."..E)else
d("bad object flag "..A)end else if E=="manipulators"then
d("found custom object manipulators for: "..f,d.update)local
O=fs.list("objects/"..f.."/manipulators")for x,z in pairs(O)do local
I,N=pcall(require,"objects."..f..".manipulators."..z:match("(.*)%.")or z)if I
then
d("found custom object manipulator \""..z.."\" for: "..f,d.update)j[z:match("(.*)%.")or
z]=setmetatable({},{__call=function(S,...)return
N(...)end,__index=N,__tostring=function()return"GuiH."..f..".manipulator"end})else
d("bad object manipulator "..N)end end end end end
u[f]=setmetatable({},{__index=q,__tostring=function()return"GuiH.element_builder."..f
end,__call=function(H,R)local l=y(l,R)if not(type(l.name)=="string")then
l.name=e.uuid4()end if not(type(l.order)=="number")then l.order=1 end if
not(type(l.logic_order)=="number")then l.logic_order=1 end if
not(type(l.graphic_order)=="number")then l.graphic_order=1 end if
not(type(l.react_to_events)=="table")then l.react_to_events={}end if
not(type(l.btn)=="table")then l.btn={}end if
not(type(l.visible)=="boolean")then l.visible=true end if
not(type(l.reactive)=="boolean")then l.reactive=true end r[f][l.name]=l local
D=t(j)or{}D.logic=v D.graphic=g D.kill=function()if r[f][l.name]then
r[f][l.name]=nil d("killed "..f.." > "..l.name,d.warn)return true else
d("tried to manipulate dead object.",d.error)return
false,"object no longer exist"end end D.get_position=function()if
r[f][l.name]then if l.positioning then return l.positioning else return
false,"object doesnt have positioning information"end else
d("tried to manipulate dead object.",d.error)return
false,"object no longer exist"end end D.replicate=function(L)L=L or e.uuid4()if
r[f][l.name]then if L==l.name then return"name of copy cannot be the same!"else
d("Replicated "..f.." > "..l.name.." as "..f.." > "..L,d.info)local
U=t(r[f][l.name])r[f][L or""]=U U.name=L return U,true end else
d("tried to manipulate dead object.",d.error)return
false,"object no longer exist"end end D.isolate=function()if r[f][l.name]then
local
l=t(r[f][l.name])d("isolated "..f.." > "..l.name,d.info)return{parse=function(C)d("parsed "..f.." > "..l.name,d.info)if
l then local C=C or l.name if r[f][C]then r[f][C]=nil end r[f][C]=l return
r[f][C]else return false,"object no longer exist"end end,get=function()if l
then d("returned "..f.." > "..l.name,d.info)return l else return
false,"object no longer exist"end
end,clear=function()d("Removed copied object "..f.." > "..l.name,d.info)l=nil
end,}else d("tried to manipulate dead object.",d.error)return
false,"object no longer exist"end end D.cut=function()if r[f][l.name]then local
l=t(r[f][l.name])r[f][l.name]=nil
d("cut "..f.." > "..l.name,d.info)return{parse=function()if l then
d("parsed "..f.." > "..l.name,d.info)if r[f][l.name]then r[f][l.name]=nil end
r[f][l.name]=l return r[f][l.name]else return false,"object no longer exist"end
end,get=function()d("returned "..f.." > "..l.name,d.info)return l
end,clear=function()d("Removed copied object "..f.." > "..l.name,d.info)l=nil
end}else d("tried to manipulate dead object.",d.error)return
false,"object no longer exist"end end D.destroy=D.kill D.murder=D.destroy
D.copy=D.isolate if not type(D.logic)=="function"then
d("object "..f.." has invalid logic.lua",d.error)return false end if not
type(D.graphic)=="function"then
d("object "..f.." has invalid graphic.lua",d.error)return false end
setmetatable(l,{__index=D,__tostring=function()return"GuiH.element."..f.."."..l.name
end})if l.positioning then
setmetatable(l.positioning,{__tostring=function()return"GuiH.element.position"end})end
l.canvas=h d("created new "..f.." > "..l.name,d.info)d:dump()return l end})else
if not p and b then d(f.." is missing an logic file !",d.error)end if not b and
p then d(f.." is missing an graphic file !",d.error)end if not p and not b then
d(f.." is missing logic and graphic file !",d.error)end if p
and(type(v)~="function")then d(f.." has an invalid logic file !",d.error)end if
b and(type(g)~="function")then
d(f.." has an invalid graphic file !",d.error)end if b and p
and(type(g)~="function")and(type(v)~="function")then
d(f.." has an invalid logic and graphic file !",d.error)end end else if w and
not(type(y)=="function")then d(f.." has invalid object file!",d.error)else
d(f.." is missing an object file !",d.error)end end end
return u
end,types=fs.list("objects")}
