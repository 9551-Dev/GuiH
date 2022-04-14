local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            if orig_key == "canvas" then
                copy.canvas = orig_value
            else
                copy[deepcopy(orig_key)] = deepcopy(orig_value)
            end
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

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
                graphic=require("GuiH.objects."..v..".graphic"),
                kill=function()
                    if guis[v][object.name] then
                        guis[v][object.name] = nil
                        return true
                    else
                        return false,"object no longer exist"
                    end
                end,
                get_position=function()
                    if guis[v][object.name] then
                        if object.positioning then
                            return object.positioning
                        else
                            return false,"object doesnt have positioning information"
                        end
                    else
                        return false,"object no longer exist"
                    end
                end,
                replicate=function(name)
                    if guis[v][object.name] then
                        if name == object.name then
                            return "name of copy cannot be the same!"
                        else
                            local temp = deepcopy(guis[v][object.name])
                            guis[v][name] = temp
                            return temp,true
                        end
                    else
                        return false,"object no longer exist"
                    end
                end,
                isolate=function()
                    if guis[v][object.name] then
                        local object = deepcopy(guis[v][object.name])
                        return {
                            parse=function(name)
                                if object then
                                    local name = name or object.name
                                    if guis[v][name] then guis[v][name] = nil end
                                    guis[v][name] = object
                                    return guis[v][name]
                                else
                                    return false,"object no longer exist"
                                end
                            end,
                            get=function()
                                if object then
                                    return object
                                else
                                    return false,"object no longer exist"
                                end
                            end,
                            clear=function()
                                object = nil
                            end,
                        }
                    else
                        return false,"object no longer exist"
                    end
                end,
                cut=function()
                    if guis[v][object.name] then
                        local object = deepcopy(guis[v][object.name])
                        guis[v][object.name] = nil
                        return {
                            parse=function()
                                if object then
                                    if guis[v][object.name] then guis[v][object.name] = nil end
                                    guis[v][object.name] = object
                                    return guis[v][object.name]
                                else
                                    return false,"object no longer exist"
                                end
                            end,
                            get=function()
                                return object
                            end,
                            clear=function()
                                object = nil
                            end
                        }
                    else
                        return false,"object no longer exist"
                    end
                end
            }
            index.destroy = index.kill
            index.murder = index.destroy
            if not type(index.logic) == "function" then error("object "..v.." has invalid logic.lua") end
            if not type(index.graphic) == "function" then error("object "..v.." has invalid graphic.lua") end
            setmetatable(object,{__index = index})
            object.canvas = i_self
            return object
        end
    end
    return objects
end,types=fs.list("GuiH/objects")}