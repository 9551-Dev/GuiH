local e=require("a-tools.algo")local t=require("graphic_handle").code return
function(a)local o=a.canvas.term_object local i={}local n={}if a.filled then
local
s=e.get_triangle_points(a.positioning.p1,a.positioning.p2,a.positioning.p3)for
h,r in ipairs(s)do i[r.y]=(i[r.y]or"").."*"n[r.y]=math.min(n[r.y]or
math.huge,r.x)end for d,l in pairs(i)do
o.setCursorPos(n[d],d)o.blit(l:gsub("%*",a.symbol),l:gsub("%*",t.to_blit[a.fg]),l:gsub("%*",t.to_blit[a.bg]))end
else local
u=e.get_triangle_outline_points(a.positioning.p1,a.positioning.p2,a.positioning.p3)for
c,m in pairs(u)do
o.setCursorPos(m.x,m.y)o.blit(a.symbol,t.to_blit[a.fg],t.to_blit[a.bg])end end
end