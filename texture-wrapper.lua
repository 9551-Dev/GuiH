local chars = "0123456789abcdef"
local saveCols, loadCols = {}, {}
for i = 0, 15 do
    saveCols[2^i] = chars:sub(i + 1, i + 1)
    loadCols[chars:sub(i + 1, i + 1)] = 2^i
end

local decode = function(tbl)
    local output = setmetatable({},{
        __index=function(t,k)
            local new = {}
            t[k]=new
            return new
        end
    })
    output["offset"] = tbl["offset"]
    for k,v in pairs(tbl) do
        for ko,vo in pairs(v) do
            if type(vo) == "table" then
                output[k][ko] = {}
                if vo then
                    output[k][ko].t = loadCols[vo.t]
                    output[k][ko].b = loadCols[vo.b]
                    output[k][ko].s = vo.s 
                end
            end
        end
    end
    return setmetatable(output,getmetatable(tbl))
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

local function get2DarraySquareWH(array)
    local minx, maxx = math.huge, -math.huge
    local miny,maxy = math.huge, -math.huge
    for x,yList in pairs(array) do
        minx, maxx = math.min(minx, x), math.max(maxx, x)
        for y,_ in pairs(yList) do
            miny, maxy = math.min(miny, y), math.max(maxy, y)
        end
    end
    return math.abs(minx)+maxx,math.abs(miny)+maxy
end

local function index_proximal_small(list,num)
    local diffirences = {}
    local outs = {}
    for k,v in pairs(list) do
        local diff = math.abs(k-num)
        diffirences[#diffirences+1],outs[diff] = diff,k
    end
    local proximal = math.min(table.unpack(diffirences))
    return list[outs[proximal]]
end
local function index_proximal_big(list,num) --credit to wojbie
    if not next(list) then return nil end
    if list[num] then return list[num] end
    local cur = math.floor(num+0.5)
    if list[cur] then return list[cur] end
    for i=1,math.huge do
        if list[cur+i] then return list[cur+i] end
        if list[cur-i] then return list[cur-i] end
    end
end
local function load_texture(file_name)
    if file_name:match(".nimg$") and fs.exists(file_name) then
        local file = fs.open(file_name,"r")
        local data = file.readAll()
        file.close()
        local nimg = create2Darray(decode(textutils.unserialise(data)))
        local temp = create2Darray()
        for x,dat in pairs(nimg) do
            if type(x) ~= "string" then
                for y,data in pairs(dat) do
                    temp[x-nimg.offset[1]+1][y-nimg.offset[2]+5] = {
                        text_color=data.t,
                        background_color=data.b,
                        symbol=data.s
                    }
                end
            end
        end
        temp.scale = {get2DarraySquareWH(temp)}
        return {
            tex=temp,
            offset=nimg.offset
        }
    else
        error("file doesnt exist",2)
    end
end
local function get_pixel(x,y,tex,fill_empty)
    local texture = tex.tex
    local w,h = math.floor(texture.scale[1]-0.5),math.floor(texture.scale[2]-0.5)
    x = ((x-1)%w)+1
    y = ((y-1)%h)+1
    local pixel = texture[x][y]
    local scale = texture.scale
    texture.scale = nil
    if not pixel and fill_empty then
        local x_proximal = index_proximal_small(texture,x)
        pixel = index_proximal_big(x_proximal or {},y)
    end
    texture.scale = scale
    return pixel
end
return {
    load_texture=load_texture,
    code={
        get_pixel=get_pixel,
        to_blit=saveCols,
        to_color=loadCols
    }
}