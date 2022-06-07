if config then if config.get("standardsMode")==false then
print("WARNING: standardsMode is set to false, this is not supported by the GuiH API")print("Enter Y to enable standards mode, this will reboot the computer")local
e=read()if e:lower():match("y")then
config.set("standardsMode",true)os.reboot()else
error("GuiH cannot run without standards mode",0)end end end local
t=fs.getDir(select(2,...))or""local a=package.path
package.path=string.format("%s;/%s/?.lua;/%s/?/init.lua",package.path,t,t)local
o=require"main"package.path=a return
setmetatable(o,{__tostring=function()return"GuiH.API"end})