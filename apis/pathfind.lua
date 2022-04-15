local pureLua = false
local expect
if not pureLua then
    expect = require("cc.expect").expect
end
local vector = {}
vector.new = function(x,y,z)
    return setmetatable({
        x=x or 0,
        y=y or 0,
        z=z or 0
    },{__add=function(i,x)
        return {
            x=i.x+x.x,
            y=i.y+x.y,
            z=i.z+x.z
        }
    end,
    __tostring = function(self)
        local x = tostring(self.x)
        local y = tostring(self.y)
        local z = tostring(self.z)
        return x..","..y..","..z
    end
    })
end
local createNode = function(passable,x,y,z)
    if passable == nil then passable = true end
    if not pureLua then
        expect(1,passable,"boolean","nil")
        expect(2,x,"number")
        expect(3,y,"number")
    end
    local gCost = 0
    local hCost = 0
    return setmetatable({
        isPassable = passable,
        gCost = gCost,
        hCost = hCost,
        pos = vector.new(x,y,z),
    },{__index=function(self,index)
            if index == "fCost" then
                return self.gCost+self.hCost
            end
        end
    })
end
local createSelfIndexArray = function()
    return setmetatable({},
        {
            __index=function(t,k)
                local new = {}
                t[k]=new
                return new
            end
        }
    )
end
local findInGrid = function(grid,vec)
    if not pureLua then
        expect(1,grid,"table")
        expect(2,vec,"table")
    end
    for k,v in pairs(grid) do
        if (v.pos.x == vec.x) and (v.pos.y == vec.y) and (v.pos.z == vec.z) then
            return v,grid[k],k
        end
    end
end
local getNeighbors = function(grid,node,sizedat)
    local foundNeighbors = {}
    for x=-1,1 do
        for y=-1,1 do
            for z=-1,1 do
                local abs = vector.new(math.abs(x),math.abs(y),math.abs(z))
                if not (x == 0 and y == 0 and z == 0) and (abs.x+abs.y+abs.z == 1) then
                    local relative = node.pos+vector.new(x,y,z)
                    local relativeX,relativeY,relativeZ = relative.x,relative.y,relative.z
                    if relativeX < sizedat.w+1 and relativeY < sizedat.h+1 and relativeZ < sizedat.d+1 then
                        local neighbor = findInGrid(grid,vector.new(relativeX,relativeY,relativeZ))
                        table.insert(foundNeighbors,neighbor)
                    end
                end
            end
        end
    end
    return foundNeighbors
end
local getDistance = function(grid,nodeA,nodeB)
    return math.sqrt((nodeA.pos.x - nodeB.pos.x)^2 + (nodeA.pos.y - nodeB.pos.y)^2 + (nodeA.pos.z - nodeB.pos.z)^2)
end
local tblRev = function(tbl)
    local temp = {}
    for k,v in pairs(tbl) do
        temp[(#tbl-k)] = v
    end
    return temp
end
local retracePath = function(grid,sNode,nNode,sizedat)
    local path = {nNode}
    local curNode = nNode
    local eStr = tostring(sNode.pos)
    local curNode = (getNeighbors(grid,curNode,sizedat))[1]
    if curNode then
        while tostring(curNode.pos) ~= eStr do
            table.insert(path,curNode)
            curNode = curNode.parent
        end
    end
    table.insert(path,sNode)
    local output = {}
    local tempValue = tblRev(path)
    for k,v in pairs(tempValue or {}) do
        table.insert(output,{x=v.pos.x,y=v.pos.y,z=v.pos.z,g=v.gCost,h=v.hCost,f=v.fCost})
        tempValue = v.parent
    end
    return output
end
local createField = function(w,h,d,xin,yin,zin,width,height,depth)
    if not pureLua then
        expect(1,w,"number")
        expect(2,h,"number")
        expect(3,xin,"number")
        expect(4,yin,"number")
    end
    width = width or w
    height = height or h
    local temp = {}
    for x=xin,xin+width do
        for y=yin,yin+height do
            for z=zin,zin+depth do
                table.insert(temp,createNode(true,x,y,z))
            end
        end
    end
    return {grid=temp,sizeData={w=w,h=h,d=d}}
end
local pathfind = function(gridData,startNode,endNode)
    if not pureLua then
        expect(1,gridData,"table")
        expect(2,startNode,"table")
        expect(3,endNode,"table")
    end
    local grid = gridData.grid
    local sizedat = gridData.sizeData
    local targetNode = endNode
    local openSet = {startNode}
    local closedSet = {}
    while next(openSet) do
        if not pureLua then
            os.queueEvent("fake")
            os.pullEvent("fake")
        end
        local lastIndice = 1
        local curNode = openSet[1]
        for i=2,#openSet do
            if (openSet[i].fCost < curNode.fCost) or (openSet[i].fCost == curNode.fCost and openSet[i].hCost < curNode.hCost) then
                curNode = openSet[i]
                lastIndice = i
            end
        end
        table.insert(closedSet,curNode)
        table.remove(openSet, lastIndice)
        local cx,cy,cz = curNode.pos.x,curNode.pos.y,curNode.pos.z
        local ex,ey,ez = targetNode.pos.x,targetNode.pos.y,targetNode.pos.z
        if cx == ex and cy == ey and cz == ez then
            return retracePath(closedSet,startNode,targetNode,sizedat)
        end
        for i,neighbor in pairs(getNeighbors(grid,curNode,sizedat)) do
            if not ((not neighbor.isPassable) or findInGrid(closedSet,neighbor.pos)) then
                local newMovCostToNeighbor = curNode.gCost + getDistance(grid,curNode,neighbor)
                if (newMovCostToNeighbor < neighbor.gCost) or not findInGrid(openSet,neighbor.pos) then
                    neighbor.gCost = newMovCostToNeighbor
                    neighbor.hCost = getDistance(grid,neighbor,targetNode)
                    neighbor.parent = curNode
                    if not findInGrid(openSet,neighbor.pos) then
                        table.insert(openSet,neighbor)
                    end
                end
            end
        end
    end
    return {},false,"unable to find path"
end

return {
    pathfind=pathfind,
    createField=createField,
    findInGrid=findInGrid,
    createNode=createNode
}
