return {main=function(i_self,guis)
    local object = i_self
    local objects = {}
    local object_list = fs.list("GuiH/objects")
    for k,v in pairs(object_list) do
        local main = require("GuiH.objects."..v..".object")
        objects[v] = function(data)
            local object = main(object,data)
            guis[v][object.name] = object
            local index = {
                logic=require("GuiH.objects."..v..".logic"),
                graphic=require("GuiH.objects."..v..".graphic")
            }
            if not type(index.logic) == "function" then error("object "..v.." has invalid logic.lua") end
            if not type(index.graphic) == "function" then error("object "..v.." has invalid graphic.lua") end
            setmetatable(object,{__index = index})
            object.canvas = i_self
            return object
        end
    end
    return objects
end,types=fs.list("GuiH/objects")}