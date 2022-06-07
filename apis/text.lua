local e=require("cc.expect").expect local function
t(a,o,i)e(1,a,"string")e(2,o,"number")local n,s,h={},{},""for r in
a:gmatch("[%w%p%a%d]+%s?")do table.insert(n,r)end if o==0 then return""end
while h<a and not(#n==0)do local d=""while n~=0 do local l=n[1]if not l then
break end if#l>o then local u=l:match("% +$")or""if not((#l-#u)<=o)then local
c,m=l:sub(1,o),l:sub(o+1)if#(d..c)>o then n[1]=t(c..m,o,true)break end
d,n[1],l=d..c,m,m else l=l:sub(1,#l-(#l-o))end end if#(d..l)<=o then d=d..l
table.remove(n,1)else break end end table.insert(s,d)end return
table.concat(s,i and""or"\n")end local function
f(w,y)e(1,w,"string")e(2,y,"number")local p={}local v=""for b in
w:gmatch(".")do if#v+#b<=y then v=v..b else table.insert(p,v)v=b end end
table.insert(p,v)return p end local function
g(k,q)e(1,k,"string")e(2,q,"number")local j=k:sub(1,q)if#j<q then
j=j..(" "):rep(q-#j)end return j end local function x(z)e(1,z,"table")return
table.concat(z,"\n")end
return{wrap=t,cut_parts=f,ensure_size=g}