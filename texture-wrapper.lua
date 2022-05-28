--[[
    * this file is used for drawing and texturing
    * it loads textures. converts into nimg,
    * and draws them
]]

local decode_ppm = require "a-tools.luappm"
local api = require "api"
local expect = require "cc.expect"

local chars = "0123456789abcdef"
local saveCols, loadCols = {}, {}

--* create 2 table used for decoding and encoding blit
for i = 0, 15 do
    saveCols[2^i] = chars:sub(i + 1, i + 1)
    loadCols[chars:sub(i + 1, i + 1)] = 2^i
end

--* this function is used for decoding .nimg files
--* its actually just converting blit to numbers.
local decode = function(tbl)
    local output = api.tables.createNDarray(2)
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

--* this function will get width and height of an 2D array;;
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

--* theese to functions are for finding closest key to an non existent key in a table
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
local function index_proximal_big(list,num) --! credit to wojbie
    if not next(list) then return nil end
    if list[num] then return list[num] end
    local cur = math.floor(num+0.5)
    if list[cur] then return list[cur] end
    for i=1,math.huge do
        if list[cur+i] then return list[cur+i] end
        if list[cur-i] then return list[cur-i] end
    end
end

--* a function used to convert .nimg images into GuiH textures
local function load_texture(file_name)

    --* loads input/string file
    local file,data
    if not (type(file_name) == "table") and (file_name:match(".nimg$") and fs.exists(file_name)) then
        file = fs.open(file_name,"r")
        if not file then error("file doesnt exist",2) end
        data = textutils.unserialise(file.readAll())
    else
        data = file_name
    end

    --* decodes the nimg and converts it into a 2D map
    --* creates an empty new 2D map
    local nimg = api.tables.createNDarray(2,decode(data))
    local temp = api.tables.createNDarray(2)

    --* shifts the textur into the enw 2D map
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

    --* gets the size of the new texture
    temp.scale = {get2DarraySquareWH(temp)}

    --* returns the new texture with its
    --* dimensions,data,offset
    return setmetatable({
        tex=temp,
        offset=nimg.offset
    },{__tostring=function() return "GuiH.texture" end})
end

--* a function so compec can shut up.
local function load_cimg_texture(file_name)
    local data
    expect(1,file_name,"string","table")
    if type(file_name) == "table" then
        data = file_name
    else
        local file = fs.open(file_name,"r")
        assert(file,"file doesnt exist")
        data = textutils.unserialise(file.readAll())
        file.close()
    end
    local texture_raw = api.tables.createNDarray(2,{offset = {5, 13, 11, 4}})
    for x,y_list in pairs(data) do
        for y,c in pairs(y_list) do
            texture_raw[x+4][y+7] = {
                s=" ",
                b=c,
                t="0"
            }
        end
    end
    return load_texture(texture_raw)
end

--* finds the closest CC color to an RGB value
--* with the current palette
local function get_color(terminal,c)
    local palette = {}

    --* iterate over all the 16 colors in CC
    for i=0,15 do

        --* get the RGB values for the current CC color
        local r,g,b = terminal.getPaletteColor(2^i)

        --* use the distance formula to insert the current color
        --* and its distance from desired color into the palette table
        table.insert(palette,{
            dist=math.sqrt((r-c.r)^2 + (g-c.g)^2 + (b-c.b)^2),
            color=2^i
        })
    end

    --* sort the palette table by distance
    table.sort(palette,function(a,b) return a.dist < b.dist end)

    --* return the closet color
    return palette[1].color,palette[1].dist,palette
end

--* this function builds a CC drawing chracter from a list of 6 colors
local function build_drawing_char(arr,mode)
    local cols,fin,char,visited = {},{},{},{}
    local entries = 0
    
    --* iterate over all the colors in the list
    --* and figure out how many of each color there is
    for k,v in pairs(arr) do
        cols[v] = cols[v] ~= nil and
            {count=cols[v].count+1,c=cols[v].c}
            or (function() entries = entries + 1 return {count=1,c=v} end)()
    end

    --* we convert the colors into a format where they can be sorted.
    --* we also make sure there are no duplicate entries.
    --* if there is just one color in the entire list
    --* we make a duplicate entry on purpose
    for k,v in pairs(cols) do
        if not visited[v.c] then
            visited[v.c] = true
            if entries == 1 then table.insert(fin,v) end
            table.insert(fin,v)
        end
    end

    --* sort the colors by count to find 2 most
    --* common colors
    table.sort(fin,function(a,b) return a.count > b.count end)

    --* iterate over the 6 colors and if the colors in that spot
    --* are same as in the array we keep them
    --* if there is a color we cant fit then we make that pixel
    --* be the most common color in that character
    for k=1,6 do
        if arr[k] == fin[1].c then char[k] = 1
        elseif arr[k] == fin[2].c then char[k] = 0
        else char[k] = mode and 0 or 1 end
    end

    --* then we just convert the list of 1s and 0s into a character with some magic
    if char[6] == 1 then for i = 1, 5 do char[i] = 1-char[i] end end
    local n = 128
    for i = 0, 4 do n = n + char[i+1]*2^i end

    --* return the resulting data
    return string.char(n),char[6] == 1 and fin[2].c or fin[1].c,char[6] == 1 and fin[1].c or fin[2].c
end

--* used for indexing 1D 2x3 table with x y cordinates
local function set_symbols_xy(tbl,x,y,val)
    tbl[x+y*2-2] = val
    return tbl
end

--* uses the previous functions and the LuaPPM lib to load .ppm textures
local function load_ppm_texture(terminal,file,mode,log)
    local _current = term.current()
    log("loading ppm texture.. ",log.update)
    log("decoding ppm.. ",log.update)

    --* we load the image file and also decode it using LuaPPM
    local img = decode_ppm(file)
    log("decoding finished. ",log.success)
    
    --* if this image is valid then we continue
    if img then
        local char_arrays = {}
        log("transforming pixels to characters..",log.update)
        
        --* iterate over the imag pixels using its width and height
        for x=1,img.width do
            for y=1,img.height do

                --* converts the pixels color into an CC color
                local c = get_color(terminal or _current,img.get_pixel(x,y))

                --* finds what character on the screen the pixel belongs to
                local rel_x,rel_y = math.ceil(x/2),math.ceil(y/3)

                --* finds where in that character will the pixel be placed
                local sym_x,sym_y = (x-1)%2+1,(y-1)%3+1
                
                --* we use set_symbols_xy to add that pixel into our character at its cordiantes saved
                --* in char_arrays, which is a table of character color data
                if not char_arrays[rel_x] then char_arrays[rel_x] = {} end
                char_arrays[rel_x][rel_y] = set_symbols_xy(char_arrays[rel_x][rel_y] or {},sym_x,sym_y,c)

                --* pullEvent to prevent too long wihnout yielding error
                os.queueEvent("")
                os.pullEvent("")
            end
        end
        log("transformation finished. "..tostring((img.width/2)*(img.height/3)).." characters",log.success)

        --* we create a new empty .nimg texture
        local texture_raw = api.tables.createNDarray(2,{
            offset = {5, 13, 11, 4}
        })

        log("building nimg format..",log.update)

        --* iterate over the char_arrays table and build the nimg texture
        for x,yList in pairs(char_arrays) do
            for y,sym_data in pairs(yList) do
                local char,fg,bg = build_drawing_char(sym_data,mode)
                texture_raw[x+4][y+8] = {
                    s=char,
                    t=saveCols[fg],
                    b=saveCols[bg]
                }
            end
        end
        log("building finished. texture loaded.",log.success)
        log("")
        log:dump()

        --* at last we use load_texture to convert it to GuiH texture
        --* and then we return it along with the decoded PPM image
        return setmetatable(load_texture(texture_raw),{__tostring=function() return "GuiH.texture" end}),img
    end
end

--* function used to get a single character in an GuiH texture
local function get_pixel(x,y,tex,fill_empty)
    local texture = tex.tex

    --* calculate the width and height of the texture
    local w,h = math.floor(texture.scale[1]-0.5),math.floor(texture.scale[2]-0.5)

    --* modulo the x,y by the width,height in case the x,y goes of the texture
    x = ((x-1)%w)+1
    y = ((y-1)%h)+1

    --* read that pixel from the texture
    local pixel = texture[x][y]

    --* then we move the scale data into a termorary placed
    --* so we can use index_proximal_ small/big
    local scale = texture.scale
    texture.scale = nil

    --* we can use index_proximal to fill in empty gaps in the texture if we want to.
    if not pixel and fill_empty then
        --* we find pixel with the closest x cordinate to our
        local x_proximal = index_proximal_small(texture,x)

        --* we find pixel with the closest y cordinate to our in x_proximal
        --* and save that pixel
        pixel = index_proximal_big(x_proximal or {},y)
    end

    --* we put the scale data back
    texture.scale = scale

    --* and return our desired pixel
    return pixel
end

local function draw_box_tex(term,tex,x,y,width,height,bg,tg,offsetx,offsety)
    local bg_layers = {}
    local fg_layers = {}
    local text_layers = {}

    offsetx = offsetx or 0
    offsety = offsety or 0

    --* we first iterate over the texture to loada it into blit data
    for yis=1,height do
        for xis=1,width do
            local pixel = get_pixel(xis+offsetx,yis+offsety,tex)
            if pixel and next(pixel) then
                bg_layers[yis] = (bg_layers[yis] or "")..saveCols[pixel.background_color]
                fg_layers[yis] = (fg_layers[yis] or "")..saveCols[pixel.text_color]
                text_layers[yis] = (text_layers[yis] or "")..pixel.symbol
            else
                bg_layers[yis] = (bg_layers[yis] or "")..saveCols[bg]
                fg_layers[yis] = (fg_layers[yis] or "")..saveCols[tg]
                text_layers[yis] = (text_layers[yis] or "").." "
            end
        end
    end

    --* then we draw the blit data to the screen
    for k,v in pairs(bg_layers) do
        term.setCursorPos(x,y+k-1)
        term.blit(text_layers[k],fg_layers[k],bg_layers[k])
    end
end

return {
    load_texture=load_texture,
    load_ppm_texture=load_ppm_texture,
    load_cimg_texture=load_cimg_texture,
    code={
        get_pixel=get_pixel,
        draw_box_tex=draw_box_tex,
        to_blit=saveCols,
        to_color=loadCols,
        build_drawing_char=build_drawing_char
    }
}
