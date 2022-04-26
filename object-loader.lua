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

return {main=function(i_self,guis,log)
    local object = i_self
    local objects = {}
    local object_list = fs.list("GuiH/objects")
    for k,v in pairs(object_list) do
        log("loading object: "..v,log.update)
        local zok,main = pcall(require,"GuiH.objects."..v..".object")
        if zok and type(main) == "function" then
            local aok,adat = pcall(require,"GuiH.objects."..v..".logic")
            local bok,bdat = pcall(require,"GuiH.objects."..v..".graphic")
            if aok and bok and (type(adat) == "function") and (type(bdat) == "function") then
                local c_file_names = fs.list("GuiH/objects/"..v)
                local custom_flags = {}
                for _k,_v in pairs(c_file_names) do
                    local name = _v:match("(.*)%.")
                    if not (name == "logic" or name == "graphic" or name == "object") then
                        local ok,err = pcall(require,"GuiH.objects."..v.."."..name)
                        if ok then
                            log("found custom object flag \""..name .. "\" for: " .. v,log.update)
                            custom_flags[name] = require("GuiH.objects."..v.."."..name) 
                        else
                            log("bad object flag "..err)
                        end
                    end
                end
                objects[v] = setmetatable({},{
                __index=custom_flags,
                __call=function(_,data)
                    local object = main(object,data)
                    guis[v][object.name] = object
                    local index = {
                        logic=adat,
                        graphic=bdat,
                        kill=function()
                            if guis[v][object.name] then
                                guis[v][object.name] = nil
                                log("killed "..v.." > "..object.name,log.warn)
                                return true
                            else
                                log("tried to manipulate dead object.",log.error)
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
                                log("tried to manipulate dead object.",log.error)
                                return false,"object no longer exist"
                            end
                        end,
                        replicate=function(name)
                            if guis[v][object.name] then
                                if name == object.name then
                                    return "name of copy cannot be the same!"
                                else
                                    log("Replicated "..v.." > "..object.name.." as "..v.." > "..name,log.info)
                                    local temp = deepcopy(guis[v][object.name])
                                    guis[v][name or ""] = temp
                                    temp.name = name
                                    return temp,true
                                end
                            else
                                log("tried to manipulate dead object.",log.error)
                                return false,"object no longer exist"
                            end
                        end,
                        isolate=function()
                            if guis[v][object.name] then
                                local object = deepcopy(guis[v][object.name])
                                log("isolated "..v.." > "..object.name,log.info)
                                return {
                                    parse=function(name)
                                        log("parsed "..v.." > "..object.name,log.info)
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
                                            log("returned "..v.." > "..object.name,log.info)
                                            return object
                                        else
                                            return false,"object no longer exist"
                                        end
                                    end,
                                    clear=function()
                                        log("Removed copied object "..v.." > "..object.name,log.info)
                                        object = nil
                                    end,
                                }
                            else
                                log("tried to manipulate dead object.",log.error)
                                return false,"object no longer exist"
                            end
                        end,
                        cut=function()
                            if guis[v][object.name] then
                                local object = deepcopy(guis[v][object.name])
                                guis[v][object.name] = nil
                                log("cut "..v.." > "..object.name,log.info)
                                return {
                                    parse=function()
                                        if object then
                                            log("parsed "..v.." > "..object.name,log.info)
                                            if guis[v][object.name] then guis[v][object.name] = nil end
                                            guis[v][object.name] = object
                                            return guis[v][object.name]
                                        else
                                            return false,"object no longer exist"
                                        end
                                    end,
                                    get=function()
                                        log("returned "..v.." > "..object.name,log.info)
                                        return object
                                    end,
                                    clear=function()
                                        log("Removed copied object "..v.." > "..object.name,log.info)
                                        object = nil
                                    end
                                }
                            else
                                log("tried to manipulate dead object.",log.error)
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
                    log("created new "..v.." > "..object.name,log.info)
                    log:dump()
                    return object
                end})
            else
                if not aok and bok then
                    log(v.." is missing an logic file !",log.error)
                end
                if not bok and aok then
                    log(v.." is missing an graphic file !",log.error)
                end
                if not aok and not bok then
                    log(v.." is missing logic and graphic file !",log.error)
                end
                if aok and (type(adat) ~= "function") then
                    log(v.." has an invalid logic file !",log.error)
                end
                if bok and (type(bdat) ~= "function") then
                    log(v.." has an invalid graphic file !",log.error)
                end
                if bok and aok and (type(bdat) ~= "function") and (type(adat) ~= "function") then
                    log(v.." has an invalid logic and graphic file !",log.error)
                end
            end
        else
            if zok and not (type(main) == "function") then
                log(v.." has invalid object file!",log.error)
            else
                log(v.." is missing an object file !",log.error)
            end
        end
    end
    return objects
end,types=fs.list("GuiH/objects")}