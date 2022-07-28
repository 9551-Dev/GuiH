--[[
    * this file is used for algorithms
    * and shape drawing purposes
    * i dont feel like explaining this file
    * since i dont understand it very much myself.
    ! sorry for that
]]

local api = require("util")

local function get_elipse_points(radius_x,radius_y,xc,yc,filled)
    local rx,ry = math.ceil(math.floor(radius_x-0.5)/2),math.ceil(math.floor(radius_y-0.5)/2)
    local x,y=0,ry
    local d1 = ((ry * ry) - (rx * rx * ry) + (0.25 * rx * rx))
    local dx = 2*ry^2*x
    local dy = 2*rx^2*y
    local points = {}
    while dx < dy do
        table.insert(points,{x=x+xc,y=y+yc})
        table.insert(points,{x=-x+xc,y=y+yc})
        table.insert(points,{x=x+xc,y=-y+yc})
        table.insert(points,{x=-x+xc,y=-y+yc})
        if filled then
            for y=-y+yc+1,y+yc-1 do
                table.insert(points,{x=x+xc,y=y})
                table.insert(points,{x=-x+xc,y=y})
            end
        end
        if d1 < 0 then
            x = x + 1
            dx = dx + 2*ry^2
            d1 = d1 + dx + ry^2
        else
            x,y = x+1,y-1
            dx = dx + 2*ry^2
            dy = dy - 2*rx^2
            d1 = d1 + dx - dy + ry^2
        end
    end
    local d2 = (((ry * ry) * ((x + 0.5) * (x + 0.5))) + ((rx * rx) * ((y - 1) * (y - 1))) - (rx * rx * ry * ry))
    while y >= 0 do
        table.insert(points,{x=x+xc,y=y+yc})
        table.insert(points,{x=-x+xc,y=y+yc})
        table.insert(points,{x=x+xc,y=-y+yc})
        table.insert(points,{x=-x+xc,y=-y+yc})
        if filled then
            for y=-y+yc,y+yc do
                table.insert(points,{x=x+xc,y=y})
                table.insert(points,{x=-x+xc,y=y})
            end
        end
        if d2 > 0 then
            y = y - 1
            dy = dy - 2*rx^2
            d2 = d2 + rx^2 - dy
        else
            y = y - 1
            x = x + 1
            dy = dy - 2*rx^2
            dx = dx + 2*ry^2
            d2 = d2 + dx - dy + rx^2
        end
    end
    return points
end

local function drawFlatTopTriangle(points,vec1,vec2,vec3)
    local m1 = (vec3.x - vec1.x) / (vec3.y - vec1.y)
    local m2 = (vec3.x - vec2.x) / (vec3.y - vec2.y)
    local yStart = math.ceil(vec1.y - 0.5)
    local yEnd =   math.ceil(vec3.y - 0.5)-1
    for y = yStart, yEnd do
        local px1 = m1 * (y + 0.5 - vec1.y) + vec1.x
        local px2 = m2 * (y + 0.5 - vec2.y) + vec2.x
        local xStart = math.ceil(px1 - 0.5)
        local xEnd =   math.ceil(px2 - 0.5)
        for x=xStart,xEnd do
            table.insert(points,{x=x,y=y})
        end
    end
end

local function drawFlatBottomTriangle(points,vec1,vec2,vec3)
    local m1 = (vec2.x - vec1.x) / (vec2.y - vec1.y)
    local m2 = (vec3.x - vec1.x) / (vec3.y - vec1.y)
    local yStart = math.ceil(vec1.y-0.5)
    local yEnd =   math.ceil(vec3.y-0.5)-1
    for y = yStart, yEnd do
        local px1 = m1 * (y + 0.5 - vec1.y) + vec1.x
        local px2 = m2 * (y + 0.5 - vec1.y) + vec1.x
        local xStart = math.ceil(px1 - 0.5)
        local xEnd =   math.ceil(px2 - 0.5)
        for x=xStart,xEnd do
            table.insert(points,{x=x,y=y})
        end
    end
end
local function get_triangle_points(pv1,pv2,pv3)
    local points = {}
    if pv2.y < pv1.y then pv1,pv2 = pv2,pv1 end
    if pv3.y < pv2.y then pv2,pv3 = pv3,pv2 end
    if pv2.y < pv1.y then pv1,pv2 = pv2,pv1 end
    if pv1.y == pv2.y then
        if pv2.x < pv1.x then pv1,pv2 = pv2,pv1 end
        drawFlatTopTriangle(points,pv1,pv2,pv3)
    elseif pv2.y == pv3.y then
        if pv3.x < pv2.x then pv3,pv2 = pv2,pv3 end
        drawFlatBottomTriangle(points,pv1,pv2,pv3)
    else 
        local alphaSplit = (pv2.y-pv1.y)/(pv3.y-pv1.y)
        local vi ={ 
            x = pv1.x + ((pv3.x - pv1.x) * alphaSplit),      
            y = pv1.y + ((pv3.y - pv1.y) * alphaSplit), }
        if pv2.x < vi.x then
            drawFlatBottomTriangle(points,pv1,pv2,vi)
            drawFlatTopTriangle(points,pv2,vi,pv3)
        else
            drawFlatBottomTriangle(points,pv1,vi,pv2)
            drawFlatTopTriangle(points,vi,pv2,pv3)
        end
    end
    return points
end

local function get_rectangle_points(x,y,width,height)
    local points = {}
    for x=x,x+width do
        for y=y,y+height do
            table.insert(points,{x=x,y=y})
        end
    end
end

--credit to computercraft paintutils api
local function get_line_points(startX, startY, endX, endY)
    local points = {}
    startX,startY,endX,endY = math.floor(startX),math.floor(startY),math.floor(endX),math.floor(endY)
    if startX == endX and startY == endY then return {x=startX,y=startY} end
    local minX = math.min(startX, endX)
    local maxX, minY, maxY
    if minX == startX then minY,maxX,maxY = startY,endX,endY
    else minY,maxX,maxY = endY,startX,startY end
    local xDiff,yDiff = maxX - minX,maxY - minY
    if xDiff > math.abs(yDiff) then
        local y = minY
        local dy = yDiff / xDiff
        for x = minX, maxX do
            table.insert(points,{x=x,y=math.floor(y + 0.5)})
            y = y + dy
        end
    else
        local x,dx = minX,xDiff / yDiff
        if maxY >= minY then
            for y = minY, maxY do
                table.insert(points,{x=math.floor(x + 0.5),y=y})
                x = x + dx
            end
        else
            for y = minY, maxY, -1 do
                table.insert(points,{x=math.floor(x + 0.5),y=y})
                x = x - dx
            end
        end
    end
    return points
end

local function get_triangle_outline_points(v1,v2,v3)
    local final_points = {}
    local s1 = get_line_points(v1.x,v1.y,v2.x,v2.y)
    local s2 = get_line_points(v2.x,v2.y,v3.x,v3.y)
    local s3 = get_line_points(v3.x,v3.y,v1.x,v1.y)
    return api.tables.merge(s1,s2,s3)
end

return {
    get_elipse_points = get_elipse_points,
    get_triangle_points = get_triangle_points,
    get_triangle_outline_points=get_triangle_outline_points,
    get_line_points=get_line_points
}
