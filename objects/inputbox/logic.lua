local e=require("api")local function t(a)return
a:gsub("[%[%]%(%)%.%+%-%%%$%^%*%?]","%%%1")end local function o(i,n,s)local o=0
local h=string.len(i)local r=string.len(n)local d=math.min(h,r)if i==n then
return 0 end if h==0 and s then return 0.4 end for l=1,d do if
i:sub(l,l)==n:sub(l,l)then o=o+1 end end return o end local function u(c)local
m={}for f,w in pairs(c)do m[#m+1]={key=f,value=w}end return m end local
function y(p,v)local b={}local g={}local k=v.show_default local q={}for j,x in
ipairs(v)do local o=o(p,x,k)if o>0 and type(j)=="number"then if b[o]then
table.insert(b[o],x)else b[o]={x}end else table.insert(q,x)end end local
z=u(b)table.sort(z,function(E,T)return E.key>T.key end)for A,O in ipairs(z)do
for I,N in ipairs(O.value)do table.insert(g,N)end end local S=table.getn(g)for
H,R in pairs(q)do g[1+S+H]=R end return g end return function(D,L)local
U=D.canvas.term_object if L.name=="mouse_click" or L.name=="monitor_touch" then if
e.is_within_field(L.x,L.y,D.positioning.x,D.positioning.y,D.positioning.width+1,1)then
if D.selected then
D.cursor_pos=math.min(D.cursor_pos+(L.x-D.cursor_x),#D.input)else
D.cursor_pos=D.old_cursor or 0 D.on_change_select(D,L,true)end D.selected=true
else if D.selected then D.on_change_select(D,L,false)D.old_cursor=D.cursor_pos
D.cursor_pos=-math.huge end D.selected=false end end local
C=D.input:sub(1,D.cursor_pos)local M=D.input:sub(D.cursor_pos+1,#D.input)if
next(D.autoc.strings)or next(D.autoc.spec_strings)and D.selected then local
F=t(C):match("%S+$")or""local F=F:gsub("%%(.)","%1")local
W=D.autoc.spec_strings[select(2,C:gsub("%W+",""))+1]or D.autoc.strings if W
then local Y=y(F,W)D.autoc.sorted=Y if D.autoc.selected>#Y then
D.autoc.selected=#Y end if Y[1]~=F then D.autoc.current=F
D.autoc.str_diff=D.autoc.sorted[D.autoc.selected]if not D.autoc.str_diff then
D.autoc.str_diff=""end D.autoc.current_likeness=o(F,D.autoc.str_diff)end end
end if L.name=="char"and D.selected and L.character:match(D.pattern)then
if#D.input<D.char_limit then if not D.insert then D.input=C..L.character..M
D.cursor_pos=D.cursor_pos+1 else
D.input=C..L.character..M:gsub("^.","")D.cursor_pos=D.cursor_pos+1 end
D.autoc.selected=1 D.on_change_input(D,L,D.input)end end if L.name=="key_up"and
D.selected then if L.key==keys.leftCtrl or L.key==keys.rightCtrl then
D.ctrl=false end end if L.name=="key"and D.selected then if
L.key==keys.leftCtrl or L.key==keys.rightCtrl then D.ctrl=true elseif
L.key==keys.backspace then D.input=C:gsub(".$","")..M D.autoc.selected=1
D.cursor_pos=math.max(D.cursor_pos-1,0)D.on_change_input(D,L,D.input)elseif
L.key==keys.left then if not D.ctrl then
D.cursor_pos=math.max(D.cursor_pos-1,0)else local
P=C:reverse():find(" ")D.cursor_pos=P and#C-P or 0 end elseif L.key==keys.right
then if not D.ctrl then
D.cursor_pos=math.min(math.max(D.cursor_pos+1,0),#D.input)else local
V=M:sub(2,#M):find(" ")D.cursor_pos=V and V+#C or#D.input end elseif
L.key==keys.tab and not D.ignore_tab and not L.held and(next(D.autoc.strings)or
next(D.autoc.spec_strings)and D.selected)then local
B=#D.autoc.str_diff-#D.autoc.current local
G=D.input:gsub(D.autoc.current.."$",D.autoc.str_diff)if#G<=D.char_limit and
D.cursor_pos>=#D.input then if D.autoc.put_space then
D.input=G.." "D.cursor_pos=D.cursor_pos+B+1 else D.input=G
D.cursor_pos=D.cursor_pos+B end
D.autoc.sorted={}D.autoc.str_diff=""D.on_change_input(D,L,D.input)end elseif
L.key==keys.home then D.cursor_pos=0 elseif L.key==keys["end"]then
D.cursor_pos=#D.input elseif L.key==keys.delete then
D.input=C..M:gsub("^.","")D.autoc.selected=1
D.on_change_input(D,L,D.input)elseif L.key==keys.insert and not L.held then
D.insert=not D.insert elseif L.key==keys.down then if
D.autoc.selected+1<=#D.autoc.sorted then D.autoc.selected=D.autoc.selected+1
end elseif L.key==keys.up then if D.autoc.selected>1 then
D.autoc.selected=D.autoc.selected-1 end elseif L.key==keys.enter and D.selected
then local
K={}D.input:gsub("%S+",function(Q)table.insert(K,Q)end)D.on_enter(D,L,K)end end
if L.name=="paste"then D.autoc.selected=1 D.input=C..L.text..M
D.cursor_pos=D.cursor_pos+#L.text D.on_change_input(D,L,D.input)end
end
