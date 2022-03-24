return {main=function(object)
    local objects = {}
    local object_list = fs.list("GuiH/GuiH/objects")
    for k,v in pairs(object_list) do
        local main = require("GuiH.objects."..v..".object")
        objects[v] = function(data)
            return main(object,data)
        end
    end
    return objects
end,types=fs.list("GuiH/GuiH/objects")}