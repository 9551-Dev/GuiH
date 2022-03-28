fs.makeDir("GuiH")
fs.makeDir("GuiH/a-tools")
fs.makeDir("GuiH/objects")

local ls = {
    ["https://github.com/9551-Dev/Gui-h/raw/main/api.lua"]="api.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/main.lua"]="main.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/object-loader.lua"]="object-loader.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/texture-wrapper.lua"]="texture-wrapper.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/a-tools/gui_object.lua"]="a-tools/gui-object.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/a-tools/update.lua"]="a-tools/update.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/button/graphic.lua"]="objects/button/graphic.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/button/object.lua"]="objects/button/object.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/button/logic.lua"]="objects/button/logic.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/frame/graphic.lua"]="objects/frame/graphic.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/frame/object.lua"]="objects/frame/object.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/frame/logic.lua"]="objects/frame/logic.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/switch/graphic.lua"]="objects/switch/graphic.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/switch/object.lua"]="objects/switch/object.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/switch/logic.lua"]="objects/switch/logic.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/progressbar/graphic.lua"]="objects/progressbar/graphic.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/progressbar/object.lua"]="objects/progressbar/object.lua",
    ["https://github.com/9551-Dev/Gui-h/raw/main/objects/progressbar/logic.lua"]="objects/progressbar/logic.lua",
}

local len = 0
for k,v in pairs(ls) do
    len = len + 1
end

local percent = 100/len
local finished = 0
for k,v in pairs(ls) do
    local web = http.get(k)
    local file = fs.open("./GuiH/"..v,"w")
    file.write(web.readAll())
    file.close()
    web.close()
    finished = finished + 1
    print("downloading "..v.."  "..tostring(math.ceil(finished*percent)).."%")
end
print("Finished downloading GuiH")