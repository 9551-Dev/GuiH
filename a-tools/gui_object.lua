--[[
    * this file is used to build the gui object itself
    * when you do gui.new this function gets ran
    * and returns a table with all the needed functions
    * and values for your GUI to function
]]

--* loads the required modules
local objects = require("GuiH.object-loader")
local graphic = require("GuiH.texture-wrapper")
local update = require("GuiH.a-tools.update")
local api = require("GuiH.api")

local function create_gui_object(term_object,orig,log)
    local gui_objects = {}
    --* checks if the term object is terminal or an monitor
    --* uses pcall cause peripheral.getType(term) errors
    local type = "term_object"
    pcall(function()
        type = peripheral.getType(orig)
    end)

    for k,v in pairs(objects.types) do gui_objects[v] = {} end

    --* creates base of the gui object
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
        paused_listeners={},
        background=term_object.getBackgroundColor()
    }
    log("set up updater",log.update)

    --* attaches a-tools/update.lua to the gui object
    --* that function is used for low level updating
    local function updater(timeout,visible,is_child,data)
        return update(gui,timeout,visible,is_child,data)
    end
    local err = "ok"

    --* a function used for adding new things to
    --* the gui objects task queue
    gui.schedule=function(fnc,t)
        local task_id = api.uuid4()
        log("scheduled task: "..tostring(task_id))
        gui.task_routine[task_id] = coroutine.create(function()
            --* wraps function into pcall to catch errors
            local ok,erro = pcall(fnc,gui,gui.term_object)
            if not ok then err = erro end
        end)
    end

    --* used for creation of new event listeners
    gui.add_listener = function(_filter,f,name)
        if not _G.type(f) == "function" then return end

        --* if no event filter is present use an empty one
        if not (_G.type(_filter) == "table" or _G.type(_filter) == "string") then _filter = {} end
        local id = name or api.uuid4()
        local listener = {filter=_filter,code=f}
        gui.event_listeners[id] = listener
        log("created event listener: "..id,log.success)
        log:dump()
        return setmetatable(listener,{__index={
            kill=function()
                --* removes the listener from the gui object
                gui.event_listeners[id] = nil
                log("killed event listener: "..id,log.success)
                log:dump()
            end,
            pause=function()
                --* pauses the listener by moving it out of gui.event_listeners
                gui.paused_listeners[id] = listener
                gui.event_listeners[id] = nil
                log("paused event listener: "..id,log.success)
                log:dump()
            end,
            resume=function()
                --* resumes the listener by moving it back into gui.event_listeners
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
        },__tostring=function()
            --* used for custom listener object naming
            return "GuiH.EVENT_LISTENER."..id
        end})
    end

    --* used for checking if any keys are currently held
    --* by reading gui.held_keys
    gui.isHeld = function(key)
        local info = gui.held_keys[key] or {}
        if info[1] then return true,info[2] end
        
        --* if the key is not held return false
        return false,false
    end

    --* used for running the actuall gui. handles graphics buffering
    --* event handling,key handling,multitasking and updating the gui
    gui.execute=function(fnc,on_event,bef_draw,after_draw)
        log("")
        log("loading execute..",log.update)
        local execution_window = gui.term_object
        local event
        local sbg  = execution_window.getBackgroundColor()

        --* this coroutine is used for udating the gui when an event happens
        local gui_coro = coroutine.create(function()
            local ok,erro = pcall(function()
                execution_window.setVisible(true)

                --* draw the GUI
                updater(0)
                execution_window.redraw()

                while true do
                    --* stop window updates
                    execution_window.setVisible(false)

                    --* clean the window
                    execution_window.setBackgroundColor(gui.background or sbg)
                    execution_window.clear();

                    --* rewdraw the gui
                    (bef_draw or function() end)(execution_window)
                    local event = update(gui,nil,true,false,nil);
                    (on_event or function() end)(execution_window,event);
                    (after_draw or function() end)(execution_window)

                    --* unfreeze
                    execution_window.setVisible(true);
                end
            end)
            if not ok then err = erro log:dump() end
        end)

        log("created graphic routine 1",log.update)
        local mns = fnc or function() end

        --* this coroutine is running custom code.
        local function main()
            local ok,erro = pcall(mns,execution_window)
            if not ok then err = erro log:dump() end
        end

        log("created custom updater",log.update)

        --* this coroutine updates the GUI's graphic side
        --* wihnout the need for an event. makes gui update live with
        --* no interaction
        local graphics_updater = coroutine.create(function()
            while true do

                --* freeeze the Gui and update its graphics side
                execution_window.setVisible(false)
                gui.update(0,true,nil,{type="mouse_click",x=-math.huge,y=-math.huge,button=-math.huge});
                (after_draw or function() end)(execution_window)
                
                --* unfreeze and freeze again for the updates to show up
                execution_window.setVisible(true)
                execution_window.setVisible(false)

                if gui.update_delay > 0 then
                    os.queueEvent("_")
                    os.pullEvent("_")
                else sleep(gui.update_delay) end
            end
        end)

        log("created event listener handle",log.update)
        --* used for updating event listeners
        local listener_handle = coroutine.create(function()
            local ok,erro = pcall(function()
                while true do
                    local eData = table.pack(os.pullEventRaw())
                    --* iterates ever listeners with said event
                    --* and if the event matches the filter or there is no filter
                    --* runs the code asigned to the listener
                    for k,v in pairs(gui.event_listeners) do
                        if v.filter[eData[1]] or v.filter == eData[1] or (not next(v.filter)) then
                            v.code(table.unpack(eData,_G.type(v.filter) ~= "table" and 2 or 1,eData.n))
                        end
                    end
                end
            end)
            if not ok then err = erro log:dump() end
        end)
        log("created graphic routine 2",log.update)

        --* this coroutine is used for handling key presses
        --* and adding/removing keys from gui.held_keys
        --* used by the isHeld function
        local key_handler = coroutine.create(function()
            while true do
                local name,key,held = os.pullEvent()
                if name == "key" then gui.held_keys[key] = {true,held} end
                if name == "key_up" then gui.held_keys[key] = nil end
            end
        end)
        log("created key handler")

        --* builds the custom code coroutine
        local func_coro = coroutine.create(main)

        --* starts up the GUI
        coroutine.resume(func_coro)
        coroutine.resume(gui_coro,"mouse_click",math.huge,-math.huge,-math.huge)
        coroutine.resume(gui_coro,"mouse_click",math.huge,-math.huge,-math.huge)
        coroutine.resume(gui_coro,"mouse_click",math.huge,-math.huge,-math.huge)
        log("")
        log("Started execution..",log.success)
        log("")
        log:dump()

        --* loops until either the gui or your custom function dies
        while (coroutine.status(func_coro) ~= "dead" or not (_G.type(fnc) == "function")) and coroutine.status(gui_coro) ~= "dead" and err == "ok" do
            local event = table.pack(os.pullEventRaw())

            --* manual termination handling
            if event[1] == "terminate" then err = "Terminated" break end

            --* if the event hasnt been triggered by GuiH (guih_data_event) then
            --* update the event listener coroutine
            if event[1] ~= "guih_data_event" then
                coroutine.resume(listener_handle,table.unpack(event,1,event.n))
            end

            --* runs your custom code
            coroutine.resume(func_coro,table.unpack(event,1,event.n))

            --* if the happening event is a keyboard based event then
            --* update held keys
            if event[1] == "key" or event[1]== "key_up" then
                coroutine.resume(key_handler,table.unpack(event,1,event.n))
            end

            --* executes schedules  tasks
            for k,v in pairs(gui.task_routine) do
                if coroutine.status(v) ~= "dead" then
                    coroutine.resume(v,table.unpack(event,1,event.n))
                else
                    --* if the task is dead then remove it
                    gui.task_routine[k] = nil
                    gui.task_schedule[k] = nil
                    log("Finished sheduled task: "..tostring(k),log.success)
                end
            end

            --* updates the GUI
            coroutine.resume(gui_coro,table.unpack(event,1,event.n))
            coroutine.resume(graphics_updater,table.unpack(event,1,event.n))
        end

        --* makes sure the window is visible when execution ends
        execution_window.setVisible(true)
        if err then log("a Fatal error occured: "..err..debug.traceback(),log.fatal)
        else log("finished execution",log.success) end
        log:dump()

        --* returns the reason for the stop in execution
        return err
    end

    --* if the term object happens to be an monitor then get its name
    if type == "monitor" then
        log("Display object: monitor",log.info)
        gui.monitor = peripheral.getName(orig)
    else
        log("Display object: term",log.info)
        gui.monitor = "term_object"
    end

    --* wrap the .nimg texture loader
    gui.load_texture = function(data)
        log("Loading nimg texture.. ",log.update)
        local tex = graphic.load_texture(data)
        return tex
    end

    --* wrap the .ppm texture loader so you dont have to
    --* provide log and term object
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

        --* makes text not be centered by default
        if _G.type(data.centered) ~= "boolean" then data.centered = false end

        --* if no color data is provided make it 13 long blit for <TEXT OBJECT> name
        local fg = (_G.type(data.text) == "string") and ("0"):rep(#data.text) or ("0"):rep(13)
        local bg = (_G.type(data.text) == "string") and ("f"):rep(#data.text) or ("f"):rep(13)
        if _G.type(data.blit) ~= "table" then data.blit = {fg,bg} end

        --* lower blit for maniacs who use caps blit
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
                    --* calcualte the center text position
                    local y_centered = (h or gui.h)/2
                    local x_centered = math.ceil(((w or gui.w)/2)-(#self.text/2))
                    term.setCursorPos(x_centered+self.offset_x+xin,y_centered+self.offset_y+yin)
                    x,y = x_centered+self.offset_x+xin,y_centered+self.offset_y+yin
                else
                    --* calculate the offset text position
                    term.setCursorPos((sval or self.x)+self.offset_x+xin-1,(sval or self.y)+self.offset_y+yin-1)
                    x,y = (sval or self.x)+self.offset_x+xin-1,(sval or self.y)+self.offset_y+yin-1
                end
                if self.transparent == true then

                    --* if the text is of the screen to the left cut it
                    --* at the spot where it leaves the screen
                    --* also move its cursor pos all the way to the left
                    local n_val = -1
                    local text = self.text
                    if x < 1 then
                        n_val = math.abs(math.min(x+1,3)-2)
                        term.setCursorPos(1,y)
                        x = 1
                        text = self.text:sub(n_val+1)
                    end
                    
                    --* get he provided blit data
                    local fg,bg = table.unpack(self.blit)

                    --* get the blit data on the line the text is on
                    local _,_,line = term.getLine(math.floor(y))

                    --* calculate the blit under the text from its position
                    --* and data from that line
                    local sc_bg = line:sub(x,math.min(x+#text-1,gui.w))

                    --* see if that data from the line is enough
                    --* if not dataa from text.blit will get added on draw
                    local diff = #text-#sc_bg-1

                    --* draw the final text subed by b_val in case
                    --* its off the screen to the left
                    term.blit(text,fg:sub(n_val+1),sc_bg..bg:sub(#bg-diff,#bg))
                else
                    --* draw text with provided blit
                    term.blit(self.text,table.unpack(self.blit))
                end
            end 
        })
    end
    return gui
end

return create_gui_object
