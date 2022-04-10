local events = {
    ["mouse_click"]=true,
    ["mouse_drag"]=true,
    ["monitor_touch"]=true,
    ["mouse_scroll"]=true,
    ["mouse_up"]=true,
    ["key"]=true,
    ["key_up"]=true,
    ["char"]=true,
    ["guih_data_event"]=true
}
local keyboard_events = {
    ["key"]=true,
    ["key_up"]=true,
    ["char"]=true
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
local api = require("GuiH.api")
return function(self,timeout,visible,is_child,data_in)
    if visible == nil then visible = true end
    local ev_name = "none"
    local ev_data = data_in
    local data = data_in
    local gui = self.gui
    local e1,e2,e3,id
    local frames,layers={},{}
    local updateD = true
    if (timeout or math.huge) >= 0 then
        if not data or not is_child then
            local tid = os.startTimer(timeout or 0)
            if timeout == 0 then os.queueEvent("mouse_click",math.huge,-math.huge,-math.huge) end
            while not events[ev_name] or (ev_name == "timer" and e1 == tid) do
                ev_name,e1,e2,e3,id = os.pullEvent()
            end
            if ev_name == "monitor_touch" then ev_data = {name=ev_name,monitor=e1,x=e2,y=e3} end
            if ev_name == "mouse_click" or ev_name == "mouse_up" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end
            if ev_name == "mouse_drag" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end
            if ev_name == "mouse_scroll" then ev_data = {name=ev_name,direction=e1,x=e2,y=e3} end
            if ev_name == "key" then ev_data = {name=ev_name,key=e1,held=e2,x=math.huge,y=math.huge} end
            if ev_name =="key_up" then ev_data = {name=ev_name,key=e1,x=math.huge,y=math.huge} end
            if ev_name == "char" then ev_data = {name=ev_name,character=e1,x=math.huge,y=math.huge} end
            if ev_name == "guih_data_event" then ev_data = e1 end
            if not ev_data.monitor then ev_data.monitor = "term_object" end
            if e2 ~= self.id and ev_name ~= "guih_data_event" then
                os.queueEvent("guih_data_event",ev_data,self.id)
            else
                updateD = false
            end
        end
        local update_layers = {}
        if updateD and ev_data.monitor == self.monitor then
            for _k,_v in pairs(gui) do for k,v in pairs(_v) do
                if v.reactive and v.react_to_events[ev_data.name] then
                    if not update_layers[v.order] then update_layers[v.order] = {} end
                    table.insert(update_layers[v.logic_order or v.order],function()
                        if keyboard_events[ev_data.name] then
                            v.logic(v,ev_data,self)
                        else
                            if (v.btn or valid_mouse_buttons)[ev_data.button] then
                                v.logic(v,ev_data,self)
                            end
                        end
                    end)
                end
            end end
        end
        for k,v in api.tables.iterate_order(update_layers) do parallel.waitForAll(unpack(v)) end
    end
    if visible and self.visible then
        for _k,_v in pairs(gui) do for k,v in pairs(_v) do
            if not layers[v.order] then layers[v.order] = {} end
            table.insert(layers[v.graphic_order or v.order],function()
                if _k ~= "frame" then
                    if v.visible then v.graphic(v,self) end
                else
                    if v.visible then v.graphic(v,self) end
                    v.window.redraw()
                    table.insert(frames,v)
                end
            end)
        end end
    end
    for k,v in api.tables.iterate_order(layers) do parallel.waitForAll(unpack(v)) end
    if not updateD then return ev_data,table.pack(ev_name,e1,e2,e3,id) end
    for k,v in pairs(frames) do
        local x,y = v.window.getPosition()
        local data = data or data_in or ev_data
        if data then
            local dat = {
                x = (data.x-x)+1,
                y = (data.y-y)+1,
                name = data.name,
                monitor = data.monitor,
                button = data.button,
                direction = data.direction,
                held=data.held,
                key=data.key,
                character=data.character
            }
            v.child.update(0,v.visible,true,dat)
        end
    end
    return ev_data,table.pack(ev_name,e1,e2,e3,id)
end