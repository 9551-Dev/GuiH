--[[
    * this file includes general usage functions so i wont
    * explain them. i use this file almost everywhere and
    * cause it has some useful stuff
]]

local function is_within_field(x,y,start_x,start_y,width,height)
    return x >= start_x and x < start_x+width and y >= start_y and y < start_y+height
end

local HSVToRGB = function(hue, saturation, value)
    if saturation == 0 then return value, value, value end
    local hue_sector = math.floor(hue / 60)
    local hue_sector_offset = (hue / 60) - hue_sector
    local p = value * (1 - saturation)
    local q = value * (1 - saturation * hue_sector_offset)
    local t = value * (1 - saturation * (1 - hue_sector_offset))
    if hue_sector == 0 then return value, t, p
    elseif hue_sector == 1 then return q, value, p
    elseif hue_sector == 2 then return p, value, t
    elseif hue_sector == 3 then return p, q, value
    elseif hue_sector == 4 then return t, p, value
    elseif hue_sector == 5 then return value, p, q end
end

local function createNDarray(n, tbl)
    tbl = tbl or {}
    if n == 0 then return tbl end
    setmetatable(tbl, {__index = function(t, k)
        local new = createNDarray(n - 1)
        t[k] = new
        return new
    end})
    return tbl
end

local create2Darray = function(tbl)
    return setmetatable(tbl or {},
        {
            __index=function(t,k)
                local new = {}
                t[k]=new
                return new
            end
        }
    )
end

local create3Darray = function(tbl)
    return setmetatable(tbl or {},
        {
            __index=function(t,k)
                local new = create2Darray()
                t[k]=new
                return new
            end
        }
    )
end

local function merge_tables(...)
    local out = {}
    for k,v in pairs({...}) do
        for _k,_v in pairs(v) do table.insert(out,_v) end
    end
    return out
end

local function interpolateY(a,b,y)
    local ya = y - a.y
    local ba = b.y - a.y
    local x = a.x + (ya * (b.x - a.x)) / ba
    local z = a.z + (ya * (b.z - a.z)) / ba
    return x,z
end

local function interpolateZ(a,b,x)
    local z = a.z + (x-a.x) * (((b.z-a.z)/(b.x-a.x)))
    return z
end

local function interpolateOnLine(x1, y1, w1, x2, y2, w2, x3, y3)
    local fxy1=(x2-x3)/(x2-x1)*w1+(x3-x1)/(x2-x1)*w2
    return (y2-y3)/(y2-y1)*fxy1+(y3-y1)/(y2-y1)*fxy1
end

local function lerp(v1,v2,t)
    return (1 - t) * v1 + t * v2
end

local function switchXYArray(array)
    local output = createSelfIndexArray()
    for x,yout in pairs(array) do
        if type(yout) == "table" then
            for y,val in pairs(yout) do
                output[y][x] = val
            end
        end
    end
    return output
end

local getTrueTableLen = function(tbl)
    local realLen = 0
    for k,v in pairs(tbl) do
        realLen = realLen + 1
    end
    return realLen,#tbl
end

local compareTable = function(tbl1,tbl2)
    local isMatching = true
    local tbl1Len = getTrueTableLen(tbl1)
    local tbl2Len = getTrueTableLen(tbl2)
    for k,v in pairs(tbl1) do
        if v ~= tbl2[k] then
            isMatching = false
        end
    end
    if isMatching and tbl1Len == tbl2Len then
        return true
    end
end

local function keys(tbl)
    local keys = {}
    for k,_ in pairs(tbl) do
        table.insert(keys,k)
    end
    return keys
end

local function iterate_order(tbl,reversed)
    local indice = 0
    local keys = keys(tbl)
    table.sort(keys, function(a, b)
        if reversed then return b<a
        else return a<b end
    end)
    return function()
        indice = indice + 1
        if tbl[keys[indice]] then return keys[indice],tbl[keys[indice]]
        else return end
    end
end

local function uuid4()
    local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        return string.format('%x', c == 'x' and random(0, 0xf) or random(8, 0xb))
    end)
end

local function precise_sleep(t)
    local ftime = os.epoch("utc")+t*1000
    while os.epoch("utc") < ftime do
        os.queueEvent("waiting")
        os.pullEvent("waiting")
    end
end

local function piece_string(str)
    local out = {}
    str:gsub(".",function(c)
        table.insert(out,c)
    end)
    return out
end

local function create_blit_array(count)
    local out = {}
    for i=1,count do
        out[i] = {"","",""}
    end
    return out
end

local events_with_cords = {
    monitor_touch=true,
    mouse_click=true,
    mouse_drag=true,
    mouse_scroll=true,
    mouse_up=true
}

return {
    is_within_field=is_within_field,
    tables={
        createNDarray=createNDarray,
        get_true_table_len=getTrueTableLen,
        compare_table=compareTable,
        switchXYArray=switchXYArray,
        create2Darray=create2Darray,
        create3Darray=create3Darray,
        iterate_order=iterate_order,
        merge=merge_tables
    },
    math={
        interpolateY=interpolateY,
        interpolateZ=interpolateZ,
        interpolate_on_line=interpolateOnLine,
        lerp=lerp
    },
    HSVToRGB=HSVToRGB,
    uuid4=uuid4,
    precise_sleep=precise_sleep,
    piece_string=piece_string,
    create_blit_array=create_blit_array,
    events_with_cords=events_with_cords
}
