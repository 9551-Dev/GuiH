--[[
    * this file is used to make the
    * object generators for the
    * gui.create table
]]

local api = require("api")
local path = fs.getDir(select(2,...))

--* function used to dereference
--* the an table/gui element
local function deepcopy(orig)

    --* if the input is not an table
    --* it doesnt have an reference
    --* so we just return it
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then

        --* if it is an table we iterate over it
        copy = {}
        for orig_key, orig_value in next, orig, nil do

            --* if the table happens to be canvas
            --* we just copy it. since canvas is recursive
            --* and would cause an infinite loop
            if orig_key == "canvas" then
                copy.canvas = orig_value
            else
                --* if its not canvas then we dereference
                --* the key and value inside+
                --* and save that to our copy
                copy[deepcopy(orig_key)] = deepcopy(orig_value)
            end
        end

        --* we also create a dereferenced copy
        --* of the metatable on this table and we put it back
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end

    --* return the dereferenced copy
    return copy
end

return {main=function(i_self,guis,log)
    local object = i_self
    local objects = {}

    --* we get all the object names and iterate over them
    local object_list = fs.list(fs.combine(path,"objects"))
    for k,v in pairs(object_list) do
        log("loading object: "..v,log.update)

        --* we require the main files for this object
        local zok,main = pcall(require,"objects."..v..".object")
        if zok and type(main) == "function" then
            local aok,adat = pcall(require,"objects."..v..".logic")
            local bok,bdat = pcall(require,"objects."..v..".graphic")

            --* check if all files are present and working
            if aok and bok and (type(adat) == "function") and (type(bdat) == "function") then
                local c_file_names = fs.list(fs.combine(path.."/objects/",v))
                local custom_flags = {}
                local custom_manipulators = {}

                --* we iterate over all the files in the objects folder
                for _k,_v in pairs(c_file_names) do
                    local name = _v:match("(.*)%.") or _v

                    --* if the files name isnt any of the default files
                    --* and it isnt a directorory then
                    if not (name == "logic" or name == "graphic" or name == "object") and (not fs.isDir(path.."/objects/"..v.."/"..name)) then
                        log("objects."..v.."."..name)
                        
                        --* we require that file and add the function it returns
                        --* into custom_flags saved under the files name
                        local ok,err = pcall(require,"objects."..v.."."..name)
                        if ok then
                            log("found custom object flag \""..name .. "\" for: " .. v,log.update)
                            custom_flags[name] = require("objects."..v.."."..name)
                        else
                            log("bad object flag "..err)
                        end
                    else
                        --* if the file happens to be a directory called
                        --* manipulators then we continue
                        if name == "manipulators" then
                            log("found custom object manipulators for: " .. v,log.update)
                            
                            --* get all the files in the manipulators folder
                            --* and iterate over them
                            local manips = fs.list(path.."/objects/"..v.."/manipulators")
                            for _k,_v in pairs(manips) do

                                --* we require the file and
                                --* save it into custom_mainipulators
                                --* table under its name
                                local ok,err = pcall(require,"objects."..v..".manipulators.".._v:match("(.*)%.") or _v)
                                if ok then
                                    log("found custom object manipulator \"".._v .. "\" for: " .. v,log.update)
                                    custom_manipulators[_v:match("(.*)%.") or _v] = setmetatable({},{__call=function(_,...) return err(...) end,__index=err,__tostring=function() return "GuiH."..v..".manipulator" end})
                                else
                                    log("bad object manipulator "..err)
                                end
                            end
                        end
                    end
                end

                objects[v] = setmetatable({},{

                --* we attach the custom creation flags
                --* to the new object creator table
                __index=custom_flags,
                __tostring=function() return "GuiH.element_builder."..v end,

                --* add a __call for the object creation function
                __call=function(_,data)

                    --* create a new object using
                    --* the object.lua file of this object
                    local object = main(object,data)

                    --* make sure all the nessesary values exist in the object
                    if not (type(object.name) == "string") then object.name = api.uuid4() end
                    if not (type(object.order) == "number") then object.order = 1 end
                    if not (type(object.logic_order) == "number") then object.logic_order = 1 end
                    if not (type(object.graphic_order) == "number") then object.graphic_order = 1 end
                    if not (type(object.react_to_events) == "table") then object.react_to_events = {} end
                    if not (type(object.btn) == "table") then object.btn = {} end
                    if not (type(object.visible) == "boolean") then object.visible = true end
                    if not (type(object.reactive) == "boolean") then object.reactive = true end

                    if type(object.positioning) == "table" then
                        if data.w and not data.width  then object.positioning.width  = data.w end
                        if data.h and not data.height then object.positioning.height = data.h end
                    end

                    --* insert the new object into  the gui
                    guis[v][object.name] = object

                    local __object = object
                    local __setters = {finish=function() return __object end}
                    local __getters = {finish=function() return __object end}

                    local function make_setters_and_getters(setters,getters,object,include_child)
                        local function build_setter(array,name,tp)
                            array[name] = setmetatable({},{__call=function(_,value,keep_env)
                                if type(value) ~= tp then error("Types are immutable with setters",2) end
                                if i_self.debug then log("Modified \""..name.."\" of ".. __object.name) end
                                object[name] = value
                                return keep_env and setters or __setters
                            end})
                        end
                        local function build_getter(array,name)
                            array[name] = setmetatable({},{__call=function()
                                if i_self.debug then log("Read \"" .. name .. "\" of ".. __object.name) end
                                return object[name]
                            end})
                        end
                        for key,current_value in pairs(object) do
                            local inc_child = key ~= "canvas" and key ~= "parent"
                            build_setter(setters,key,type(current_value))
                            build_getter(getters,key)
                            if type(current_value) == "table" and include_child then
                                if not setters[key] then setters[key] = {} end
                                if not getters[key] then getters[key] = {} end
                                make_setters_and_getters(setters[key],getters[key],current_value,inc_child)
                            end
                        end
                    end

                    make_setters_and_getters(__setters,__getters,object,true)

                    --* attach custom manipulatos to the object
                    --* also attach the core functions
                    local  build_canvas = deepcopy(custom_manipulators) or {}
                    local index = {}

                    local attached = false

                    for k,v in pairs(build_canvas) do
                        index[k] = function(...) return v(object,...) end
                        attached = true
                    end

                    if attached then log("Finished attaching manipulators to creator.",log.info) end

                    index.logic=adat
                    index.graphic=bdat

                    index.set = __setters
                    index.get = __getters

                    --* we attach default manipulators to the object
                    index.kill=function()

                        --* if the object existst   
                        if guis[v][object.name] then

                            --* we remove it from the GUI
                            guis[v][object.name] = nil
                            if i_self.debug then log("killed "..v.." > "..object.name,log.warn) end
                            return true
                        else
                            if i_self.debug then log("tried to manipulate dead object.",log.error) end
                            return false,"object no longer exist"
                        end
                    end 
                    index.get_position=function()

                        --* if the object exists we return its position
                        if guis[v][object.name] then
                            if object.positioning then
                                return object.positioning
                            else
                                return false,"object doesnt have positioning information"
                            end
                        else
                            if i_self.debug then log("tried to manipulate dead object.",log.error) end
                            return false,"object no longer exist"
                        end
                    end
                    index.replicate=function(name)
                        name = name or api.uuid4()

                        --* if the object exists and we give it a diffirent name then
                        if guis[v][object.name] then
                            if name == object.name then
                                return "name of copy cannot be the same!"
                            else

                                --* we make a deepcopy of this object and add it
                                --* to the gui with the new name
                                if i_self.debug then log("Replicated "..v.." > "..object.name.." as "..v.." > "..name,log.info) end
                                local temp = deepcopy(guis[v][object.name])
                                guis[v][name or ""] = temp
                                temp.name = name
                                return temp,true
                            end
                        else
                            if i_self.debug then log("tried to manipulate dead object.",log.error) end
                            return false,"object no longer exist"
                        end
                    end
                    index.isolate=function()
                        if guis[v][object.name] then
                            --* we save a deep copy of this object
                            local object = deepcopy(guis[v][object.name])
                            if i_self.debug then log("isolated "..v.." > "..object.name,log.info) end
                            return {
                                parse=function(name)
                                    if i_self.debug then log("parsed "..v.." > "..object.name,log.info) end
                                    --* if we still have the deepcopy we add it back to the gui
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
                                        if i_self.debug then log("returned "..v.." > "..object.name,log.info) end
                                        return object
                                    else
                                        return false,"object no longer exist"
                                    end
                                end,
                                clear=function()
                                    if i_self.debug then log("Removed copied object "..v.." > "..object.name,log.info) end
                                    object = nil
                                end,
                            }
                        else
                            if i_self.debug then log("tried to manipulate dead object.",log.error) end
                            return false,"object no longer exist"
                        end
                    end
                    index.cut=function()
                        --* we save a deep copy of this object
                        --* and then remove it from the GUI
                        if guis[v][object.name] then
                            local object = deepcopy(guis[v][object.name])
                            guis[v][object.name] = nil
                            if i_self.debug then log("cut "..v.." > "..object.name,log.info) end
                            return {
                                parse=function()
                                    --* if we still got the copy then
                                    --* we add it back to the GUI
                                    if object then
                                        if i_self.debug then log("parsed "..v.." > "..object.name,log.info) end
                                        if guis[v][object.name] then guis[v][object.name] = nil end
                                        guis[v][object.name] = object
                                        return guis[v][object.name]
                                    else
                                        return false,"object no longer exist"
                                    end
                                end,
                                get=function()
                                    if i_self.debug then log("returned "..v.." > "..object.name,log.info) end
                                    return object
                                end,
                                clear=function()
                                    if i_self.debug then log("Removed copied object "..v.." > "..object.name,log.info) end
                                    object = nil
                                end
                            }
                        else
                            if i_self.debug then log("tried to manipulate dead object.",log.error) end
                            return false,"object no longer exist"
                        end
                    end
                    
                    --* aliases for object.kill
                    index.destroy = index.kill
                    index.murder = index.destroy
                    index.copy = index.isolate

                    --* we check if the object has propper main functions attached
                    if not type(index.logic) == "function" then log("object "..v.." has invalid logic.lua",log.error) return false end
                    if not type(index.graphic) == "function" then log("object "..v.." has invalid graphic.lua",log.error) return false end

                    --* we attach theese to the object
                    --* and give it a pointer to the gui object it is in
                    setmetatable(object,{__index = index,__tostring=function() return "GuiH.element."..v.."."..object.name end})
                    if object.positioning then setmetatable(object.positioning,{__tostring=function() return "GuiH.element.position" end}) end
                    object.canvas = i_self

                    log("created new "..v.." > "..object.name,log.info)
                    log:dump()

                    --* return the finished object
                    return object
                end})
            else
                
                --* logs for debbuging purposes
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

    --* return the list of object builders
    return objects
end,types=fs.list(fs.combine(path,"objects"))}
