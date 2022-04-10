local objects = require("GuiH.object-loader")
local update = require("GuiH.a-tools.update")

local function create_gui_object(term_object)
    local gui_objects = {}
    local type = "term_object"
    pcall(function()
        type = peripheral.getType(term_object)
    end)
    for k,v in pairs(objects.types) do
        gui_objects[v] = {}
    end
    local w_win = ((term_object == term) and window.create(term.current(),1,1,term.getSize()) or window.create(term_object,1,1,term_object.getSize()))
    local gui = {
        term_object=(term_object == term) and term.current() or term_object,
        w_win=w_win,
        gui=gui_objects,
        update=update,
        visible=true,
        id=os.epoch("utc")
    }
    local function updater(timeout,visible,is_child,data)
        return update(gui,timeout,visible,is_child,data)
    end
    gui.execute=function(fnc,on_event)
        local execution_window = gui.term_object 
        local event
        gui.term_object = execution_window
        local sbg  = execution_window.getBackgroundColor()
        local err = "ok"
        local gui_coro = coroutine.create(function()
            local ok,erro = pcall(function()
                execution_window.setVisible(true)
                updater(0)
                execution_window.redraw()
                while true do
                    execution_window.setVisible(false)
                    execution_window.setBackgroundColor(gui.background or sbg)
                    execution_window.clear()
                    updater();
                    (on_event or function() end)(execution_window,event)
                    execution_window.setVisible(true);
                end
            end)
            if not ok then err = erro end
        end)
        local function main()
            local ok,erro = pcall(fnc or function() end)
            if not ok then err = erro end
        end
        local func_coro = coroutine.create(main)
        coroutine.resume(func_coro)
        coroutine.resume(gui_coro)
        while (coroutine.status(func_coro) ~= "dead" or not (_G.type(fnc) == "function")) and coroutine.status(gui_coro) ~= "dead" do
            local event = table.pack(os.pullEventRaw())
            if event[1] == "terminate" then err = "Terminated" break end
            coroutine.resume(func_coro,table.unpack(event,1,event.n))
            coroutine.resume(gui_coro,table.unpack(event,1,event.n))
        end
        execution_window.setVisible(true)
        return err
    end
    if type == "monitor" then
        gui.monitor = peripheral.getName(term_object)
    else
        gui.monitor = "term_object"
    end
    gui.create = objects.main(gui,gui.gui)
    gui.update = updater
    gui.text = function(data)
        data = data or {}
        if _G.type(data.centered) ~= "boolean" then data.centered = true end
        local fg = (_G.type(data.text) == "string") and ("0"):rep(#data.text) or ("0"):rep(13)
        local bg = (_G.type(data.text) == "string") and ("f"):rep(#data.text) or ("f"):rep(13)
        return setmetatable({
            text = data.text or "<TEXT OBJECT>",
            centered = data.centered,
            x = data.x or 1,
            y = data.y or 1,
            offset_x = data.offset_x or 0,
            offset_y = data.offset_y or 0,
            blit = data.blit or {fg,bg}
        },{
            __call=function(self)
                local term = gui.term_object
                if self.centered then
                    local w,h = term.getSize()
                    local y = h/2
                    local x = math.ceil((w/2)-(#self.text/2))
                    term.setCursorPos(x+self.offset_x,y+self.offset_y)
                else
                    term.setCursorPos(self.x+self.offset_x,self.y+self.offset_y)
                end
                term.blit(self.text,unpack(self.blit))
            end
        })
    end
    return gui
end

return create_gui_object