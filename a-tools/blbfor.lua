--[[
    * BLBFOR - BLIT BYTE FORMAT
    * a format used for storing blit data
    * in a compact way
    * 1 pixel == 2 bytes
]]

local EXPECT = require("cc.expect").expect

local SEPARATION_CHAR = 0x0A
local INT_BYTE_OFFSET = 0x30
local BLBFOR = {INTERNAL={STRING={}}}
local BLBFOR_WRITE_HANDLE = {}
local BLBFOR_READ_HANDLE = {}

function BLBFOR.INTERNAL.STRING.FORMAT_BLIT(n)
    return ("%x"):format(n)
end

function BLBFOR.INTERNAL.STRING.TO_BLIT(c,mode)
    local res = (not mode) and (BLBFOR.INTERNAL.STRING.FORMAT_BLIT(select(2, math.frexp(c))-1)) or (select(2, math.frexp(c))-1)
    return res
end

function BLBFOR.INTERNAL.STRING.FROM_HEX(hex)
    return tonumber(hex,16)
end

function BLBFOR.INTERNAL.READ_BYTES_STREAM(stream,start,byte_count)
    local bytes = {}
    stream.seek("set",start)
    for i=start,start+byte_count-1 do
        local read = stream.read()
        table.insert(bytes,read)
    end
    return table.unpack(bytes)
end

function BLBFOR.INTERNAL.STRING_TO_BYTES(str)
    local bytes = {}
    for i=1,#str do
        bytes[i] = str:byte(i)
    end
    return table.unpack(bytes)
end

function BLBFOR.INTERNAL.WRITE_BYTES_STREAM(stream,pos,...)
    local bytes = {...}
    for i=1,#bytes do
        stream.seek("set",pos+i-1)
        stream.write(bytes[i])
    end
end

function BLBFOR.INTERNAL.READ_STRING_UNTIL_SEP(stream,pos)
    local str = ""
    stream.seek("set",pos)
    local byte = stream.read()
    if not byte then return false end
    while byte ~= SEPARATION_CHAR do
        str = str .. string.char(byte)
        byte = stream.read()
    end
    return str
end

function BLBFOR.INTERNAL.READ_INT(stream,pos)
    local num = 0
    stream.seek("set",pos)
    local byte = stream.read()
    while byte ~= SEPARATION_CHAR do
        num = num * 10 + (byte-INT_BYTE_OFFSET)
        byte = stream.read()
    end
    return num
end

function BLBFOR.INTERNAL.COLORS_TO_BYTE(fg,bg)
    local log_fg = select(2, math.frexp(fg))-1
    local log_bg = select(2, math.frexp(bg))-1
    return log_fg*16 + log_bg
end

function BLBFOR.INTERNAL.BYTE_TO_COLORS(byte)
    return bit32.rshift(bit32.band(0xF0,byte),4),bit32.band(0x0F,byte)
end

function BLBFOR.INTERNAL.WRITE_HEADER(image)
    image.stream.seek("set",0)
    BLBFOR.INTERNAL.WRITE_BYTES_STREAM(
        image.stream,1,
        BLBFOR.INTERNAL.STRING_TO_BYTES(("BLBFOR1\n%d\n%d\n"):format(image.width,image.height))
    )
end

function BLBFOR.INTERNAL.ASSERT(bool,msg)
    if not bool then error(msg,3)
    else return bool end
end

function BLBFOR.INTERNAL.createNDarray(n, tbl)
    tbl = tbl or {}
    if n == 0 then return tbl end
    setmetatable(tbl, {__index = function(t, k)
        local new =  BLBFOR.INTERNAL.createNDarray(n - 1)
        t[k] = new
        return new
    end})
    return tbl
end

function BLBFOR.INTERNAL.ENCODE(self)
    BLBFOR.INTERNAL.WRITE_HEADER(self)
    for y,xlist in ipairs(self.data) do
        local bytes = {}
        for x,pixel in ipairs(xlist) do
            table.insert(bytes,pixel[1])
            table.insert(bytes,BLBFOR.INTERNAL.COLORS_TO_BYTE(2^pixel[2],2^pixel[3]))
        end
        BLBFOR.INTERNAL.WRITE_BYTES_STREAM(
            self.stream,
            self.stream.seek("cur"),
            table.unpack(bytes)
        )
    end
end

function BLBFOR.INTERNAL.DECODE(image)
    image.stream.seek("set",0)
    local header = BLBFOR.INTERNAL.READ_STRING_UNTIL_SEP(image.stream,1)
    local lines = {}
    BLBFOR.INTERNAL.ASSERT(header == "BLBFOR1", "Invalid header",2)
    local width = BLBFOR.INTERNAL.READ_INT(image.stream,image.stream.seek("cur"))
    local height = BLBFOR.INTERNAL.READ_INT(image.stream,image.stream.seek("cur"))
    image.width = width
    image.height = height
    image.data = BLBFOR.INTERNAL.createNDarray(2,image.data)
    for y=1,height do
        if not lines[y] then lines[y] = {"","",""} end
        local xlist = {}
        for x=1,width do
            local pixel = {}
            local char,color =  BLBFOR.INTERNAL.READ_BYTES_STREAM(image.stream,image.stream.seek("cur"),2)
            pixel[1] = char
            pixel[2],pixel[3] = BLBFOR.INTERNAL.BYTE_TO_COLORS(color)
            xlist[x] = pixel
            lines[y] = {
                lines[y][1]..string.char(pixel[1]),
                lines[y][2]..BLBFOR.INTERNAL.STRING.FORMAT_BLIT(pixel[2]),
                lines[y][3]..BLBFOR.INTERNAL.STRING.FORMAT_BLIT(pixel[3])
            }
        end
        image.data[y] = xlist
    end
    image.lines = lines
end

function BLBFOR_WRITE_HANDLE:set_pixel(x,y,char,fg,bg)
    BLBFOR.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")
    BLBFOR.INTERNAL.ASSERT(not self.closed,"Image handle closed")
    EXPECT(1,x,"number")
    EXPECT(2,y,"number")
    EXPECT(3,char,"string")
    EXPECT(4,fg,"number")
    EXPECT(5,bg,"number")
    BLBFOR.INTERNAL.ASSERT(not (x<1 or y<1 or x>self.width or y>self.height),"pixel out of range")
    self.data[y][x] = {
        char:byte(),
        BLBFOR.INTERNAL.STRING.TO_BLIT(fg,true),
        BLBFOR.INTERNAL.STRING.TO_BLIT(bg,true)
    }
end

function BLBFOR_READ_HANDLE:get_pixel(x,y,return_blit)
    BLBFOR.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,x,"number")
    EXPECT(2,y,"number")
    EXPECT(3,return_blit,"boolean","nil")
    BLBFOR.INTERNAL.ASSERT(not (x<1 or y<1 or x>self.width or y>self.height),"pixel out of range")
    local pixel = self.data[y][x]
    local standard = {
        string.char(pixel[1]),
        2^pixel[2],
        2^pixel[3]
    }
    local blit = {
        string.char(pixel[1]),
        BLBFOR.INTERNAL.STRING.FORMAT_BLIT(pixel[2]),
        BLBFOR.INTERNAL.STRING.FORMAT_BLIT(pixel[3])
    }
    return table.unpack(return_blit and blit or standard)
end

function BLBFOR_READ_HANDLE:get_line(y)
    BLBFOR.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,y,"number")
    BLBFOR.INTERNAL.ASSERT(not (y<1 or y>self.height),"line out of range")
    return self.lines[y][1],self.lines[y][2],self.lines[y][3]
end

function BLBFOR_WRITE_HANDLE:set_line(y,char,fg,bg)
    BLBFOR.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")
    BLBFOR.INTERNAL.ASSERT(not self.closed,"Image handle closed")
    EXPECT(1,y,"number")
    EXPECT(2,char,"string")
    EXPECT(3,fg,"string")
    EXPECT(4,bg,"string")
    BLBFOR.INTERNAL.ASSERT(#fg == #char and #bg == #char,"line length mismatch")
    BLBFOR.INTERNAL.ASSERT(#char <= self.width,"line too long")
    BLBFOR.INTERNAL.ASSERT(y <= self.height and y > 0,"line out of range")
    for x=1,#char do
        self:set_pixel(
            x,y,
            char:sub(x,x),
            2^BLBFOR.INTERNAL.STRING.FROM_HEX(fg:sub(x,x)),
            2^BLBFOR.INTERNAL.STRING.FROM_HEX(bg:sub(x,x))
        )
    end
end

function BLBFOR_WRITE_HANDLE:close()
    BLBFOR.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")
    BLBFOR.INTERNAL.ASSERT(not self.closed,"Image handle closed")
    BLBFOR.INTERNAL.ENCODE(self)
    self.stream.close()
    self.closed = true
end

function BLBFOR_WRITE_HANDLE:flush()
    BLBFOR.INTERNAL.ASSERT(type(self)=="table","Please use \":\" when running this function")
    BLBFOR.INTERNAL.ASSERT(not self.closed,"Image handle closed")
    BLBFOR.INTERNAL.ENCODE(self)
    self.stream.flush()
end

BLBFOR_WRITE_HANDLE.write_pixel = BLBFOR_WRITE_HANDLE.set_pixel
BLBFOR_WRITE_HANDLE.write_line = BLBFOR_WRITE_HANDLE.set_line
BLBFOR_READ_HANDLE.read_pixel = BLBFOR_READ_HANDLE.get_pixel
BLBFOR_READ_HANDLE.read_line = BLBFOR_READ_HANDLE.get_line

function BLBFOR.open(file, mode, width, height, FG, BG, SYM)
    EXPECT(1,file,"string")
    EXPECT(2,mode,"string")
    local EXT = file:match("%.%a+$")
    BLBFOR.INTERNAL.ASSERT(EXT==".blbfor","file must be a .blbfor file")
    local image = {}
    if mode:sub(1,1):lower() == "w" then
        EXPECT(3,width,"number")
        EXPECT(4,height,"number")
        EXPECT(5,FG,"number","nil")
        EXPECT(6,BG,"number","nil")
        EXPECT(7,SYM,"string","nil")
        local stream = fs.open(file,"wb")
        if not stream then error("Could not open file",2) end
        image.width = width
        image.height = height
        image.data = BLBFOR.INTERNAL.createNDarray(2)
        image.stream = stream
        for x=1,width do
            for y=1,height do
                image.data[y][x] = {
                    (SYM or string.char(0)):byte(),
                    BLBFOR.INTERNAL.STRING.TO_BLIT(FG or colors.black,true),
                    BLBFOR.INTERNAL.STRING.TO_BLIT(BG or colors.black,true)
                }
            end
        end
        return setmetatable(image,{__index=BLBFOR_WRITE_HANDLE})
    elseif mode:sub(1,1):lower() == "r" then
        local stream = fs.open(file,"rb")
        if not stream then error("Could not open file",2) end
        local pos = stream.seek("cur")
        image.raw = stream.readAll()
        stream.seek("set",pos)
        image.stream = stream
        BLBFOR.INTERNAL.DECODE(image)
        image.closed = true
        stream.close()
        return setmetatable(image,{__index=BLBFOR_READ_HANDLE})
    else
        stream.close()
        error("invalid mode. please use \"w\" or \"r\" (Write/Read)",2)
    end
end

return BLBFOR