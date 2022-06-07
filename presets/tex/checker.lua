local e=require("api")local t=require("graphic_handle")return
function(...)local a=e.tables.createNDarray(2,{offset={5,13,11,4}})local
o={...}local i=1 for n,s in pairs(o)do local h={}for r=1,table.getn(o)do local
d=((r+i)-2)%table.getn(o)+1 h[r]=o[d]end for n,s in pairs(h)do
a[n+4][i+8]={s=" ",t="f",b=t.code.to_blit[s]}end i=i+1 end return
t.load_texture(a)end