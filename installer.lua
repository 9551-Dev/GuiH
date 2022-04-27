fs.makeDir("GuiH")
fs.makeDir("GuiH/a-tools")
fs.makeDir("GuiH/objects")
fs.makeDir("GuiH/apis/")
fs.makeDir("GuiH/apis/fonts.7sh")
fs.makeDir("GuiH/presets")
fs.makeDir("GuiH/presets/rect")
fs.makeDir("GuiH/presets/tex")

local github_api = http.get("https://api.github.com/repos/9551-Dev/Gui-h/git/trees/main?recursive=1")
local list = textutils.unserialiseJSON(github_api.readAll())
local ls = {}
local len = 0
github_api.close()
for k,v in pairs(list.tree) do
    if v.type == "blob" and v.path:lower():match(".+%.lua") then
        ls["https://raw.githubusercontent.com/9551-Dev/Gui-h/main/"..v.path] = v.path
        len = len + 1
    end
end
local percent = 100/len
local finished = 0
local size_gained = 0
for k,v in pairs(ls) do
    local web = http.get(k)
    local file = fs.open("./GuiH/"..v,"w")
    file.write(web.readAll())
    file.close()
    web.close()
    finished = finished + 1
    local file_size = fs.getSize("./GuiH/"..v)
    size_gained = size_gained + file_size
    print("downloading "..v.."  "..tostring(math.ceil(finished*percent)).."% "..tostring(math.ceil(file_size/1024*10)/10).."kB total: "..math.ceil(size_gained/1024).."kB")
end
print("Finished downloading GuiH")
