local function e(t,...)local a={...}local o={}for i,n in pairs(a[1])do
o[i]=function(...)local s=table.pack(t[i](...))for h,r in pairs(a)do
s=table.pack(r[i](...))end return table.unpack(s,1,s.n or 1)end end return o
end local function d(...)local l={...}local u={}for c,m in pairs(l[1])do
u[c]=function(...)local f={}for w,y in pairs(l)do f=table.pack(y[c](...))end
return table.unpack(f,1,f.n or 1)end end return u end
return{mirror_monitors=e,make_shared_terminal=d}