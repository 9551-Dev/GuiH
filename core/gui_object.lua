--[[
    * this file is used to build the gui object itself
    * when you do gui.new this function gets ran
    * and returns a table with all the needed functions
    * and values for your GUI to function
]]

--* loads the required modules
local objects = require("object_loader")
local graphic = require("graphic_handle")
local update = require("core.update")
local api = require("util")

local function create_gui_object(term_object,orig,log,event_offset_x,event_offset_y)
    local gui_objects = {}
    --* checks if the term object is terminal or an monitor
    --* uses pcall cause peripheral.getType(term) errors
    local type = "term_object"
    local deepest = orig
    local function calibrate(gui_object)
        event_offset_x,event_offset_y = 0,0
        pcall(function()
            local function get_ev_offset(terminal)
                local x,y = terminal.getPosition()
                event_offset_x = event_offset_x + (x-1)
                event_offset_y = event_offset_y + (y-1)
                local _,parent = debug.getupvalue(terminal.reposition,5)
                if parent.reposition and parent ~= term.current() then
                    deepest = parent
                    get_ev_offset(parent)
                elseif parent ~= nil then
                    deepest = parent
                end
            end
            get_ev_offset(term_object)
        end)
        if gui_object then
            gui_object.event_offset_x = event_offset_x
            gui_object.event_offset_y = event_offset_y
        end
    end
    if not event_offset_x or not event_offset_y then
        calibrate()
    end
    pcall(function()
        type = peripheral.getType(deepest)
    end)
    for k,v in pairs(objects.types) do gui_objects[v] = {} end

    --* creates base of the gui object
    local w,h = term_object.getSize()
    local gui = {
        term_object=term_object,
        term=term_object,
        gui=gui_objects,
        update=update,
        visible=true,
        id=api.uuid4(),
        task_schedule={},
        update_delay=0.05,
        held_keys={},
        log=log,
        task_routine={},
        paused_task_routine={},
        w=w,h=h,
        width=w,height=h,
        event_listeners={},
        paused_listeners={},
        background=term_object.getBackgroundColor(),
        cls=false,
        key={},
        texture_cache={},
        debug=false,
        event_offset_x=event_offset_x,
        event_offset_y=event_offset_y,
        dynamic_positions={},
        paused_dynamic_positions={}
    }

    gui.inherit = function(from, group)
        gui.api          = from.api
        gui.preset       = from.preset
        gui.async        = from.async
        gui.schedule     = from.schedule
        gui.add_listener = from.add_listener
        gui.debug        = from.debug
        gui.parent       = group
        gui.dynamic_positions        = from.dynamic_positions
        gui.paused_dynamic_positions = from.paused_dynamic_positions
    end

    gui.disable_logging = function()
        gui.log = setmetatable({dump=function() end},{__call=function() end})
    end

    gui.elements = gui.gui

    gui.calibrate = function()
        calibrate(gui)
    end
    gui.getSize = function()
        return gui.w,gui.h
    end

    local anchors = {
        ["center"]=true,
        ["top_left"]=true,
        ["top_right"]=true,
        ["bottom_left"]=true,
        ["bottom_right"]=true
    }

    gui.create_position = function(x,y,w,h,anchor,offset_x,offset_y,width_offset,height_offset)
        local id = api.uuid4()
        x,y = tostring(x),tostring(y)
        w,h = tostring(w),tostring(h)
        offset_x      = offset_x or 0
        offset_y      = offset_y or 0
        width_offset  = width_offset or 0
        height_offset = height_offset or 0
        anchor = anchors[anchor] and anchor or "center"
        local valuex,isxpercent = x:gsub("%%","")
        local valuey,isypercent = y:gsub("%%","")
        local valuew,iswpercent = w:gsub("%%","")
        local valueh,ishpercent = h:gsub("%%","")
        local positioning = {}
        local function update_position()
            local centered_x   = tonumber(valuex)
            local centered_y   = tonumber(valuey)
            local sized_width  = tonumber(valuew)
            local sized_height = tonumber(valueh)
            if isxpercent > 0 then centered_x   = gui.w*(centered_x/100)   end
            if isypercent > 0 then centered_y   = gui.h*(centered_y/100)   end
            if iswpercent > 0 then sized_width  = gui.w*(sized_width/100)  end
            if ishpercent > 0 then sized_height = gui.h*(sized_height/100) end
            if anchor == "center" then
                if isxpercent > 0 then centered_x = centered_x - sized_width /2 + 1 end
                if isypercent > 0 then centered_y = centered_y - sized_height/2 + 1 end
            elseif anchor == "top_right" then
                if isxpercent > 0 then centered_x = centered_x - sized_width  + 1 end
            elseif anchor == "bottom_left" then
                if isypercent > 0 then centered_y = centered_y - sized_height + 1 end
            elseif anchor == "bottom_right" then
                if isxpercent > 0 then centered_x = centered_x - sized_width  + 1 end
                if isypercent > 0 then centered_y = centered_y - sized_height + 1 end
            end
            positioning.x      = math.floor(centered_x+0.5) + offset_x
            positioning.y      = math.floor(centered_y+0.5) + offset_y
            positioning.width  = sized_width                + width_offset
            positioning.height = sized_height               + height_offset
        end
        update_position()
        if gui.debug then log("Made new dynamic position "..id) end
        gui.dynamic_positions[id] = update_position
        return positioning
    end
    gui.position = gui.create_position

    gui.relative_to = function(object,offset_x,offset_y,w,h,width_offset,height_offset,start_anchor,end_anchor)
        local id = api.uuid4()
        w,h = tostring(w),tostring(h)
        offset_x      = offset_x or 0
        offset_y      = offset_y or 0
        start_anchor  = anchors[start_anchor] and start_anchor or "centered"
        end_anchor    = anchors[end_anchor]   and end_anchor   or "centered"
        width_offset  = width_offset  or 0
        height_offset = height_offset or 0
        local valuew,iswpercent = w:gsub("%%","")
        local valueh,ishpercent = h:gsub("%%","")
        local positioning = {}
        local function update_position()
            local anchored_x = object.positioning.x      or 1
            local anchored_y = object.positioning.y      or 1
            local anchored_w = object.positioning.width  or 1
            local anchored_h = object.positioning.height or 1
            local sized_width  = tonumber(valuew)
            local sized_height = tonumber(valueh)
            if not next(positioning) then positioning = {
                width  = sized_width,
                height = sized_height
            } end
            if iswpercent > 0 then sized_width  = gui.w*(sized_width/100)  end
            if ishpercent > 0 then sized_height = gui.h*(sized_height/100) end
            if start_anchor == "centered" then
                anchored_x = anchored_x + (anchored_w/2) + 0.5
                anchored_y = anchored_y + (anchored_h/2) + 0.5
            elseif start_anchor == "top_right" then
                anchored_x = anchored_x + anchored_w
                anchored_y = anchored_y + 1
            elseif start_anchor == "bottom_left" then
                anchored_x = anchored_x + 1
                anchored_y = anchored_y + anchored_h
            elseif start_anchor == "bottom_right" then
                anchored_x = anchored_x + anchored_w
                anchored_y = anchored_y + anchored_h
            elseif start_anchor == "top_left" then
                anchored_x = anchored_x + 1
                anchored_y = anchored_y + 1
            end
            if end_anchor == "centered" then
                anchored_x = anchored_x - positioning.width/2
                anchored_y = anchored_y - positioning.height/2
            elseif end_anchor == "top_right" then
                anchored_x = anchored_x - positioning.width+0.5
                anchored_y = anchored_y - 0.5
            elseif end_anchor == "bottom_left" then
                anchored_x = anchored_x - 0.5
                anchored_y = anchored_y - positioning.height+0.5
            elseif end_anchor == "bottom_right" then
                anchored_x = anchored_x - positioning.width+0.5
                anchored_y = anchored_y - positioning.height+0.5
            elseif end_anchor == "top_left" then
                anchored_x = anchored_x - 0.5
                anchored_y = anchored_y - 0.5
            end

            positioning.x      = math.floor(anchored_x-0.5) + offset_x
            positioning.y      = math.floor(anchored_y-0.5) + offset_y
            positioning.width  = sized_width                + width_offset
            positioning.height = sized_height               + height_offset
        end
        update_position()
        if gui.debug then log("Made new relative position "..id) end
        gui.dynamic_positions[id] = update_position

        return positioning
    end

    log("set up updater",log.update)

    --* attaches a-tools/update.lua to the gui object
    --* that function is used for low level updating
    local function updater(timeout,visible,is_child,data,block_logic,block_graphic,pixemap,screen_x,screen_y,logic_updaters,graphic_updaters)
        return update(gui,timeout,visible,is_child,data,block_logic,block_graphic,pixemap,screen_x,screen_y,logic_updaters,graphic_updaters)
    end

    local err
    local running = false

    --* a function used for adding new things to
    --* the gui objects task queue
    gui.schedule=function(fnc,t,errflag,debug)
        local task_id = api.uuid4()
        if debug or gui.debug then log("created new thread: "..tostring(task_id), log.info) end
        local errupvalue = {}
        local routine = {c=coroutine.create(function()
            --* wraps function into pcall to catch errors
            local ok,erro = pcall(function()
                if t then api.precise_sleep(t) end
                fnc(gui,gui.term_object)
            end)
            if not ok then
                if errflag == true then err = erro end
                errupvalue.err = erro
                if debug or gui.debug then
                    log("error in thread: "..tostring(task_id).."\n"..tostring(erro),log.error)
                    log:dump()
                end
            end
        end),dbug=debug}
        gui.task_routine[task_id] = routine
        local function step(...)
            local task = gui.task_routine[task_id] or gui.paused_task_routine[task_id]
            if task then
                local ok,err = coroutine.resume(task.c,...)
                if not ok then
                    errupvalue.err = err
                    if debug or gui.debug then
                        log("task "..tostring(task_id).." error: "..tostring(err),log.error)
                        log:dump()
                    end
                end
                return true,ok,err
            else
                if debug or gui.debug then
                    log("task "..tostring(task_id).." not found",log.error)
                    log:dump()
                end
                return false
            end
        end
        return setmetatable(routine,{__index={
            kill=function()
                gui.task_routine[task_id] = nil
                gui.paused_task_routine[task_id] = nil
                if debug or gui.debug then
                    log("killed task: "..tostring(task_id), log.info)
                    log:dump()
                end
                return true
            end,
            alive=function()
                local task = gui.task_routine[task_id] or gui.paused_task_routine[task_id]
                if not task then return false end
                return coroutine.status(task.c) ~= "dead"
            end,
            step=step,
            update=step,
            pause=function()
                local task = gui.task_routine[task_id] or gui.paused_task_routine[task_id]
                if task then
                    gui.paused_task_routine[task_id] = task
                    gui.task_routine[task_id] = nil
                    if debug or gui.debug then
                        log("paused task: "..tostring(task_id), log.info)
                        log:dump()
                    end
                    return true
                else
                    if debug or gui.debug then
                        log("task "..tostring(task_id).." not found",log.error)
                        log:dump()
                    end
                    return false
                end
            end,
            resume=function()
                local task = gui.paused_task_routine[task_id] or gui.task_routine[task_id]
                if task then
                    gui.task_routine[task_id] = task
                    gui.paused_task_routine[task_id] = nil
                    if debug or gui.debug then
                        log("resumed task: "..tostring(task_id), log.info)
                        log:dump()
                    end
                    return true
                else
                    if debug or gui.debug then
                        log("task "..tostring(task_id).." not found",log.error)
                        log:dump()
                    end
                    return false
                end
            end,
            get_error=function()
                return errupvalue.err
            end,
            set_running=function(bool,debug)
                local task = gui.task_routine[task_id] or gui.paused_task_routine[task_id]
                local running = gui.task_routine[task_id] ~= nil
                if task then
                    if running and bool then return true end
                    if not running and not bool then return true end
                    if running and not bool then
                        gui.paused_task_routine[task_id] = task
                        gui.task_routine[task_id] = nil
                        if debug or gui.debug then
                            log("paused task: "..tostring(task_id), log.info)
                            log:dump()
                        end
                        return true
                    end
                    if not running and bool then
                        gui.task_routine[task_id] = task
                        gui.paused_task_routine[task_id] = nil
                        if debug or gui.debug then
                            log("resumed task: "..tostring(task_id), log.info)
                            log:dump()
                        end
                        return true
                    end
                end
            end
        },__tostring=function()
            return "GuiH.SCHEDULED_THREAD."..task_id
        end})
    end

    gui.async = gui.schedule

    --* used for creation of new event listeners
    gui.add_listener = function(_filter,f,name,debug,on_finish)
        if not _G.type(f) == "function" then return end

        --* if no event filter is present use an empty one
        if not (_G.type(_filter) == "table" or _G.type(_filter) == "string") then _filter = {} end
        local id = name or api.uuid4()
        local listener = {filter=_filter,code=f,finish=on_finish}
        gui.event_listeners[id] = listener
        if debug or gui.debug then
            log("created event listener: "..id,log.success)
            log:dump()
        end
        return setmetatable(listener,{__index={
            kill=function()
                --* removes the listener from the gui object
                gui.event_listeners[id] = nil
                gui.paused_listeners[id] = nil
                if debug or gui.debug then
                    log("killed event listener: "..id,log.success)
                    log:dump()
                end
            end,
            pause=function()
                --* pauses the listener by moving it out of gui.event_listeners
                gui.paused_listeners[id] = listener
                gui.event_listeners[id] = nil
                if debug or gui.debug then
                    log("paused event listener: "..id,log.success)
                    log:dump()
                end
            end,
            resume=function()
                --* resumes the listener by moving it back into gui.event_listeners
                local listener = gui.paused_listeners[id] or gui.event_listeners[id]
                if listener then
                    gui.event_listeners[id] = listener
                    gui.paused_listeners[id] = nil
                    if debug or gui.debug then
                        log("resumed event listener: "..id,log.success)
                        log:dump()
                    end
                elseif debug or gui.debug then
                    log("event listener not found: "..id,log.error)
                    log:dump()
                end
            end
        },__tostring=function()
            --* used for custom listener object naming
            return "GuiH.EVENT_LISTENER."..id
        end})
    end

    gui.cause_exeption = function(e)
        err = tostring(e)
    end

    gui.stop = function()
        running = false
    end

    gui.kill = gui.stop
    gui.error = gui.cause_exeption

    --* a function used for clearing the gui
    gui.clear = function(debug)
        if debug or gui.debug then
            log("clearing the gui..",log.update)
        end
        local empty = {}
        for k,v in pairs(objects.types) do empty[v] = {} end
        gui.gui = empty
        gui.elements = empty
        local creators = objects.main(gui,empty,log)
        gui.create = creators
        gui.new = creators
    end

    --* used for checking if any keys are currently being held
    --* by reading gui.held_keys
    gui.isHeld = function(...)
        local k_list = {...}
        local out1,out2 = true,true
        for k,key in pairs(k_list) do
            local info = gui.held_keys[key] or {}
            if info[1] then
                out1 = out1 and true
                out2 = out2 and info[2]
            else
                return false,false,gui.held_keys
            end
        end
        return out1,out2,gui.held_keys
    end
    gui.key.held = gui.isHeld

    --* used for running the actuall gui. handles graphics buffering
    --* event handling,key handling,multitasking and updating the gui
    gui.execute=setmetatable({},{__call=function(_,fnc,on_event,bef_draw,after_draw)
        if running then log("Coulnt execute. Gui is already running",log.error) log:dump() return false end
        err = nil
        running = true
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

                    --* clean the window
                    execution_window.setBackgroundColor(gui.background or sbg)
                    execution_window.clear();

                    --* redraw the gui
                    (bef_draw or function() end)(execution_window)
                    local event = update(gui,nil,true,false,nil);
                    (on_event or function() end)(execution_window,event);
                    (after_draw or function() end)(execution_window)
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
                
                execution_window.setBackgroundColor(gui.background or sbg)
                execution_window.clear();
                
                gui.update(0,true,nil,{type="mouse_click",x=-math.huge,y=-math.huge,button=-math.huge});
                (after_draw or function() end)(execution_window)
                
                --* unfreeze and freeze again for the updates to show up
                execution_window.setVisible(true)
                execution_window.setVisible(false)

                sleep(math.max(gui.update_delay,0.05))
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
                    local listeners = {}
                    for k,v in pairs(gui.event_listeners) do
                        local filter = v.filter
                        if _G.type(filter) == "string" then filter = {[v.filter]=true} end
                        if filter[eData[1]] or filter == eData[1] or (not next(filter)) then
                            v.code(table.unpack(eData,_G.type(v.filter) ~= "table" and 2 or 1,eData.n))
                            table.insert(listeners,v.finish)
                        end
                    end
                    for k,v in pairs(listeners) do v() end
                end
            end)
            if not ok then err = erro log:dump() end
        end)
        log("created graphic routine 2",log.update)

        local position_updater = coroutine.create(function()
            while true do
                for k,v in pairs(gui.dynamic_positions) do
                    v()
                end
                sleep(math.max(gui.update_delay,0.05))
            end
        end)
        log("Created position updater",log.update)

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
        coroutine.resume(graphics_updater)
        coroutine.resume(position_updater)
        log("")
        log("Started execution..",log.success)
        log("")
        log:dump()

        --* loops until either the gui or your custom function dies
        while ((coroutine.status(func_coro) ~= "dead" or not (_G.type(fnc) == "function")) and coroutine.status(gui_coro) ~= "dead" and err == nil) and running do
            local event = table.pack(os.pullEventRaw())
            if api.events_with_cords[event[1]] then
                event[3] = event[3] - (gui.event_offset_x)
                event[4] = event[4] - (gui.event_offset_y)
            end

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
            if event[1] == "key" or event[1] == "key_up" then
                coroutine.resume(key_handler,table.unpack(event,1,event.n))
            end

            --* executes schedules  tasks
            for k,v in pairs(gui.task_routine) do
                if coroutine.status(v.c) ~= "dead" then
                    if v.filter == event[1] or v.filter == nil then
                        local ok,filter = coroutine.resume(v.c,table.unpack(event,1,event.n))
                        if ok then v.filter = filter end
                    end
                else
                    --* if the task is dead then remove it
                    gui.task_routine[k] = nil
                    gui.task_schedule[k] = nil
                    if v.dbug then log("Finished sheduled task: "..tostring(k),log.success) end
                end
            end

            --* updates the GUI
            coroutine.resume(position_updater,table.unpack(event,1,event.n))
            coroutine.resume(gui_coro,table.unpack(event,1,event.n))
            coroutine.resume(graphics_updater,table.unpack(event,1,event.n))

            --* handling for window rescaling
            local w,h = orig.getSize()
            if w ~= gui.w or h ~= gui.h then
                if (event[1] == "monitor_resize" and gui.monitor == event[2]) or gui.monitor == "term_object" then
                    gui.term_object.reposition(1,1,w,h)
                    gui.w,gui.h = w,h
                    gui.width,gui.height = w,h
                    coroutine.resume(gui_coro,"mouse_click",math.huge,-math.huge,-math.huge)
                end
            end
        end
        if err then gui.last_err = err end
        --* makes sure the window is visible when execution ends
        execution_window.setVisible(true)
        if err then log("a Fatal error occured: "..err.." "..debug.traceback(),log.fatal)
        else log("finished execution",log.success) end
        log:dump()
        err = nil
        --* returns the reason for the stop in execution
        return gui.last_err,true
    end,__tostring=function() return "GuiH.main_gui_executor" end})

    gui.run = gui.execute

    --* if the term object happens to be an monitor then get its name
    if type == "monitor" then
        log("Display object: monitor",log.info)
        gui.monitor = peripheral.getName(deepest)
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
    gui.load_cimg_texture = function(file_data)
        log("Loading cimg texture.. ",log.update)
        local tex = graphic.load_cimg_texture(file_data)
        return tex
    end
    gui.load_blbfor_texture = function(file_data)
        log("Loading blbfor texture.. ",log.update)
        local tex,anim = graphic.load_blbfor_texture(file_data)
        return tex,anim
    end
    gui.load_limg_texture = function(file_data,bg,image)
        log("Loading limg texture.. ",log.update)
        local tex,anim = graphic.load_limg_texture(file_data,bg,image)
        return tex,anim
    end
    gui.load_limg_animation = function(file_data,bg)
        log("Loading limg animation.. ",log.update)
        local textures = graphic.load_limg_animation(file_data,bg)
        return textures
    end
    gui.load_blbfor_animation = function(file_data)
        log("Loading blbfor animation.. ",log.update)
        local textures = graphic.load_blbfor_animation(file_data)
        return textures
    end

    gui.set_event_offset = function(x,y)
        gui.event_offset_x,gui.event_offset_y = x or gui.event_offset_x,y or gui.event_offset_y
    end
    
    log("")
    log("Starting creator..",log.info)
    local creators = objects.main(gui,gui.gui,log)
    gui.create = creators
    gui.new = creators
    log("")
    gui.update = updater
    log("loading text object...",log.update)
    log("")

    gui.get_blit = function(y,sx,ex)
        local line
        pcall(function()
            line = {gui.term_object.getLine(y)}
        end)
        if not line then return false end
        return line[1]:sub(sx,ex),
            line[2]:sub(sx,ex),
            line[3]:sub(sx,ex)
    end

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

        if gui.debug then log("created new text object",log.info) end
        return setmetatable({
            text = data.text or "<TEXT OBJECT>",
            centered = data.centered,
            x = data.x or 1,
            y = data.y or 1,
            offset_x = data.offset_x or 0,
            offset_y = data.offset_y or 0,
            blit = data.blit or {fg,bg},
            transparent=data.transparent,
            bg=data.bg,
            fg=data.fg,
            width=data.width,
            height=data.height
        },{
            __call=function(self,tobject,x,y,w,h)
                x,y = x or self.x,y or self.y
                if self.width then w = self.width end
                if self.height then h = self.height end
                local term = tobject or gui.term_object
                local sval
                if _G.type(x) == "number" and _G.type(y) == "number" then sval = 1 end
                if _G.type(x) ~= "number" then x = 1 end
                if _G.type(y) ~= "number" then y = 1 end
                local xin,yin = x,y
                local strings = {}
                for c in self.text:gmatch("[^\n]+") do table.insert(strings,c) end
                if self.centered then yin = yin - #strings/2
                else yin = yin - 1 end
                for i=1,#strings do
                    local text = strings[i]
                    yin = yin + 1
                    if self.centered then
                        --* calcualte the center text position
                        local y_centered = (h or gui.h)/2-0.5
                        local x_centered = math.ceil(((w or gui.w)/2)-(#text/2)-0.5)
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
                        if x < 1 then
                            n_val = math.abs(math.min(x+1,3)-2)
                            term.setCursorPos(1,y)
                            x = 1
                            text = text:sub(n_val+1)
                        end
                        
                        --* get he provided blit data
                        local fg,bg = table.unpack(self.blit)
                        if self.bg then bg = graphic.code.to_blit[self.bg]:rep(#text) end
                        if self.fg then fg = graphic.code.to_blit[self.fg]:rep(#text) end

                        --* get the blit data on the line the text is on
                        local line
                        pcall(function()
                            _,_,line = term.getLine(math.floor(y))
                        end)
                        if not line then return end
                        --* calculate the blit under the text from its position
                        --* and data from that line
                        local sc_bg = line:sub(x,math.min(x+#text-1,gui.w))

                        --* see if that data from the line is enough
                        --* if not data from text.blit will get added on draw
                        local diff = #text-#sc_bg-1

                        --* draw the final text subed by b_val in case
                        --* its off the screen to the left
                        if #fg ~= #text then fg = ("0"):rep(#text) end
                        pcall(term.blit,text,fg:sub(math.min(x,1)),sc_bg..bg:sub(#bg-diff,#bg))
                    else
                        --* draw text with provided blit
                        local fg,bg = table.unpack(self.blit)
                        if self.bg then bg = graphic.code.to_blit[self.bg]:rep(#text) end
                        if self.fg then fg = graphic.code.to_blit[self.fg]:rep(#text) end
                        if #fg ~= #text then fg = ("0"):rep(#text) end
                        if #bg ~= #text then bg = ("f"):rep(#text) end
                        pcall(term.blit,text,fg,bg)
                    end
                end
            end,
            __tostring=function() return "GuiH.primitive.text" end
        })
    end
    return gui
end

return create_gui_object
