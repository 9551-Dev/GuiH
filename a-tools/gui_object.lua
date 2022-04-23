local objects = require("GuiH.object-loader")
local update = require("GuiH.a-tools.update")

local function create_gui_object(term_object,orig,log)
    local gui_objects = {}
    local type = "term_object"
    pcall(function()
        type = peripheral.getType(orig)
    end)
    for k,v in pairs(objects.types) do gui_objects[v] = {} end
    local gui = {
        term_object=term_object,
        gui=gui_objects,
        update=update,
        visible=true,
        id=os.epoch("utc"),
        task_schedule={},
        update_delay=0,
        held_keys={},
        log=log
    }
    log("set up updater",log.update)
    local function updater(timeout,visible,is_child,data)
        return update(gui,timeout,visible,is_child,data)
    end
    local task_routine = {}
    local task_id = 0
    local err = "ok"
    gui.schedule=function(fnc)
        task_id = task_id + 1
        log("scheduled task: "..tostring(task_id))
        task_routine[task_id] = coroutine.create(function()
            local ok,erro  = pcall(fnc,gui,gui.term_object)
            if not ok then err = erro end
        end)
    end
    gui.isHeld = function(key)
        local info = gui.held_keys[key] or {}
        if info[1] then return true,info[2] end
        return false,false
    end
    gui.execute=function(fnc,on_event,bef_draw)
        log("")
        log("loading execute..",log.update)
        local execution_window = gui.term_object
        local event
        local sbg  = execution_window.getBackgroundColor()
        local gui_coro = coroutine.create(function()
            local ok,erro = pcall(function()
                execution_window.setVisible(true)
                updater(0)
                execution_window.redraw()
                while true do
                    execution_window.setVisible(false)
                    execution_window.setBackgroundColor(gui.background or sbg)
                    execution_window.clear();
                    (bef_draw or function() end)(execution_window)
                    local event = update(gui,nil,true,false,nil);
                    (on_event or function() end)(execution_window,event)
                    execution_window.setVisible(true);
                end
            end)
            if not ok then err = erro end
        end)
        log("created graphic routine 1",log.update)
        local mns = fnc or function() end
        local function main()
            local ok,erro = pcall(mns,execution_window)
            if not ok then err = erro end
        end
        log("created custom updater",log.update)
        local graphics_updater = coroutine.create(function()
            while true do
                gui.update(0)
                execution_window.setVisible(true)
                execution_window.setVisible(false)
                if gui.update_delay > 0 then
                    os.queueEvent("_")
                    os.pullEvent("_")
                else sleep(gui.update_delay) end
            end
        end)
        log("created graphic routine 2",log.update)
        local key_handler = coroutine.create(function()
            local name,key,held = os.pullEvent()
            if name == "key" then gui.held_keys[key] = {true,held} end
            if name == "key_up" then gui.held_keys[key] = nil end
        end)
        log("created key handler")
        local func_coro = coroutine.create(main)
        coroutine.resume(func_coro)
        coroutine.resume(gui_coro,"mouse_click",math.huge,-math.huge,-math.huge)
        coroutine.resume(gui_coro,"mouse_click",math.huge,-math.huge,-math.huge)
        coroutine.resume(gui_coro,"mouse_click",math.huge,-math.huge,-math.huge)
        log("")
        log("Started execution..",log.success)
        log("")
        log:dump()
        while (coroutine.status(func_coro) ~= "dead" or not (_G.type(fnc) == "function")) and coroutine.status(gui_coro) ~= "dead" and err == "ok" do
            local event = table.pack(os.pullEventRaw())
            if event[1] == "terminate" then err = "Terminated" break end
            coroutine.resume(func_coro,table.unpack(event,1,event.n))
            if event[1] == "key" or event[1]== "key_up" then
                coroutine.resume(key_handler,table.unpack(event,1,event.n))
            end
            for k,v in pairs(task_routine) do
                if coroutine.status(v) ~= "dead" then
                    coroutine.resume(v,table.unpack(event,1,event.n))
                else
                    task_routine[k] = nil
                    gui.task_schedule[k] = nil
                    log("Finished sheduled task: "..tostring(k),log.sucess)
                end
            end
            coroutine.resume(graphics_updater,table.unpack(event,1,event.n))
            coroutine.resume(gui_coro,table.unpack(event,1,event.n))
        end
        execution_window.setVisible(true)
        if err then log("a Fatal error occured: "..err,log.fatal)
        else log("finished execution",log.success) end
        log:dump()
        return err
    end
    if type == "monitor" then
        log("Display object: monitor",log.info)
        gui.monitor = peripheral.getName(orig)
    else
        log("Display object: term",log.info)
        gui.monitor = "term_object"
    end
    log("")
    log("Starting creator..",log.info)
    gui.create = objects.main(gui,gui.gui,log)
    log("")
    gui.update = updater
    log("loading text object...",log.update)
    log("")
    gui.text = function(data)
        data = data or {}
        if _G.type(data.centered) ~= "boolean" then data.centered = true end
        local fg = (_G.type(data.text) == "string") and ("0"):rep(#data.text) or ("0"):rep(13)
        local bg = (_G.type(data.text) == "string") and ("f"):rep(#data.text) or ("f"):rep(13)
        log("created new text object",log.info)
        return setmetatable({
            text = data.text or "<TEXT OBJECT>",
            centered = data.centered,
            x = data.x or 1,
            y = data.y or 1,
            offset_x = data.offset_x or 0,
            offset_y = data.offset_y or 0,
            blit = data.blit or {fg,bg},
            transparent=data.transparent
        },{
            __call=function(self)
                local term = gui.term_object
                local x,y = 1,1
                local w,h = term.getSize()
                if self.centered then
                    local y = h/2
                    local x = math.ceil((w/2)-(#self.text/2))
                    term.setCursorPos(x+self.offset_x,y+self.offset_y)
                    x,y = x+self.offset_x,y+self.offset_y
                else
                    term.setCursorPos(self.x+self.offset_x,self.y+self.offset_y)
                    x,y = self.x+self.offset_x,self.y+self.offset_y
                end
                if self.transparent == true then
                    local fg,bg = table.unpack(self.blit)
                    local _,_,line = term.getLine(y)
                    local sc_bg = line:sub(x,math.min(x+#self.text-1,w))
                    local diff = #self.text-#sc_bg-1
                    term.blit(self.text,fg,sc_bg..bg:sub(#bg-diff,#bg))
                else
                    term.write(self.text,table.unpack(self.blit))
                end
            end 
        })
    end
    return gui
end

return create_gui_object
