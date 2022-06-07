local e=require("a-tools.algo")local t=require("graphic_handle").code local
a=require("api")return function(o)local i=o.canvas.term_object local n={}local
s={}local h=a.tables.createNDarray(2)if o.filled then local
r=e.get_elipse_points(o.positioning.radius,math.ceil(o.positioning.radius-o.positioning.radius/3)+0.5,o.positioning.x,o.positioning.y,true)for
d,l in ipairs(r)do if h[l.x][l.y]~=true then
n[l.y]=(n[l.y]or"").."*"s[l.y]=math.min(s[l.y]or math.huge,l.x)h[l.x][l.y]=true
end end for u,c in pairs(n)do
i.setCursorPos(s[u],u)i.blit(c:gsub("%*",o.symbol),c:gsub("%*",t.to_blit[o.fg]),c:gsub("%*",t.to_blit[o.bg]))end
else local
m=e.get_elipse_points(o.positioning.radius,math.ceil(o.positioning.radius-o.positioning.radius/3)+0.5,o.positioning.x,o.positioning.y)for
f,w in pairs(m)do
i.setCursorPos(w.x,w.y)i.blit(o.symbol,t.to_blit[o.fg],t.to_blit[o.bg])end end
end