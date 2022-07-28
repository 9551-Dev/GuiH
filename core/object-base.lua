--[[
    ! this file doesnt do anything !
    * it shows how to make a propper new object.lua
    * for your own custom elements
]]

local api = require("util")
return function(object,data)
    data = data or {}
    if type(data.visible) ~= "boolean" then data.visible = true end
    if type(data.reactive) ~= "boolean" then data.reactive = true end
    local base = {
        name=data.name or api.uuid4(),
        visible=data.visible,
        reactive=data.reactive,
        react_to_events={}, --*events that the object should run logic.lua on. LUT
        btn={}, --*buttons that the object should run logic.lua on. LUT
        order=data.order or 1,
        logic_order=data.logic_order,
        graphic_order=data.graphic_order,
    }
    return base
end