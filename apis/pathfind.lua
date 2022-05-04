local pure_lua = false

local expect
if not pure_lua then
    expect = require("cc.expect").expect
end

local function node(x,y,z,passable)
    if not pure_lua then
        expect(1,x,"number")
        expect(2,y,"number")
        expect(3,z,"number")
        expect(4,passable,"boolean","nil")
    end
    if passable == nil then passable = true end
    local gCost = 0
    local hCost = 0
    return setmetatable({
        passable = passable,
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

local function index_proximal(list,num)
    local diffirences = {}
    local outs = {}
    for k,v in pairs(list) do
        local diff = math.abs(k-num)
        diffirences[#diffirences+1],outs[diff] = diff,k
    end
    local proximal = math.min(table.unpack(diffirences))
    return list[outs[proximal]]
end

local function get_distance(nodeA,nodeB)
    return math.sqrt((nodeA.pos.x - nodeB.pos.x)^2 + (nodeA.pos.y - nodeB.pos.y)^2 + (nodeA.pos.z - nodeB.pos.z)^2)
end

local function tblRev(tbl)
    local temp = {}
    for k,v in pairs(tbl) do
        temp[(#tbl-k+1)] = v
    end
    return temp
end

local function createField(w,h,d,xi,yi,zi)
    if not pure_lua then
        expect(1,w,"number")
        expect(2,h,"number")
        expect(3,d,"number")
        expect(4,xi,"number","nil")
        expect(5,yi,"number","nil")
        expect(6,zi,"number","nil")
    end
    xi,yi,zi = xi or 1,yi or 1,zi or 1
    local temp = createNDarray(3,{})
    for x=xi,xi+w do
        for y=yi,yi+h do
            for z=zi,zi+d do
                temp[x][y][z] = node(x,y,z,true)
            end
        end
    end
    return {grid=temp,size={w=w,h=h,d=d}}
end

local function add(tbl,pointer,pnode)
    table.insert(tbl,pnode)
    pointer[pnode.pos.x][pnode.pos.y][pnode.pos.z] = #tbl
end

local function find(tbl,pointer,node)
    return tbl[pointer[node.pos.x][node.pos.y][node.pos.z]] or {}
end

local function match_cord(a,b)
    local pa,pb = a.pos,b.pos
    return pa.x == pb.x and pa.y == pb.y and pa.z == pb.z
end

local function decrem(tbl)
    for x,yList in pairs(tbl) do
        for y,zList in pairs(yList) do
            for z,node in pairs(zList) do
                tbl[x][y][z] = tbl[x][y][z]-1
            end
        end
    end
end

local function getNeighbors(node,grid)
    local neighbors = {}
    for x=-1,1 do
        for y=-1,1 do
            for z=-1,1 do
                local abs = vector.new(math.abs(x),math.abs(y),math.abs(z))
                if not (x == 0 and y == 0 and z == 0) and (abs.x+abs.y+abs.z == 1) then
                    local check_x = node.pos.x+x
                    local check_y = node.pos.y+y
                    local check_z = node.pos.z+z
                    if check_x < grid.size.w+1 and check_y < grid.size.h+1 and check_z < grid.size.d+1 then
                        local neighbor = grid.grid[check_x][check_y][check_z]
                        if next(neighbor) then table.insert(neighbors, neighbor) end
                    end
                end
            end
        end
    end
    return neighbors
end

local function retrace_path(set)
    local path = {}
    local current_node = set[#set]
    while current_node do
        table.insert(path,vector.new(current_node.pos.x,current_node.pos.y,current_node.pos.z))
        current_node = current_node.parent
    end
    return tblRev(path)
end

local function pathfind(grid_dat,startn,endn)
    if not pure_lua then
        expect(1,grid_dat,"table")
        expect(2,startn,"table")
        expect(3,endn,"table")
    end
    local start_node = startn
    local target_node = endn
    local open_set = {}
    local closed_set = {}
    local open_pointer = createNDarray(2)
    local closed_pointer = createNDarray(2)
    add(open_set,open_pointer,start_node)
    while next(open_set) do
        local current_node = open_set[1]
        for k,v in ipairs(open_set) do
            if (v.fCost < current_node.fCost) or ((v.fCost == current_node.fCost) and v.hCost < current_node.hCost) then
                current_node = v
            end 
        end 
        add(closed_set,closed_pointer,current_node)
        table.remove(open_set,1)
        decrem(open_pointer)
        open_pointer[current_node.pos.x][current_node.pos.y][current_node.pos.z] = nil
        if match_cord(current_node,target_node) then
            return retrace_path(closed_set)
        end
        for k,neighbor in pairs(getNeighbors(current_node,grid_dat)) do
            if not (not neighbor.passable or next(find(closed_set,closed_pointer,neighbor))) then
                local new_mov_cost = current_node.gCost + get_distance(current_node,neighbor)
                if (new_mov_cost < neighbor.gCost) or not next(find(open_set,open_pointer,neighbor)) then
                    neighbor.gCost = new_mov_cost
                    neighbor.hCost = get_distance(neighbor,target_node)
                    neighbor.parent = current_node
                    if not next(find(open_set,open_pointer,neighbor)) then
                        add(open_set,open_pointer,neighbor)
                    end
                end
            end
        end
        os.queueEvent("pathfinding")
        os.pullEvent("pathfinding")
    end
    return false
end

local function get3DarraySquareWHD(array)
    if not pure_lua then
        expect(1,array,"table")
    end
    local minx, maxx = math.huge, -math.huge
    local miny,maxy = math.huge, -math.huge
    local minz,maxz = math.huge, -math.huge
    for x,yList in pairs(array) do
        minx, maxx = math.min(minx, x), math.max(maxx, x)
        for y,zList in pairs(yList) do
            miny, maxy = math.min(miny, y), math.max(maxy, y)
            for z,_ in pairs(zList) do
                minz, maxz = math.min(minz, z), math.max(maxz, z)
            end
        end
    end
    return {w=math.abs(minx)+maxx,h=math.abs(miny)+maxy,d=math.abs(minz)+maxz}
end

return {
    pathfind=pathfind,
    node=node,
    createField=createField,
    get_array_whd=get3DarraySquareWHD,
    index_proximal=index_proximal,
    createNDarray=createNDarray
}
