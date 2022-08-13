--[[
    * this file is used for updating
    * graphics and state of gui elements
    * also used for event proccessing
]]

local api = require("util")

--* definitions for events and what they are
local events = {
    ["mouse_click"]=true,
    ["mouse_drag"]=true,
    ["monitor_touch"]=true,
    ["mouse_scroll"]=true,
    ["mouse_up"]=true,
    ["key"]=true,
    ["key_up"]=true,
    ["char"]=true,
    ["guih_data_event"]=true,
    ["paste"]=true
}
local keyboard_events = {
    ["key"]=true,
    ["key_up"]=true,
    ["char"]=true,
    ["paste"]=true
}
local valid_mouse_buttons = {
    [1]=true,
    [2]=true
}
local valid_mouse_event = {
    ["mouse_click"]=true,
    ["mouse_drag"]=true,
    ["mouse_up"]=true,
    ["mouse_scroll"]=true
}
--* end of event definitions

return function(self,timeout,visible,is_child,data_in,block_logic,block_graphic,pixemap,screen_x,screen_y,logic_updaters,graphic_updaters)

    --* set up some variables for use later and for placeholders
    if visible == nil then visible = true end
    local ev_name = "none"
    local ev_data = data_in
    local data = data_in
    local gui = self.gui
    local e1,e2,e3,id
    local frames,layers={},{}
    local updateD = true

    --* if there is a timeout and this isnt a child gui update then continue
    if ((timeout or math.huge) > 0) and not block_logic then
        if not data or not is_child then

            --* pull event until one of events useful for GUIs happens
            while not events[ev_name] do
                ev_name,e1,e2,e3,id = os.pullEvent()
            end

            --* convert the event into a more convinient format
            if ev_name == "monitor_touch" then ev_data = {name=ev_name,monitor=e1,x=e2,y=e3} end
            if ev_name == "mouse_click" or ev_name == "mouse_up" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end
            if ev_name == "mouse_drag" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end
            if ev_name == "mouse_scroll" then ev_data = {name=ev_name,direction=e1,x=e2,y=e3} end
            if ev_name == "key" then ev_data = {name=ev_name,key=e1,held=e2,x=math.huge,y=math.huge} end
            if ev_name == "key_up" then ev_data = {name=ev_name,key=e1,x=math.huge,y=math.huge} end
            if ev_name == "paste" then ev_data = {name=ev_name,text=e1,x=math.huge,y=math.huge} end
            if ev_name == "char" then ev_data = {name=ev_name,character=e1,x=math.huge,y=math.huge} end

            --* guih data event is used to pass events onto child objects
            if ev_name == "guih_data_event" then ev_data = e1 end

            --* if you are using term instead of an monitor then the monitor used by the event
            --* will be set to term_object which is monitor name used by term in
            --* a-tools/gui_object.lua
            if not ev_data.monitor then ev_data.monitor = "term_object" end

            --* trigger GuiH data event with the current event if the event we received was not
            --* created here. to prevent infinte event loops
            --* if we catch an event that was also made here then set updatedD
            --* to false so we dont update the gui with replica event
            if not (e2 ~= self.id and ev_name ~= "guih_data_event") then
                updateD = false
            end
        end

        local update_layers = {}
        local update_functions = {}

        --* if the monitor that we clicked matches the one the gui is set to respond to then we continue
        local touchpixelmap = pixemap or api.tables.createNDarray(1)
        if updateD and ((ev_data.monitor == self.monitor) or keyboard_events[ev_data.name]) then

            --* iterate over all the elements in the gui
            for _k,_v in pairs(gui) do for k,v in pairs(_v) do

                --* if the element is reactive and is set to respond to the current event then continue
                if v.react_to_events[ev_data.name] or not next(v.react_to_events) then

                    --* build a function that updates this element and add it into update_layers
                    --* with its update logic_order or order as a key
                    if not update_layers[v.logic_order or v.order] then update_layers[v.logic_order or v.order] = {} end
                    table.insert(update_layers[v.logic_order or v.order],function()

                        if api.events_with_cords[ev_data.name] and v.blocking then
                            local p = v.positioning
                            if p and p.x and p.y then
                                local w = p.width or 1
                                local h = p.height or 1

                                local was_object_clicked = api.is_within_field(ev_data.x,ev_data.y,p.x,p.y,w,h)

                                if was_object_clicked then
                                    if touchpixelmap[ev_data.x][ev_data.y] and not v.always_update then return end
                                    if _G.type(v.on_focus) == "function" and ev_data.name ~= "mouse_drag" then v.on_focus(v) end
                                    for xy=1,w*h do
                                        touchpixelmap[(xy-1)%w+p.x][math.ceil(xy/w)+p.y-1] = true
                                    end
                                end
                            end
                        end

                        --* if the event is a keyboard based event then straight up
                        --* update the object, but if its nota keyboard based object then
                        --* check if the button clicked matches with v.btn
                        --* which is a LUT of the buttons the object should respond to
                        --* also check if the monitor that this event happened on matches
                        if v.reactive then
                            table.insert(logic_updaters or update_functions,function()
                                if keyboard_events[ev_data.name] then
                                    if v.logic then v.logic(v,ev_data,self) end
                                else
                                    if ((v.btn or valid_mouse_buttons)[ev_data.button]) or ev_data.monitor == self.monitor then
                                        if v.logic then v.logic(v,ev_data,self) end
                                    end
                                end
                            end)
                        end
                    end)
                end
            end end
        end
        --* execute all of the objects functions in the right order using the iterate_order function
        for k,v in api.tables.iterate_order(update_layers,true) do for _k,_v in pairs(v) do _v() end end
        if not logic_updaters then
            for i=#update_functions,1,-1 do
                update_functions[i]()
            end
        end
    end
    local cx,cy = self.term_object.getCursorPos()

    --* if this update is meant to be visible
    if visible and self.visible then
        
        --* iterate over all the elements in the gui
        for _k,_v in pairs(gui) do for k,v in pairs(_v) do

            --* build a function that updates this element and add it into update_layers
            --* with its update logic_order or order as a key
            if not layers[v.graphic_order or v.order] then layers[v.graphic_order or v.order] = {} end
            table.insert(layers[v.graphic_order or v.order],function()

                --* if this object doesnt have any child gui and is set to visible then update it
                --* if it has a child object and is visible then update it and add that child
                --* element to the frames list to be updated reccursively later
                if not (v.gui or v.child) then
                    if v.visible and v.graphic and not block_graphic then v.graphic(v,self) end
                else
                    if v.visible and v.graphic and not block_graphic then
                        v.graphic(v,self);
                        (v.gui or v.child).term_object.redraw()
                    end
                end
            end)
        end end
    end

    --* execute all of the objects functions in the right order using the iterate_order function
    for k,v in api.tables.iterate_order(layers,graphic_updaters) do
        for _k,_v in pairs(v) do
            if graphic_updaters then
                table.insert(graphic_updaters,_v)
            else _v() end
        end
    end

    local child_layers = {}
    for _k,_v in pairs(gui) do for k,v in pairs(_v) do
        if not child_layers[v.graphic_order or v.order] then child_layers[v.graphic_order or v.order] = {} end
        table.insert(child_layers[v.graphic_order or v.order],function()
            if (v.gui or v.child) then
                table.insert(frames,v)
            end
        end)
    end end

    for k,v in api.tables.iterate_order(child_layers,true) do for _k,_v in pairs(v) do _v() end end

    --* if we had caught an replica event then end the update here. else continue
    if not updateD then return ev_data,table.pack(ev_name,e1,e2,e3,id) end

    --* iterate over all the frames so their child guis can be updated
    local child_pixemap = api.tables.createNDarray(1)
    local logupdates,graphupdates = {},{}
    local drawers = {}
    for k,v in ipairs(frames) do

        --* get the childs size and position info
        local x,y = v.window.getPosition()
        local w,h = v.window.getSize()

        --* try to get any event data that could be here
        local data = data or data_in or ev_data
        if data then
            
            --* offset the event data to make the click relative to the window object
            local dat = {
                x = (data.x-x)+1,
                y = (data.y-y)+1,
                name = data.name,
                monitor = data.monitor,
                button = data.button,
                direction = data.direction,
                held=data.held,
                key=data.key,
                character=data.character,
                text=data.text
            }

            --* if the element has an gui (for example group) then clear it with its background color
            if (v.gui or v.child) and (v.gui or v.child).cls then
                (v.gui or v.child).term_object.setBackgroundColor((v.gui or v.child).background);
                (v.gui or v.child).term_object.clear();
            end

            --* if the event has happened within the gui object that update it like normal
            --* else update it with infinite event cordinates so nothing will most likely get triggered
            local reactivity = not v.reactive
            local visibility = not v.visible
            if type(block_logic) == "boolean" then reactivity = block_logic end
            if type(block_graphic) == "boolean" then visibility = block_graphic end
            if api.is_within_field(data.x,data.y,x,y,x+w,y+h) then
                (v.child or v.gui).update(math.huge,v.visible,true,dat,reactivity,visibility,child_pixemap,screen_x or data.x,screen_y or data.y,logupdates,graphupdates)
            else
                dat.x = -math.huge
                dat.y = -math.huge;
                (v.child or v.gui).update(math.huge,v.visible,true,dat,reactivity,visibility,child_pixemap,screen_x or data.x,screen_y or data.y,logupdates,logupdates)
            end
            if (v.gui or v.child) and (v.gui or v.child).cls then
                (v.gui or v.child).term_object.redraw()
            end
        end
    end
    for i=#logupdates,1,-1          do logupdates[i]() end
    for k,v in ipairs(graphupdates) do v() end

    --* restore the cursor position
    return ev_data,table.pack(ev_name,e1,e2,e3,id)
end
