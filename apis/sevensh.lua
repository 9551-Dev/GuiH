local
e={normal={1021,1007,1021,881,2,925,893,894,1021,325,2,1017,877,879,1021,size=3,conversion={}}}if
not fs.exists("GuiH/apis/fonts.7sh")then fs.makeDir("GuiH/apis/fonts.7sh")end
for t,a in pairs(fs.list("GuiH/apis/fonts.7sh"))do local
o=dofile("GuiH/apis/fonts.7sh/"..a)if next(o or{})then for t,i in pairs(o)do
e[a.."."..t]=i end end end local n={}function n:update()local
s,h=self.term.getBackgroundColor(),self.term.getTextColor()for r,d in
ipairs(e[self.font])do local l=self.value local
u=bit32.band(bit32.rshift(d,(e[self.font].conversion or{})[l]or
l),1)self.term.setCursorPos(((r-1)%e[self.font].size)+1+self.pos.x,math.ceil(r/e[self.font].size)+self.pos.y)if
u==1 then
self.term.setBackgroundColor(self.bg)self.term.setTextColor(self.tg)self.term.write(self.symbol)else
self.term.setBackgroundColor(s)self.term.setTextColor(h)self.term.write(" ")end
end self.term.setTextColor(h)self.term.setBackgroundColor(s)end function
n:reposition(c,m)self.pos=vector.new(c or 0,m or 0)end function
n:set_background(f)self.bg=f or colors.white end function
n:set_color(w)self.tg=w or colors.black end function
n:set_symbol(y)self.symbol=y or" "end function n:set_value(p)self.value=p or 0
end function n:set_font(v)if e[v or"normal"]then self.font=v or"normal"end end
function n:set_term(b)if type(b)=="table"then self.term=b end end local
function g(k,q,j,x,z,E,T,A)if type(k)~="table"then
error("create_display needs an term object as its argument input to work!",2)end
return setmetatable({pos=vector.new(q,j),value=x or 0,symbol=T or" ",bg=E or
colors.white,tg=A or colors.black,font=z or"normal",term=k},{__index=n})end
return{create_display=g}