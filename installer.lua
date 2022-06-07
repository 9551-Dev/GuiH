fs.makeDir("GuiH")fs.makeDir("GuiH/a-tools")fs.makeDir("GuiH/objects")fs.makeDir("GuiH/apis/")fs.makeDir("GuiH/apis/fonts.7sh")fs.makeDir("GuiH/presets")fs.makeDir("GuiH/presets/rect")fs.makeDir("GuiH/presets/tex")local
e=http.get("https://api.github.com/repos/9551-Dev/GuiH/git/trees/minified?recursive=1",_G._GIT_API_KEY
and{Authorization='token '.._G._GIT_API_KEY})local
t=textutils.unserialiseJSON(e.readAll())local a={}local o=0 e.close()for i,n in
pairs(t.tree)do if n.type=="blob"and n.path:lower():match(".+%.lua")then
a["https://raw.githubusercontent.com/9551-Dev/GuiH/minified/"..n.path]=n.path o=o+1
end end local s=100/o local h=0 local r=0 local d={}for l,u in pairs(a)do
table.insert(d,function()local c=http.get(l)local
m=fs.open("./GuiH/"..u,"w")m.write(c.readAll())m.close()c.close()h=h+1 local
f=fs.getSize("./GuiH/"..u)r=r+f
print("downloading "..u.."  "..tostring(math.ceil(h*s)).."% "..tostring(math.ceil(f/1024*10)/10).."kB total: "..math.ceil(r/1024).."kB")end)end
parallel.waitForAll(table.unpack(d))print("Finished downloading GuiH")