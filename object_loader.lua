local e=require("api")local t=fs.getDir(select(2,...))local function a(o)local
i=type(o)local n if i=="table"then n={}for s,h in next,o,nil do if
s=="canvas"then n.canvas=h else n[a(s)]=a(h)end end
setmetatable(n,a(getmetatable(o)))else n=o end return n end
return{main=function(r,d,l)local u=r local c={}local
m=fs.list(fs.combine(t,"objects"))for f,w in pairs(m)do
l("loading object: "..w,l.update)local
y,p=pcall(require,"objects."..w..".object")if y and type(p)=="function"then
local v,b=pcall(require,"objects."..w..".logic")local
g,k=pcall(require,"objects."..w..".graphic")if v and g
and(type(b)=="function")and(type(k)=="function")then local
q=fs.list(fs.combine(t.."/objects/",w))local j={}local x={}for z,E in
pairs(q)do local T=E:match("(.*)%.")or E if not(T=="logic"or T=="graphic"or
T=="object")and(not fs.isDir(t.."/objects/"..w.."/"..T))then
l("objects."..w.."."..T)local A,O=pcall(require,"objects."..w.."."..T)if A then
l("found custom object flag \""..T.."\" for: "..w,l.update)j[T]=require("objects."..w.."."..T)else
l("bad object flag "..O)end else if T=="manipulators"then
l("found custom object manipulators for: "..w,l.update)local
I=fs.list(t.."/objects/"..w.."/manipulators")for z,E in pairs(I)do local
N,S=pcall(require,"objects."..w..".manipulators."..E:match("(.*)%.")or E)if N
then
l("found custom object manipulator \""..E.."\" for: "..w,l.update)x[E:match("(.*)%.")or
E]=setmetatable({},{__call=function(H,...)return
S(...)end,__index=S,__tostring=function()return"GuiH."..w..".manipulator"end})else
l("bad object manipulator "..S)end end end end end
c[w]=setmetatable({},{__index=j,__tostring=function()return"GuiH.element_builder."..w
end,__call=function(R,D)local u=p(u,D)if not(type(u.name)=="string")then
u.name=e.uuid4()end if not(type(u.order)=="number")then u.order=1 end if
not(type(u.logic_order)=="number")then u.logic_order=1 end if
not(type(u.graphic_order)=="number")then u.graphic_order=1 end if
not(type(u.react_to_events)=="table")then u.react_to_events={}end if
not(type(u.btn)=="table")then u.btn={}end if
not(type(u.visible)=="boolean")then u.visible=true end if
not(type(u.reactive)=="boolean")then u.reactive=true end d[w][u.name]=u local
L=x or{}L.logic=b L.graphic=k L.kill=function()if d[w][u.name]then
d[w][u.name]=nil l("killed "..w.." > "..u.name,l.warn)return true else
l("tried to manipulate dead object.",l.error)return
false,"object no longer exist"end end L.get_position=function()if
d[w][u.name]then if u.positioning then return u.positioning else return
false,"object doesnt have positioning information"end else
l("tried to manipulate dead object.",l.error)return
false,"object no longer exist"end end L.replicate=function(U)U=U or e.uuid4()if
d[w][u.name]then if U==u.name then return"name of copy cannot be the same!"else
l("Replicated "..w.." > "..u.name.." as "..w.." > "..U,l.info)local
C=a(d[w][u.name])d[w][U or""]=C C.name=U return C,true end else
l("tried to manipulate dead object.",l.error)return
false,"object no longer exist"end end L.isolate=function()if d[w][u.name]then
local
u=a(d[w][u.name])l("isolated "..w.." > "..u.name,l.info)return{parse=function(M)l("parsed "..w.." > "..u.name,l.info)if
u then local M=M or u.name if d[w][M]then d[w][M]=nil end d[w][M]=u return
d[w][M]else return false,"object no longer exist"end end,get=function()if u
then l("returned "..w.." > "..u.name,l.info)return u else return
false,"object no longer exist"end
end,clear=function()l("Removed copied object "..w.." > "..u.name,l.info)u=nil
end,}else l("tried to manipulate dead object.",l.error)return
false,"object no longer exist"end end L.cut=function()if d[w][u.name]then local
u=a(d[w][u.name])d[w][u.name]=nil
l("cut "..w.." > "..u.name,l.info)return{parse=function()if u then
l("parsed "..w.." > "..u.name,l.info)if d[w][u.name]then d[w][u.name]=nil end
d[w][u.name]=u return d[w][u.name]else return false,"object no longer exist"end
end,get=function()l("returned "..w.." > "..u.name,l.info)return u
end,clear=function()l("Removed copied object "..w.." > "..u.name,l.info)u=nil
end}else l("tried to manipulate dead object.",l.error)return
false,"object no longer exist"end end L.destroy=L.kill L.murder=L.destroy
L.copy=L.isolate if not type(L.logic)=="function"then
l("object "..w.." has invalid logic.lua",l.error)return false end if not
type(L.graphic)=="function"then
l("object "..w.." has invalid graphic.lua",l.error)return false end
setmetatable(u,{__index=L,__tostring=function()return"GuiH.element."..w.."."..u.name
end})if u.positioning then
setmetatable(u.positioning,{__tostring=function()return"GuiH.element.position"end})end
u.canvas=r l("created new "..w.." > "..u.name,l.info)l:dump()return u end})else
if not v and g then l(w.." is missing an logic file !",l.error)end if not g and
v then l(w.." is missing an graphic file !",l.error)end if not v and not g then
l(w.." is missing logic and graphic file !",l.error)end if v
and(type(b)~="function")then l(w.." has an invalid logic file !",l.error)end if
g and(type(k)~="function")then
l(w.." has an invalid graphic file !",l.error)end if g and v
and(type(k)~="function")and(type(b)~="function")then
l(w.." has an invalid logic and graphic file !",l.error)end end else if y and
not(type(p)=="function")then l(w.." has invalid object file!",l.error)else
l(w.." is missing an object file !",l.error)end end end return c
end,types=fs.list(fs.combine(t,"objects"))}