fs.makeDir("GuiH")
local github_api = http.get(
	"https://api.github.com/repos/9551-Dev/GuiH/git/trees/main?recursive=1",
	_G._GIT_API_KEY and {Authorization = 'token ' .. _G._GIT_API_KEY}
)

local list = textutils.unserialiseJSON(github_api.readAll())
local ls = {}
local len = 0
github_api.close()
for k,v in pairs(list.tree) do
    if v.type == "blob" and v.path:lower():match(".+%.lua") then
        ls["https://raw.githubusercontent.com/9551-Dev/GuiH/main/"..v.path] = v.path
        len = len + 1
    end
end
local percent = 100/len
local finished = 0
local size_gained = 0
local downloads = {}
for k,v in pairs(ls) do
    table.insert(downloads,function()
        local web = http.get(k)
        local file = fs.open("./GuiH/"..v,"w")
        file.write(web.readAll())
        file.close()
        web.close()
        finished = finished + 1
        local file_size = fs.getSize("./GuiH/"..v)
        size_gained = size_gained + file_size
        print("downloading "..v.."  "..tostring(math.ceil(finished*percent)).."% "..tostring(math.ceil(file_size/1024*10)/10).."kB total: "..math.ceil(size_gained/1024).."kB")
    end)
end
parallel.waitForAll(table.unpack(downloads))
print("Finished downloading GuiH")
