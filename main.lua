return {
    create_gui=require("GuiH.a-tools.gui_object"),
    load_texture=require("GuiH.texture-wrapper").load_texture,
    convert_event=function(ev_name,e1,e2,e3)
        local ev_data = {}
        if ev_name == "monitor_touch" then ev_data = {name=ev_name,monitor=e1,x=e2,y=e3} end
        if ev_name == "mouse_click" or ev_name == "mouse_up" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end
        if ev_name == "mouse_drag" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end
        if ev_name == "mouse_scroll" then ev_data = {name=ev_name,direction=e1,x=e2,y=e3} end
        return ev_data
    end
}