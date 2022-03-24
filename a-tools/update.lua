local events = {
    ["mouse_click"]=true,
    ["mouse_drag"]=true,
    ["monitor_touch"]=true,
    ["mouse_scroll"]=true
}
return function(wait_for_click,visible)
    local ev_name = "none"
    local e1,e2,e3
    local gui = self.gui
    if wait_for_click then
        while not events[ev_name] do
            ev_name,e1,e2,e3 = os.pullEvent()
        end
        for k,v in pairs(self.gui) do v.logic() end
    end
    if visible then
        for k,v in pairs(self.gui) do
            v.graphic()
        end
    end
end