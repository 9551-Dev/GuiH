local e=require("graphic_handle").code local function t(a)return
a:gsub("[%[%]%(%)%.%+%-%%%$%^%*%?]","%%%1")end return function(o)local
i=o.canvas.term_object local n,s=o.input,0 if#o.input>=o.positioning.width-1
then
n=o.input:sub(#o.input-o.positioning.width+1-o.shift,#o.input-o.shift)s=#o.input-#n
end local h=(o.positioning.x+o.cursor_pos)-s
i.setCursorPos(o.positioning.x,o.positioning.y)local r=n
n=n:gsub(" ",o.space_symbol)..o.background_symbol:rep(o.positioning.width-#n+1)local
d if o.replace_char then
d=o.replace_char:rep(#r)..o.background_symbol:rep(o.positioning.width-#r+1)end
i.blit(d or
n,e.to_blit[o.text_color]:rep(#n),e.to_blit[o.background_color]:rep(#n))if
o.selected and(o.char_limit>o.cursor_pos)then
i.setCursorPos(math.max(h+o.shift,o.positioning.x),o.positioning.y)if
h+o.shift<o.positioning.x then o.shift=o.shift+1 end if
h+o.shift>o.positioning.x+o.positioning.width then o.shift=o.shift-1 end local
l if o.cursor_pos<o.positioning.width then
l=o.input:sub(o.cursor_pos+1,o.cursor_pos+1)o.cursor_x=o.cursor_pos+1 else
l=o.input:sub(o.cursor_pos+1,o.cursor_pos+1)i.setCursorPos(h+o.shift,o.positioning.y)end
o.cursor_x=h+o.shift i.blit((l)~=""and(o.replace_char or l)or"_",l~=""and
e.to_blit[o.background_color]or e.to_blit[o.text_color],l~=""and
e.to_blit[o.text_color]or e.to_blit[o.background_color])else
i.setCursorPos(o.positioning.x+o.positioning.width,o.positioning.y)i.blit("\127",e.to_blit[o.text_color],e.to_blit[o.background_color])end
if o.autoc.str_diff then
i.setCursorPos(o.cursor_x+o.shift,o.positioning.y)local
u=o.autoc.sorted[o.autoc.selected]if u then local
c=o.input:match("%S+$")or""local m=u:gsub("^"..c:gsub(" $",""),"")if
o.cursor_pos>=#o.input then local m=m:gsub("%%(.)","%1")local
f=o.positioning.x+o.positioning.width+1 local w=o.cursor_x+o.shift+#m if w>f
and not o.autoc.ignore_width then local y=w-f m=m:sub(1,#m-y)end
i.blit(m,e.to_blit[o.autoc.fg]:rep(#m),e.to_blit[o.autoc.bg]:rep(#m))end end
end
end