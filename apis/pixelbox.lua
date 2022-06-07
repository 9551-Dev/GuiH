local e=require("graphic_handle")local t=require("api")local
a=require("cc.expect").expect local o=require("a-tools.algo")local i={}local
n={}function i.INDEX_SYMBOL_CORDINATION(s,h,r,d)s[h+r*2-2]=d return s end
function n:within(l,u)return l>0 and u>0 and l<=self.width*2 and
u<=self.height*3 end function
n:push_updates()i.ASSERT(type(self)=="table","Please use \":\" when running this function")self.symbols=t.tables.createNDarray(2)self.lines=t.create_blit_array(self.height)getmetatable(self.symbols).__tostring=function()return"PixelBOX.SYMBOL_BUFFER"end
setmetatable(self.lines,{__tostring=function()return"PixelBOX.LINE_BUFFER"end})for
c,m in pairs(self.CANVAS)do for f,w in pairs(m)do local y=math.ceil(f/2)local
p=math.ceil(c/3)local v=(f-1)%2+1 local b=(c-1)%3+1
self.symbols[p][y]=i.INDEX_SYMBOL_CORDINATION(self.symbols[p][y],v,b,w)end end
for g,k in pairs(self.symbols)do for q,j in ipairs(k)do local
x,z,E=e.code.build_drawing_char(j)self.lines[g]={self.lines[g][1]..x,self.lines[g][2]..e.code.to_blit[z],self.lines[g][3]..e.code.to_blit[E]}end
end end function
n:get_pixel(T,A)i.ASSERT(type(self)=="table","Please use \":\" when running this function")a(1,T,"number")a(2,A,"number")assert(self.CANVAS[A]and
self.CANVAS[A][T],"Out of range")return self.CANVAS[A][T]end function
n:clear(O)i.ASSERT(type(self)=="table","Please use \":\" when running this function")a(1,O,"number")self.CANVAS=t.tables.createNDarray(2)for
I=1,self.height*3 do for N=1,self.width*2 do self.CANVAS[I][N]=O end end
getmetatable(self.CANVAS).__tostring=function()return"PixelBOX_SCREEN_BUFFER"end
end function
n:draw()i.ASSERT(type(self)=="table","Please use \":\" when running this function")if
not self.lines then error("You must push_updates in order to draw",2)end for
S,H in ipairs(self.lines)do
self.term.setCursorPos(1,S)self.term.blit(table.unpack(H))end end function
n:set_pixel(R,D,L,U)i.ASSERT(type(self)=="table","Please use \":\" when running this function")a(1,R,"number")a(2,D,"number")a(3,L,"number")i.ASSERT(R>0
and R<=self.width*2,"Out of range")i.ASSERT(D>0 and
D<=self.height*3,"Out of range")U=U or 1 local C=(U-1)/2
self:set_box(math.ceil(R-C),math.ceil(D-C),R+U-1,D+U-1,L,true)end function
n:set_box(M,F,W,Y,P,V)if not V then
i.ASSERT(type(self)=="table","Please use \":\" when running this function")a(1,M,"number")a(2,F,"number")a(3,W,"number")a(4,Y,"number")a(5,P,"number")end
for B=F,Y do for G=M,W do if self:within(G,B)then self.CANVAS[B][G]=P end end
end end function n:set_ellipse(K,Q,J,X,Z,et,tt,at)if not at then
i.ASSERT(type(self)=="table","Please use \":\" when running this function")a(1,K,"number")a(2,Q,"number")a(3,J,"number")a(4,X,"number")a(5,Z,"number")a(6,et,"boolean","nil")end
tt=tt or 1 local ot=(tt-1)/2 if type(et)~="boolean"then et=true end local
it=o.get_elipse_points(J,X,K,Q,et)for nt,st in ipairs(it)do if
self:within(st.x,st.y)then
self:set_box(math.ceil(st.x-ot),math.ceil(st.y-ot),st.x+tt-1,st.y+tt-1,Z,true)end
end end function
n:set_circle(ht,rt,dt,lt,ut,ct)i.ASSERT(type(self)=="table","Please use \":\" when running this function")a(1,ht,"number")a(2,rt,"number")a(3,dt,"number")a(4,lt,"number")a(5,ut,"boolean","nil")self:set_ellipse(ht,rt,dt,dt,lt,ut,ct,true)end
function
n:set_triangle(mt,ft,wt,yt,pt,vt,bt,gt,kt)i.ASSERT(type(self)=="table","Please use \":\" when running this function")a(1,mt,"number")a(2,ft,"number")a(3,wt,"number")a(4,yt,"number")a(5,pt,"number")a(6,vt,"number")a(7,bt,"number")a(8,gt,"boolean","nil")kt=kt
or 1 local qt=(kt-1)/2 if type(gt)~="boolean"then gt=true end local jt if gt
then
jt=o.get_triangle_points(vector.new(mt,ft),vector.new(wt,yt),vector.new(pt,vt))else
jt=o.get_triangle_outline_points(vector.new(mt,ft),vector.new(wt,yt),vector.new(pt,vt))end
for xt,zt in ipairs(jt)do if self:within(zt.x,zt.y)then
self:set_box(math.ceil(zt.x-qt),math.ceil(zt.y-qt),zt.x+kt-1,zt.y+kt-1,bt,true)end
end end function
n:set_line(Et,Tt,At,Ot,It,Nt)i.ASSERT(type(self)=="table","Please use \":\" when running this function")a(1,Et,"number")a(2,Tt,"number")a(3,At,"number")a(4,Ot,"number")a(5,It,"number")Nt=Nt
or 1 local St=(Nt-1)/2 local Ht=o.get_line_points(Et,Tt,At,Ot)for Rt,Dt in
ipairs(Ht)do if self:within(Dt.x,Dt.y)then
self:set_box(math.ceil(Dt.x-St),math.ceil(Dt.y-St),Dt.x+Nt-1,Dt.y+Nt-1,It,true)end
end end function i.ASSERT(Lt,Ut)if not Lt then error(Ut,3)end return Lt end
function
i.new(Ct,Mt,Ft)a(1,Ct,"table")a(2,Mt,"number","nil")a(3,Ft,"table","nil")local
Mt=Mt or Ct.getBackgroundColor()or colors.black local Wt={}local
Yt,Pt=Ct.getSize()Wt.term=setmetatable(Ct,{__tostring=function()return"term_object"end})Wt.CANVAS=t.tables.createNDarray(2,Ft)getmetatable(Wt.CANVAS).__tostring=function()return"PixelBOX_SCREEN_BUFFER"end
Wt.width=Yt Wt.height=Pt for Vt=1,Pt*3 do for Bt=1,Yt*2 do Wt.CANVAS[Vt][Bt]=Mt
end end return setmetatable(Wt,{__index=n})end return
i