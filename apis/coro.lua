local expect = require("cc.expect").expect

local function get_keys(tbl)
    local keys = {}
    for k,_ in pairs(tbl) do
        table.insert(keys,k)
    end
    return keys
end

local function iterate_order(tbl)
    local indice = 0
    local keys = get_keys(tbl)
    table.sort(keys, function(a, b) return a<b end)
    return function()
        indice = indice + 1
        if tbl[keys[indice]] then return keys[indice],tbl[keys[indice]]
        else return end
    end
end


local function coro_main(...)
    local erro
    local object = {
        coros={},
        id_names={},
        running=true
    }
    local routine_id = 0
    local function create_wrapped_coro(func)
        return setmetatable({},{__index={coro=coroutine.create(function()
            local ok,err = pcall(func)
            if not ok then erro = err end
        end)}})
    end
    for k,v in ipairs({...}) do
        if type(v) == "function" then
            routine_id = routine_id + 1
            local coro = create_wrapped_coro(v)
            object.id_names[routine_id] = 1
            if not object.coros[1] then object.coros[1] = {} end
            object.coros[1][routine_id] = setmetatable({},{
                __index={
                    coro=coro.coro,
                    kill=function()
                        object.coros[1][routine_id] = nil
                        object.id_names[routine_id] = nil
                    end
                }
            })
        end
    end
    local function checkLiving()
        local living = 0
        for name,order in pairs(object.id_names) do
            if coroutine.status(object.coros[order][name].coro) ~= "dead" then
                living = living + 1
            end
        end
        return living
    end
    local index = {
        create=function(fnc,name,order)
            local order = order or 1
            expect(1,fnc,"function")
            expect(2,name,"string","nil")
            expect(3,order,"number")
            routine_id = routine_id + 1
            object.id_names[name or routine_id] = order
            if not object.coros[order] then object.coros[order] = {} end
            object.coros[order][name or routine_id] = create_wrapped_coro(fnc)
            return setmetatable(object.coros[order][name or routine_id],{
                __index={
                    kill=function()
                        object.coros[order][name or routine_id] = nil
                        object.id_names[name or routine_id] = nil
                    end,
                    coro = object.coros[order][name or routine_id].coro
                },
            })
        end,
        kill=function(name)
            expect(2,name,"string")
            object.coros[object.id_names[name]][name] = nil
            object.id_names[name] = nil
        end,
        get=function(name)
            expect(2,name,"string")
            if not object.id_names[name] then return "coroutine no longer exists." end
            return object.coros[object.id_names[name]][name]
        end,
        living=checkLiving,
        stop=function()
            object.running=false
        end,
        run=function()
            object.running=true
            while object.running do
                local event = table.pack(os.pullEventRaw())
                if erro then error(erro,0) end
                if event[1] == "terminate" then error("Terminated",0) end
                for key,_v in iterate_order(object.coros) do
                    for k,coro in pairs(_v) do
                        if coroutine.status(coro.coro) == "dead" then
                            object.coros[key][k] = nil
                            object.id_names[k] = nil
                        else
                            coroutine.resume(coro.coro,table.unpack(event,1,event.n))
                        end
                    end
                end
                if checkLiving() < 1 then return true end
            end
        end
    }
    return setmetatable(object,{__index=index})
end

return {create=coro_main}
