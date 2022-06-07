local e=require("a-tools.logger")local t=fs.getDir(select(2,...))local
a=e.create_log()local
o={algo=require("a-tools.algo"),luappm=require("a-tools.luappm"),blbfor=require("a-tools.blbfor"),graphic=require("graphic_handle").code,general=require("api")}local
i={}a("loading apis..",a.update)for n,s in pairs(fs.list(t.."/apis"))do local
h=s:match("[^.]+")if not fs.isDir(t.."/apis/"..s)then
o[h]=require("apis."..h)a("loaded api: "..h)end end
a("")a("loading presets..",a.update)for r,d in pairs(fs.list(t.."/presets"))do
for l,u in pairs(fs.list(t.."/presets/"..d))do if not i[d]then i[d]={}end local
c=u:match("[^.]+")i[d][c]=require("presets."..d.."."..c)a("loaded preset: "..d.." > "..c)end
end a("")a("finished loading",a.success)a("")a:dump()local function
m(f,w,y)local p=package.path
package.path=string.format("%s;/%s/?.lua;/%s/?/init.lua",package.path,t,t)local
v=require("a-tools.gui_object")local
b=window.create(f,1,1,f.getSize())a("creating gui object..",a.update)local
g=v(b,f,a,w,y)a("finished creating gui object!",a.success)a("",a.info)a:dump()package.path=p
local
k=getmetatable(g)or{}k.__tostring=function()return"GuiH.MAIN_UI."..tostring(g.id)end
g.api=o g.preset=i return setmetatable(g,k)end
return{create_gui=m,new=m,load_texture=require("graphic_handle").load_texture,convert_event=function(q,j,x,z,E)local
T={}if q=="monitor_touch"then T={name=q,monitor=j,x=x,y=z}end if
q=="mouse_click"or q=="mouse_up"then T={name=q,button=j,x=x,y=z}end if
q=="mouse_drag"then T={name=q,button=j,x=x,y=z}end if q=="mouse_scroll"then
T={name=q,direction=j,x=x,y=z}end if q=="key"then
T={name=q,key=j,held=x,x=math.huge,y=math.huge}end if q=="key_up"then
T={name=q,key=j,x=math.huge,y=math.huge}end if q=="char"then
T={name=q,character=j,x=math.huge,y=math.huge}end if q=="guih_data_event"then
T=j end if not T.monitor then T.monitor="term_object"end return T
or{name=q}end,apis=o,presets=i,valid_events={["mouse_click"]=true,["mouse_drag"]=true,["monitor_touch"]=true,["mouse_scroll"]=true,["mouse_up"]=true,["key"]=true,["key_up"]=true,["char"]=true,["guih_data_event"]=true},log=a}