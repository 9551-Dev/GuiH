--[[
    * api for easy interaction with drawing characters
]]

local graphic = require("graphic_handle")
local api = require("util")
local EXPECT = require("cc.expect").expect
local ALGO = require("core.algo")

local PIXELBOX = {}
local OBJECT = {}

function PIXELBOX.INDEX_SYMBOL_CORDINATION(tbl,x,y,val)
    tbl[x+y*2-2] = val
    return tbl
end

function OBJECT:within(x,y)
    return x > 0
        and y > 0
        and x <= self.width*2
        and y <= self.height*3
end

function OBJECT:push_updates()
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    self.symbols = api.tables.createNDarray(2)
    self.lines = api.create_blit_array(self.height)
    getmetatable(self.symbols).__tostring=function() return "PixelBOX.SYMBOL_BUFFER" end
    setmetatable(self.lines,{__tostring=function() return "PixelBOX.LINE_BUFFER" end})
    for y,x_list in pairs(self.CANVAS) do
        for x,block_color in pairs(x_list) do
            local RELATIVE_X = math.ceil(x/2)
            local RELATIVE_Y = math.ceil(y/3)
            local SYMBOL_POS_X = (x-1)%2+1
            local SYMBOL_POS_Y = (y-1)%3+1
            self.symbols[RELATIVE_Y][RELATIVE_X] = PIXELBOX.INDEX_SYMBOL_CORDINATION(
                self.symbols[RELATIVE_Y][RELATIVE_X],
                SYMBOL_POS_X,SYMBOL_POS_Y,
                block_color
            )
        end
    end
    for y,x_list in pairs(self.symbols) do
        for x,color_block in ipairs(x_list) do
            local char,fg,bg = graphic.code.build_drawing_char(color_block)
            self.lines[y] = {
                self.lines[y][1]..char,
                self.lines[y][2]..graphic.code.to_blit[fg],
                self.lines[y][3]..graphic.code.to_blit[bg]
            }
        end
    end
end

function OBJECT:get_pixel(x,y)
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,x,"number")
    EXPECT(2,y,"number")
    assert(self.CANVAS[y] and self.CANVAS[y][x],"Out of range")
    return self.CANVAS[y][x]
end

function OBJECT:clear(color)
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,color,"number")
    self.CANVAS = api.tables.createNDarray(2)
    for y=1,self.height*3 do
        for x=1,self.width*2 do
            self.CANVAS[y][x] = color
        end
    end
    getmetatable(self.CANVAS).__tostring = function() return "PixelBOX_SCREEN_BUFFER" end
end

function OBJECT:draw()
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    if not self.lines then error("You must push_updates in order to draw",2) end
    for y,line in ipairs(self.lines) do
        self.term.setCursorPos(1,y)
        self.term.blit(
            table.unpack(line)
        )
    end
end

function OBJECT:set_pixel(x,y,color,thiccness)
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,x,"number")
    EXPECT(2,y,"number")
    EXPECT(3,color,"number")
    PIXELBOX.ASSERT(x>0 and x<=self.width*2,"Out of range")
    PIXELBOX.ASSERT(y>0 and y<=self.height*3,"Out of range")
    thiccness = thiccness or 1
    local t_ratio = (thiccness-1)/2
    self:set_box(
        math.ceil(x-t_ratio),
        math.ceil(y-t_ratio),
        x+thiccness-1,y+thiccness-1,color,true
    )
end

function OBJECT:set_box(sx,sy,ex,ey,color,check)
    if not check then
        PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
        EXPECT(1,sx,"number")
        EXPECT(2,sy,"number")
        EXPECT(3,ex,"number")
        EXPECT(4,ey,"number")
        EXPECT(5,color,"number")
    end
    for y=sy,ey do
        for x=sx,ex do
            if self:within(x,y) then
                self.CANVAS[y][x] = color
            end
        end
    end
end

function OBJECT:set_ellipse(x,y,rx,ry,color,filled,thiccness,check)
    if not check then
        PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
        EXPECT(1,x,"number")
        EXPECT(2,y,"number")
        EXPECT(3,rx,"number")
        EXPECT(4,ry,"number")
        EXPECT(5,color,"number")
        EXPECT(6,filled,"boolean","nil")
    end
    thiccness = thiccness or 1
    local t_ratio = (thiccness-1)/2 
    if type(filled) ~= "boolean" then filled = true end
    local points = ALGO.get_elipse_points(rx,ry,x,y,filled)
    for _,point in ipairs(points) do
        if self:within(point.x,point.y) then
            self:set_box(
                math.ceil(point.x-t_ratio),
                math.ceil(point.y-t_ratio),
                point.x+thiccness-1,point.y+thiccness-1,color,true
            )
        end
    end
end

function OBJECT:set_circle(x,y,radius,color,filled,thiccness)
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,x,"number")
    EXPECT(2,y,"number")
    EXPECT(3,radius,"number")
    EXPECT(4,color,"number")
    EXPECT(5,filled,"boolean","nil")
    self:set_ellipse(x,y,radius,radius,color,filled,thiccness,true)
end

function OBJECT:set_triangle(x1,y1,x2,y2,x3,y3,color,filled,thiccness)
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,x1,"number")
    EXPECT(2,y1,"number")
    EXPECT(3,x2,"number")
    EXPECT(4,y2,"number")
    EXPECT(5,x3,"number")
    EXPECT(6,y3,"number")
    EXPECT(7,color,"number")
    EXPECT(8,filled,"boolean","nil")
    thiccness = thiccness or 1
    local t_ratio = (thiccness-1)/2 
    if type(filled) ~= "boolean" then filled = true end
    local points
    if filled then points = ALGO.get_triangle_points(
        vector.new(x1,y1),
        vector.new(x2,y2),
        vector.new(x3,y3)
    )
    else points = ALGO.get_triangle_outline_points(
        vector.new(x1,y1),
        vector.new(x2,y2),
        vector.new(x3,y3)
    ) end
    for _,point in ipairs(points) do
        if self:within(point.x,point.y) then
            self:set_box(
                math.ceil(point.x-t_ratio),
                math.ceil(point.y-t_ratio),
                point.x+thiccness-1,point.y+thiccness-1,color,true
            )
        end
    end
end

function OBJECT:set_line(x1,y1,x2,y2,color,thiccness)
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,x1,"number")
    EXPECT(2,y1,"number")
    EXPECT(3,x2,"number")
    EXPECT(4,y2,"number")
    EXPECT(5,color,"number")
    thiccness = thiccness or 1
    local t_ratio = (thiccness-1)/2 
    local points = ALGO.get_line_points(x1,y1,x2,y2)
    for _,point in ipairs(points) do
        if self:within(point.x,point.y) then
            self:set_box(
                math.ceil(point.x-t_ratio),
                math.ceil(point.y-t_ratio),
                point.x+thiccness-1,point.y+thiccness-1,color,true
            )
        end
    end
end

function PIXELBOX.ASSERT(condition,message)
    if not condition then error(message,3) end
    return condition
end

function PIXELBOX.new(terminal,bg,existing)
    EXPECT(1,terminal,"table")
    EXPECT(2,bg,"number","nil")
    EXPECT(3,existing,"table","nil")
    local bg = bg or terminal.getBackgroundColor() or colors.black
    local BOX = {}
    local w,h = terminal.getSize()
    BOX.term = setmetatable(terminal,{__tostring=function() return "term_object" end})
    BOX.CANVAS = api.tables.createNDarray(2,existing)
    getmetatable(BOX.CANVAS).__tostring = function() return "PixelBOX_SCREEN_BUFFER" end
    BOX.width = w
    BOX.height = h
    for y=1,h*3 do
        for x=1,w*2 do
            BOX.CANVAS[y][x] = bg
        end
    end
    return setmetatable(BOX,{__index = OBJECT})
end

return PIXELBOX
