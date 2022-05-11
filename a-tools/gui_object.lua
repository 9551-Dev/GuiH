local objects = require("GuiH.object-loader")
local graphic = require("GuiH.texture-wrapper")
local update = require("GuiH.a-tools.update")
local api = require("GuiH.api")

local function create_gui_object(term_object,orig,log)
    local gui_objects = {}
    local type = "term_object"
    pcall(function()
        type = peripheral.getType(orig)
    end)
    for k,v in pairs(objects.types) do gui_objects[v] = {} end
    local w,h = term_object.getSize()
    local gui = {
        term_object=term_object,
        gui=gui_objects,
        update=update,
        visible=true,
        id=api.uuid4(),
        task_schedule={},
        update_delay=0,
        held_keys={},
        log=log,
        task_routine={},
        w=w,h=h,
        event_listeners={},
        paused_listeners={}
    }
    log("set up updater",log.update)
    local function updater(timeout,visible,is_child,data)
        return update(gui,timeout,visible,is_child,data)
    end
    local err = "ok"
    gui.schedule=function(fnc,t)
        local task_id = api.uuid4()
        log("scheduled task: "..tostring(task_id))
        gui.task_routine[task_id] = coroutine.create(function()
            local ok,erro = pcall(fnc,gui,gui.term_object)
            if not ok then err = erro end
        end)
    end
    gui.add_listener = function(_filter,f,name)
        if not _G.type(f) == "function" then return end
        local id = name or api.uuid4()
        local listener = {filter=_filter,code=f}
        gui.event_listeners[id] = listener
        log("created event listener: "..id,log.success)
        log:dump()
        return setmetatable(listener,{__call={
            kill=function()
                gui.event_listeners[id] = nil
                log("killed event listener: "..id,log.success)
                log:dump()
            end,
            pause=function()
                gui.paused_listeners[id] = listener
                gui.event_listeners[id] = nil
                log("paused event listener: "..id,log.success)
                log:dump()
            end,
            resume=function()
                local listener = gui.paused_listeners[id] or gui.event_listeners[id]
                if listener then
                    gui.event_listeners[id] = listener
                    gui.paused_listeners[id] = nil
                    log("resumed event listener: "..id,log.success)
                    log:dump()
                else
                    log("event listener not found: "..id,log.error)
                    log:dump()
                end
            end
        }})
    end
    gui.isHeld = function(key)
        local info = gui.held_keys[key] or {}
        if info[1] then return true,info[2] end
        return false,false
    end
    gui.execute=function(fnc,on_event,bef_draw,after_draw)
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
                    (on_event or function() end)(execution_window,event);
                    (after_draw or function() end)(execution_window)
                    execution_window.setVisible(true);
                end
            end)
            if not ok then err = erro log:dump() end
        end)
        log("created graphic routine 1",log.update)
        local mns = fnc or function() end
        local function main()
            local ok,erro = pcall(mns,execution_window)
            if not ok then err = erro log:dump() end
        end
        log("created custom updater",log.update)
        local graphics_updater = coroutine.create(function()
            while true do
                execution_window.setVisible(false)
                gui.update(0,true,nil,{type="mouse_click",x=-math.huge,y=-math.huge,button=-math.huge});
                (after_draw or function() end)(execution_window)
                execution_window.setVisible(true)
                execution_window.setVisible(false)
                if gui.update_delay > 0 then
                    os.queueEvent("_")
                    os.pullEvent("_")
                else sleep(gui.update_delay) end
            end
        end)
        log("created event listener handle",log.update)
        local listener_handle = coroutine.create(function()
            local ok,erro = pcall(function()
                while true do
                    local eData = table.pack(os.pullEventRaw())
                    for k,v in pairs(gui.event_listeners) do
                        if v.filter[eData[1]] or v.filter == eData[1] then
                            v.code(table.unpack(eData,2,eData.n))
                        end
                    end
                    os.queueEvent("")
                    os.pullEvent("")
                end
            end)
            if not ok then err = erro log:dump() end
        end)
        log("created graphic routine 2",log.update)
        local key_handler = coroutine.create(function()
            while true do
                local name,key,held = os.pullEvent()
                if name == "key" then gui.held_keys[key] = {true,held} end
                if name == "key_up" then gui.held_keys[key] = nil end
                os.queueEvent("")
                os.pullEvent("")
            end
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
            coroutine.resume(listener_handle,table.unpack(event,1,event.n))
            coroutine.resume(func_coro,table.unpack(event,1,event.n))
            if event[1] == "key" or event[1]== "key_up" then
                coroutine.resume(key_handler,table.unpack(event,1,event.n))
            end
            for k,v in pairs(gui.task_routine) do
                if coroutine.status(v) ~= "dead" then
                    coroutine.resume(v,table.unpack(event,1,event.n))
                else
                    gui.task_routine[k] = nil
                    gui.task_schedule[k] = nil
                    log("Finished sheduled task: "..tostring(k),log.success)
                end
            end
            coroutine.resume(gui_coro,table.unpack(event,1,event.n))
            coroutine.resume(graphics_updater,table.unpack(event,1,event.n))
        end
        execution_window.setVisible(true)
        if err then log("a Fatal error occured: "..err..debug.traceback(),log.fatal)
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
    gui.load_texture = function(data)
        log("Loading nimg texture.. ",log.update)
        local tex = graphic.load_texture(data)
        return tex
    end
    gui.load_ppm_texture = function(data,mode)
        local ok,tex,img = pcall(graphic.load_ppm_texture,gui.term_object,data,mode,log)
        if ok then
            return tex,img
        else
            log("Failed to load texture: "..tex,log.error)
        end
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
        if _G.type(data.centered) ~= "boolean" then data.centered = false end
        local fg = (_G.type(data.text) == "string") and ("0"):rep(#data.text) or ("0"):rep(13)
        local bg = (_G.type(data.text) == "string") and ("f"):rep(#data.text) or ("f"):rep(13)
        if _G.type(data.blit) ~= "table" then data.blit = {fg,bg} end
        data.blit[1] = (data.blit[1] or fg):lower()
        data.blit[2] = (data.blit[2] or bg):lower()
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
            __call=function(self,tobject,x,y,w,h)
                local term = tobject or gui.term_object
                local sval
                if _G.type(x) == "number" and _G.type(y) == "number" then sval = 1 end
                if _G.type(x) ~= "number" then x = 1 end
                if _G.type(y) ~= "number" then y = 1 end
                local xin,yin = x,y
                if self.centered then
                    local y_centered = (h or gui.h)/2
                    local x_centered = math.ceil(((w or gui.w)/2)-(#self.text/2))
                    term.setCursorPos(x_centered+self.offset_x+xin,y_centered+self.offset_y+yin)
                    x,y = x_centered+self.offset_x+xin,y_centered+self.offset_y+yin
                else
                    term.setCursorPos((sval or self.x)+self.offset_x+xin-1,(sval or self.y)+self.offset_y+yin-1)
                    x,y = (sval or self.x)+self.offset_x+xin-1,(sval or self.y)+self.offset_y+yin-1
                end
                if self.transparent == true then
                    local n_val = -1
                    local text = self.text
                    if x < 1 then
                        n_val = math.abs(math.min(x+1,3)-2)
                        term.setCursorPos(1,y)
                        x = 1
                        text = self.text:sub(n_val+1)
                    end
                    local fg,bg = table.unpack(self.blit)
                    local _,_,line = term.getLine(math.floor(y))
                    local sc_bg = line:sub(x,math.min(x+#text-1,gui.w))
                    local diff = #text-#sc_bg-1
                    term.blit(text,fg:sub(n_val+1),sc_bg..bg:sub(#bg-diff,#bg))
                else
                    term.blit(self.text,table.unpack(self.blit))
                end
            end 
        })
    end
    return gui
end

return create_gui_object
