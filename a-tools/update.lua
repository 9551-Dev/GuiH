local events = {
    ["mouse_click"]=true,
    ["mouse_drag"]=true,
    ["monitor_touch"]=true,
    ["mouse_scroll"]=true
}
return function(self,wait_for_click,visible)
    if wait_for_click == nil then wait_for_click = true end
    if visible == nil then visible = true end
    local ev_name = "none"
    local ev_data
    local gui = self.gui
    local e1,e2,e3
    if wait_for_click then
        while not events[ev_name] do
            ev_name,e1,e2,e3 = os.pullEvent()
        end
        if ev_name == "monitor_touch" then ev_data = {name=ev_name,monitor=e1,x=e2,y=e3} end
        if ev_name == "mouse_click" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end
        if ev_name == "mouse_drag" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end
        if ev_name == "mouse_scroll" then ev_data = {name=ev_name,direction=e1,x=e2,y=e3} end
        for _k,_v in pairs(gui) do for k,v in pairs(_v) do
            if v.reactive and v.react_to_events[ev_data.name] then
                v.logic(v,ev_data)
            end
        end end
    end
    if visible then
        for _k,_v in pairs(gui) do for k,v in pairs(_v) do
            if v.visible then
                v.graphic(v)
            end
        end end
    end
end