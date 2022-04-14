return {
    create_gui=function(m)
        local create = require("GuiH.a-tools.gui_object")
        local win = window.create(m,1,1,m.getSize())
        local gui = create(win,m)
        return gui
    end,
    load_texture=require("GuiH.texture-wrapper").load_texture,
    convert_event=function(ev_name,e1,e2,e3,id)
        local ev_data = {}
        if ev_name == "monitor_touch" then ev_data = {name=ev_name,monitor=e1,x=e2,y=e3} end
        if ev_name == "mouse_click" or ev_name == "mouse_up" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end
        if ev_name == "mouse_drag" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end
        if ev_name == "mouse_scroll" then ev_data = {name=ev_name,direction=e1,x=e2,y=e3} end
        if ev_name == "key" then ev_data = {name=ev_name,key=e1,held=e2,x=math.huge,y=math.huge} end
        if ev_name =="key_up" then ev_data = {name=ev_name,key=e1,x=math.huge,y=math.huge} end
        if ev_name == "char" then ev_data = {name=ev_name,character=e1,x=math.huge,y=math.huge} end
        if ev_name == "guih_data_event" then ev_data = e1 end
        if not ev_data.monitor then ev_data.monitor = "term_object" end
        return ev_data or {name=ev_name}
    end,
    valid_events={
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
}