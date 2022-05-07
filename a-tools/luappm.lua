local function read_characters(file,start,en)
    local out = {}
    for i=start,en do
        file.seek("set",i)
        table.insert(out,file.read())
    end
    return string.char(table.unpack(out))
end

local function get_meta(file,on)
    local sekt = on
    local out = {}
    for i=1,3 do
        local full = {}
        local data = ""
        while not (data == 0x20 or data == 0x0A) do
            file.seek("set",sekt)
            data = file.read()
            table.insert(full,data)
            sekt = sekt + 1
        end
        table.insert(out,tonumber(string.char(table.unpack(full))))
    end
    return out,sekt
end

local function get_image_data(file,on,meta)
    local sekt = on
    local out = {}
    local pixels = 0
    file.seek("set",on)
    while file.read() do pixels = pixels + 1 end
    file.seek("set",sekt)
    for i=1,math.floor(pixels/3) do
        local data = ""
        for i=1,3 do
            local running = 0
            local full = {}
            while data and running < 3 do
                file.seek("set",sekt)
                data = file.read()
                if data ~= nil then data = data/meta[3] end
                table.insert(full,data)
                sekt = sekt + 1
                running = running + 1
            end
            if not next(full) then break end
            table.insert(out,{r=full[1],g=full[2],b=full[3]})
        end
    end
    return out,pixels/3
end

local function process_to_2d_array(list,width,tp)
    local out = {}
    for k,v in pairs(list) do
        local x = math.floor((k-1)%width+1)
        local y = math.ceil(k/width)
        if not out[tp and x or y] then out[tp and x or y] = {} end
        out[tp and x or y][tp and y or x] = v
    end
    return out
end

local function decode(_file)
    local file = fs.open(_file,"rb")
    if not file then error("File: "..(_file or "").." doesnt exist",3) end
    if read_characters(file,0,2) == "P6\x0A" then
        local seek_offset = -math.huge
        while true do
            local data = file.read()
            if string.char(data) == "#" then
                while true do
                    local cmt_part = file.read()
                    if cmt_part == 0x0A then break end
                    seek_offset = file.seek("cur")+1
                end
            else
                local meta,seek_offset = get_meta(file,seek_offset)
                local _temp,pixels = get_image_data(file,seek_offset,meta)
                local data = process_to_2d_array(_temp,meta[1],true)
                local file_data = file.readAll()
                file.close()
                return {
                    data=file_data,
                    meta=meta,
                    pixels=data,
                    pixel_count=pixels,
                    width=meta[1],
                    height=meta[2],
                    color_type=meta[3],
                    get_pixel=function(x,y)
                        local y_list = data[math.floor(x+0.5)]
                        if y_list then
                            return y_list[math.floor(y+0.5)]
                        end
                    end,
                    get_palette=function()
                        local cols = {}
                        local palette_cols = 0
                        local out = {}
                        local final = {}
                        for k,v in pairs(_temp) do
                            local hex = colors.packRGB(v.r,v.g,v.b)
                            if not cols[hex] then
                                palette_cols = palette_cols + 1
                                cols[hex] = {c=hex,count=0}
                            end
                            cols[hex].count = cols[hex].count + 1
                        end
                        for k,v in pairs(cols) do
                            table.insert(out,v)
                        end
                        table.sort(out,function(a,b) return a.count > b.count end)
                        for k,v in ipairs(out) do
                            local r,g,b = colors.unpackRGB(v.c)
                            table.insert(final,{r=r,g=g,b=b,c=v.count})
                        end
                        return final,palette_cols
                    end
                }
            end
        end
    else
        error("File is unsupported format: "..read_characters(file,0,1),2)
        file.close()
    end
end

return decode