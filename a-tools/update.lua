local events = {
    ["mouse_click"]=true,
    ["mouse_drag"]=true,
    ["monitor_touch"]=true,
    ["mouse_scroll"]=true,
    ["mouse_up"]=true,
    ["guih_data_event"]=true
}
local valid_mouse_events = {
    [1]=true,
    [2]=true
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
            if ev_name == "guih_data_event" then ev_data = e1 end
            if e2 ~= self.id and ev_name ~= "guih_data_event" then
                os.queueEvent("guih_data_event",ev_data,self.id)
            else
                return timeout,visible,is_child,data
            end
        end
        for _k,_v in pairs(gui) do for k,v in pairs(_v) do
            if v.reactive and v.react_to_events[ev_data.name] and (v.btn or valid_mouse_events)[ev_data.button] then
                v.logic(v,ev_data,self)
            end
        end end
    end
    if visible and self.visible then
        for _k,_v in pairs(gui) do for k,v in pairs(_v) do
            if not layers[v.order] then layers[v.order] = {} end
            table.insert(layers[v.order],function()
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
    for k,v in api.tables.iterate_order(layers) do
        parallel.waitForAll(table.unpack(v))
    end
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
                direction = data.direction
            }
            v.child.update(0,visible,true,dat)
        end
    end
    return timeout,visible,is_child,data
end