--[[
    * this file will have various tools
    * and utilities for working with term objects
]]

local function mirror(base,...)
    local mons = {...}
    local out = {}
    for fname,_ in pairs(mons[1]) do
        out[fname] = function(...)
            local ret = table.pack(base[fname](...))
            for k,mon in pairs(mons) do
                ret = table.pack(mon[fname](...))
            end
            return table.unpack(ret,1,ret.n or 1)
        end
    end
    return out
end

local function make_shared(...)
    local mons = {...}
    local out = {}
    for fname,_ in pairs(mons[1]) do
        out[fname] = function(...)
            local ret = {}
            for k,mon in pairs(mons) do
                ret = table.pack(mon[fname](...))
            end
            return table.unpack(ret,1,ret.n or 1)
        end
    end
    return out
end

return {
    mirror=mirror,
    make_shared=make_shared
}
