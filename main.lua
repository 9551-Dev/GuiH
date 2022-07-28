--[[
    * this file is used to provide you with the main few main functions that
    * and load all the nessesary presets and modules, also sets up log
]]

local logger = require("core.logger")

--* gets this files path so it can be later used in package.path
local path = fs.getDir(select(2,...))

local log = logger.create_log()

--* puts the internal apis into the apis table cause they may be useful
local apis = {
    algo=require("core.algo"),
    luappm=require("core.luappm"),
    blbfor=require("core.blbfor"),
    graphic=require("graphic_handle").code,
    general=require("util")
}
local presets={}

--* iterating over everything in the apis and presets folder and loading them
log("loading apis..",log.update)
for k,v in pairs(fs.list(path.."/apis")) do
    local name = v:match("[^.]+")
    if not fs.isDir(path.."/apis/"..v) then
        apis[name] = require("apis."..name)
        log("loaded api: "..name)
    end
end
log("")
log("loading presets..",log.update)
for k,v in pairs(fs.list(path.."/presets")) do
    for _k,_v in pairs(fs.list(path.."/presets/"..v)) do
        if not presets[v] then presets[v] = {} end
        local name = _v:match("[^.]+")
        presets[v][name] = require("presets."..v.."."..name)
        log("loaded preset: "..v.." > "..name)
    end
end
log("")
log("finished loading",log.success)
log("")

--* dumps the log into the a-tools/log.log file
log:dump()

--* this function is used to build a new gui_object using the gui_object.lua file
local function generate_ui(m,event_offset_x,event_offset_y)
    local old_path = package.path
    package.path = string.format(
        "%s;/%s/?.lua;/%s/?/init.lua",
        package.path, path,path
    )
    local create = require("core.gui_object")
    local win = window.create(m,1,1,m.getSize())
    log("creating gui object..",log.update)
    local gui = create(win,m,log,event_offset_x,event_offset_y)
    log("finished creating gui object!",log.success)
    log("",log.info)
    log:dump()
    package.path = old_path
    local mt = getmetatable(gui) or {}
    mt.__tostring = function() return "GuiH.MAIN_UI."..tostring(gui.id) end
    gui.api=apis
    gui.preset=presets
    return setmetatable(gui,mt)
end

return {
    create_gui=generate_ui,
    new=generate_ui,
    load_texture=require("graphic_handle").load_texture,
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
    apis=apis,
    presets=presets,
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
    },
    log=log
}
