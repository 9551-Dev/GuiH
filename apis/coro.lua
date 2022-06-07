local e=require("cc.expect").expect local function t(a)local o={}for i,n in
pairs(a)do table.insert(o,i)end return o end local function s(h)local r=0 local
d=t(h)table.sort(d,function(l,u)return l<u end)return function()r=r+1 if
h[d[r]]then return d[r],h[d[r]]else return end end end local function
c(...)local m local f={coros={},id_names={},running=true,filters={}}local w=0
local function y(p)return
setmetatable({},{__index={coro=coroutine.create(function()local v,b=pcall(p)if
not v then m=b end end)}})end for g,k in ipairs({...})do if
type(k)=="function"then w=w+1 local q=y(k)f.id_names[w]=1 if not f.coros[1]then
f.coros[1]={}end
f.coros[1][w]=setmetatable({},{__index={coro=q.coro,kill=function()f.coros[1][w]=nil
f.id_names[w]=nil end}})end end local function j()local x=0 for z,E in
pairs(f.id_names)do if coroutine.status(f.coros[E][z].coro)~="dead"then x=x+1
end end return x end local T={create=function(A,O,I)local I=I or 1
e(1,A,"function")e(2,O,"string","nil")e(3,I,"number")w=w+1 f.id_names[O or w]=I
if not f.coros[I]then f.coros[I]={}end f.coros[I][O or w]=y(A)return
setmetatable(f.coros[I][O or w],{__index={kill=function()f.coros[I][O or w]=nil
f.id_names[O or w]=nil end,coro=f.coros[I][O or
w].coro},})end,kill=function(N)e(2,N,"string")f.coros[f.id_names[N]][N]=nil
f.id_names[N]=nil end,get=function(S)e(2,S,"string")if not f.id_names[S]then
return"coroutine no longer exists."end return
f.coros[f.id_names[S]][S]end,living=j,stop=function()f.running=false
end,kill_all=function()f.running=false
f.coros={}f.id_names={}end,run=function()f.running=true while f.running do
local H=table.pack(os.pullEventRaw())if m then error(m,0)end if
H[1]=="terminate"then error("Terminated",0)end for R,D in s(f.coros)do for L,U
in pairs(D)do if coroutine.status(U.coro)=="dead"then f.coros[R][L]=nil
f.id_names[L]=nil else if f.filters[U.coro]==nil or f.filters[U.coro]==H[1]then
local C,M=coroutine.resume(U.coro,table.unpack(H,1,H.n))f.filters[U.coro]=M end
end end end if j()<1 then return true end end end}return
setmetatable(f,{__index=T})end
return{create=c}