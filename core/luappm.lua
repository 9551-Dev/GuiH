--[[
    * this is the LuaPPM library
    * its used for reading .ppm images exported from gimp
]]

--* returns all bytes between the specified start and end
local function read_characters(file,start,en)
    local out = {}

    --* reads all the bytes
    for i=start,en do
        file.seek("set",i)
        table.insert(out,file.read())
    end

    --* converts them into characters
    return string.char(table.unpack(out))
end

--* this is used to get width,height,color type of an image
local function get_meta(file,on)
    local sekt = on
    local out = {}

    --* runs 3 times since we have 3 values to get
    for i=1,3 do
        
        --* loops thru bytes until it gets an newline or space
        --* and then merges them into one number
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

--* reads all the pixel data from the image
local function get_image_data(file,on,meta)
    local sekt = on
    local out = {}
    local pixels = 0
    file.seek("set",on)

    --* get the amount of color values in an image
    while file.read() do pixels = pixels + 1 end

    file.seek("set",sekt)

    --* runs the amount of times there is pixels in the image (each pixel has 3 values R,G,B so /3)
    for i=1,math.floor(pixels/3) do
        local data = ""

        --* runs 3 times to retrieve all the 3 colors for that pixel
        for i=1,3 do
            
            --* goes forward until it finds all the color data it needs
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
            --* if there is no more data to find then stop the loop
            if not next(full) then break end
            table.insert(out,{r=full[1],g=full[2],b=full[3]})
        end
    end

    --* returuns the array of all the pixels in the image
    return out,pixels/3
end

--* this functions turns array of all the pixels and the image width anto an 2D array with the images data !
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

--* makes use of all the functions so far to decode the image
local function decode(_file)
    local file = fs.open(_file,"rb")
    if not file then error("File: "..(_file or "").." doesnt exist",3) end

    --* reads the first 3 bytes and checks if it is a raw ppm file
    if read_characters(file,0,2) == "P6\x0A" then
        local seek_offset = -math.huge
        while true do
            --* reads the first byte after "magic number"
            local data = file.read()
            --* if there is an comment it will loop
            --* until it gets to the end of it
            if string.char(data) == "#" then
                while true do
                    local cmt_part = file.read()
                    if cmt_part == 0x0A then break end
                    seek_offset = file.seek("cur")+1
                end
            else
                --* gets the metadata of the image
                local meta,seek_offset = get_meta(file,seek_offset)

                --* reads the color data
                local _temp,pixels = get_image_data(file,seek_offset,meta)

                --* turns the data into a 2D array of pixels
                local data = process_to_2d_array(_temp,meta[1],true)

                --* reads the total data in the file and closes it
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

                    --* returns a pixel from the 2D array
                    get_pixel=function(x,y)
                        local y_list = data[math.floor(x+0.5)]
                        if y_list then
                            return y_list[math.floor(y+0.5)]
                        end
                    end,

                    --* this function is used to get all the shades of colors
                    --* in the loaded image
                    get_palette=function()
                        local cols = {}
                        local palette_cols = 0
                        local out = {}
                        local final = {}

                        --* loops over all the pixels
                        --* and if it finds a pixel with a color it hasnt found yet
                        --* add it to the cols list
                        --* if this color is already in the cols list.
                        --* increase its count by 1
                        for k,v in pairs(_temp) do
                            local hex = colors.packRGB(v.r,v.g,v.b)
                            if not cols[hex] then
                                palette_cols = palette_cols + 1
                                cols[hex] = {c=hex,count=0}
                            end
                            cols[hex].count = cols[hex].count + 1
                        end

                        --* sort the colors by count from most used to least
                        for k,v in pairs(cols) do
                            table.insert(out,v)
                        end
                        table.sort(out,function(a,b) return a.count > b.count end)
                        for k,v in ipairs(out) do
                            local r,g,b = colors.unpackRGB(v.c)
                            table.insert(final,{r=r,g=g,b=b,c=v.count})
                        end

                        --* return final sorted table
                        return final,palette_cols
                    end
                }
            end
        end
    else
        --* if the file isnt raw ppm then closes the file and throws an error
        file.close()
        error("File is unsupported format: "..read_characters(file,0,1),2)
    end
end

return decode