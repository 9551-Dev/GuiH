--[[
    * a graphic installer for GuiH written using GUiH
]]

fs.delete("GuiH")
write("Setting stuff up. please stand by")
local x,y = term.getCursorPos()
x = x + 1
write(" 0%")

local github_api = http.get(
	"https://api.github.com/repos/9551-Dev/Gui-h/git/trees/main?recursive=1",
	_G._GIT_API_KEY and {Authorization = 'token ' .. _G._GIT_API_KEY}
)
local list = textutils.unserialiseJSON(github_api.readAll())
local ls = {}
local files = {}
local len = 0
github_api.close()
for k,v in pairs(list.tree) do
    if v.type == "blob" and v.path:lower():match(".+%.lua") then
        ls["https://raw.githubusercontent.com/9551-Dev/Gui-h/main/"..v.path] = v.path
        len = len + 1
    end
end
local downloads = {}
local percent = 100 / len
local finished = 0
for k,v in pairs(ls) do
    table.insert(downloads,function()
        local web = http.get(k)
        local path = "GuiH/"..v
        local data = web.readAll()
        local file = fs.open(path,"w")
        files[v] = data
        file.write(data)
        file.close()
        web.close()
        finished = finished + 1
        term.setCursorPos(x,y)
        term.write(math.floor(percent*finished).."%")
    end)
end
parallel.waitForAll(table.unpack(downloads))

local GuiH = require ".GuiH"
local running = true
local install_done = false

local objects = fs.list("GuiH/objects")
local presets = fs.list("GuiH/presets")
local apis =    fs.list("GuiH/apis")

local w,h = term.getSize()
term.clear()

local mGui = GuiH.create_gui(term.current())
local gui = mGui.create.frame({
    x=math.ceil(w/2-51/2+1),y=math.ceil(h/2-19/2+1),width=51,height=19,
    dragger={
        x=3,y=2,width=46,height=1,
    }
}).child
gui.log=setmetatable({dump=function() end},{__call=function() end})

local _next = gui.load_texture({[3]={[5]={b="8",t="8",s="",},[6]={b="7",t="8",s="",},[7]={b="8",t="8",s="",},},[4]={[5]={b="7",t="8",s="",},[6]={b="7",t="0",s="N",},[7]={b="8",t="7",s="",},},[5]={[5]={b="7",t="8",s="",},[6]={b="7",t="0",s="E",},[7]={b="8",t="7",s="",},},[6]={[5]={b="7",t="8",s="",},[6]={b="7",t="0",s="X",},[7]={b="8",t="7",s="",},},[7]={[5]={b="7",t="8",s="",},[6]={b="7",t="0",s="T",},[7]={b="8",t="7",s="",},},[8]={[5]={b="8",t="8",s="",},[6]={b="8",t="7",s="",},[7]={b="8",t="8",s="",},},offset={3,9,11,4,},})

local textures = {
    off = gui.load_texture({[3]={[5]={t="f",s="|",b="0",},},[4]={[5]={t="f",s=" ",b="e",},},offset={3,9,11,4,},}),
    on = gui.load_texture({[3]={[5]={t="d",s=" ",b="d",},},[4]={[5]={t="f",s="|",b="0",},},offset={3,9,11,4,},}),
}

local function combine_path(...)
    local strings = {...}
    local path = ""
    for k,v in ipairs(strings) do
        path = fs.combine(path,v)
    end
    return path
end

local selectable = {
    objects=true,
    apis=true,
    presets=true
}

local function path_to_table(path,sol)
    if not sol then sol = {} end
    local list = fs.list(path)
    for k,v in pairs(list) do
        local p = combine_path(path,v)
        if fs.isDir(p) then
            sol[v] = {}
            path_to_table(p,sol[v])
        else
            local file = fs.open(p,"r")
            sol[v] = file.readAll()
            file.close()
        end
    end
    return sol
end

local function reverse_table(tbl)
    local sol = {}
    for k,v in pairs(tbl) do
        sol[#tbl-k+1] = v
    end
    return sol
end

local function iterate_reccursively(t,f,...)
    for k,v in pairs(t) do
        if type(v) == "table" then
            iterate_reccursively(v,f,k,...)
        else
            f(v,table.unpack(reverse_table({k,...})))
        end
    end
end

local function precise_sleep(t)
    local ftime = os.epoch("utc")+t*1000
    while os.epoch("utc") < ftime do
        os.queueEvent("waiting")
        os.pullEvent("waiting")
    end
end

local function format_size(size)
    if size < 1024 then
        return size.."B"
    elseif size < 1024^2 then
        return math.floor(size/1024).."KB"
    elseif size < 1024^3 then
        return math.floor(size/1024^2).."MB"
    elseif size < 1024^4 then
        return math.floor(size/1024^3).."GB"
    else
        return math.floor(size/1024^4).."TB"
    end
end

local files = path_to_table("GuiH")
fs.delete("GuiH")

local function build_window(gui,title)
    local fg_rect = gui.create.rectangle({
        x = 3,
        y = 2,
        width = gui.w-5,
        height = gui.h-3,
        color=colors.lightGray,
        graphic_order=-1
    })

    fg_rect.symbols.side_top.bg = colors.gray
    fg_rect.symbols.top_right.bg = colors.gray

    local rect = gui.create.rectangle({
        x = 4,
        y = 3,
        width = gui.w-5,
        height = gui.h-3,
        graphic_order=-2,
        symbols=GuiH.presets.rect.frame(colors.black,colors.white)
    })

    gui.create.text({
        text=gui.text{
            x = 3,
            y = 2,
            text = title,
            bg=colors.gray,
            fg=colors.white
        },
        graphic_order=1
    })

    rect.symbols.side_bottom.sym = "\x83"
    rect.symbols.side_bottom.bg = colors.black
    rect.symbols.side_bottom.fg = colors.white
    rect.symbols.bottom_left.sym = "\x82"
    rect.symbols.bottom_left.bg = colors.black
    rect.symbols.bottom_left.fg = colors.white
    rect.symbols.bottom_right.sym = "\x81"
    rect.symbols.bottom_right.bg = colors.black
    rect.symbols.bottom_right.fg = colors.white

end

local box = gui.create.inputbox{
    x=4,y=5,width=15,
    graphic_order=5,
    char_limit=50,
    background_color=colors.gray
}

gui.create.text{
    graphic_order=5,
    text=gui.text{
        x=4,y=4,
        text="install path",
        bg=colors.blue
    }
}

gui.create.text{
    graphic_order=5,
    text=gui.text{
        x=21,y=3,
        text="objects",
        bg=colors.blue
    }
}

gui.create.text{
    graphic_order=5,
    text=gui.text{
        x=36,y=3,
        text="apis",
        bg=colors.blue
    }
}

gui.create.text{
    graphic_order=5,
    text=gui.text{
        x=4,y=7,
        text="presets",
        bg=colors.blue
    }
}

local buttons = {apis={},objects={},presets={}}

for k,v in ipairs(objects) do
    local sw = gui.create.switch({
        x=21,y=k+3,width=2,height=1,
        tex_on=textures.on,
        tex=textures.off,
        graphic_order=12
    })
    local t = gui.create.text({
        text=gui.text{
            x=24,y=k+3,
            text=v,
            bg=colors.lightGray
        }
    })
    gui.create.script{
        graphic=function()
            t.text.fg = sw.value and colors.lime or colors.red
        end,
        graphic_order=5
    }
    sw.value = true
    buttons.objects[v] = {ob=sw,name=v}
end

for k,v in pairs(apis) do
    local sw = gui.create.switch({
        x=36,y=k+3,width=2,height=1,
        tex_on=textures.on,
        tex=textures.off,
        graphic_order=12
    })
    local t = gui.create.text({
        text=gui.text{
            x=39,y=k+3,
            text=fs.getName(v):match("[^.+?]+"),
            bg=colors.lightGray
        }
    })
    gui.create.script{
        code=function()
            t.text.fg = sw.value and colors.lime or colors.red
        end,
        logic_order=2
    }
    sw.value = true
    buttons.apis[v] = {ob=sw,name=v}
end

for k,v in pairs(presets) do
    local sw = gui.create.switch({
        x=4,y=k+7,width=2,height=1,
        tex_on=textures.on,
        tex=textures.off,
        graphic_order=12
    })
    local t = gui.create.text({
        text=gui.text{
            x=7,y=k+7,
            text=v,
            bg=colors.lightGray
        }
    })
    gui.create.script{
        code=function()
            t.text.fg = sw.value and colors.lime or colors.red
        end,
        logic_order=2
    }
    sw.value = true
    buttons.presets[v] = {ob=sw,name=v}
end

gui.create.button({
    x=40,y=15,width=6,height=3,
    tex=_next,
    graphic_order=5,
    on_click=function(object)
        local path = shell.resolve(box.input)
        local olGui = {}
        for k,v in pairs(gui.gui) do
            olGui[k] = v
            gui.gui[k] = {}
        end
        build_window(gui,"Gui-h install confirmation")
        gui.create.button{
            x=9,y=8,width=15,height=5,
            background_color=colors.red,
            graphic_order=5,
            text=gui.text{
                text="cancel",
                bg=colors.red,
                fg=colors.white,
                centered=true
            },
            on_click=function()
                running = false
                gui.term_object.setCursorPos(1,1)
                gui.term_object.setBackgroundColor(colors.black)
                gui.term_object.clear()
            end
        }
        local to_install = {}
        local file_size = 0
        iterate_reccursively(files,function(file,a,b,c,d,e)
            a,b,c,d,e = a or "",b or "",c or "",d or "",e or ""
            local size = #("%q"):format(file)
            if selectable[a] then
                local v = buttons[a][b]
                if v.ob.value then
                    to_install[combine_path(a,v.name,c,e)] = {
                        data=file,
                        size=size
                    }
                    file_size = file_size + size
                end
            else
                to_install[combine_path(a,b,c,d,e)] = {
                    data=file,
                    size=size
                }
                file_size = file_size + size
            end
        end)
        gui.create.text{
            text=gui.text{
                x=5,y=4,
                text="this will install the GuiH api at ",
                bg=colors.black,
                fg=colors.white,
                transparent=true
            },
            graphic_order=6
        }
        --add another text under the one before
        gui.create.text{
            text=gui.text{
                x=5,y=5,
                text=("%q"):format(combine_path(path,"GuiH")),
                bg=colors.blue,
                transparent=false
            },
            graphic_order=6
        }
        gui.create.text{
            text=gui.text{
                x=4,y=16,
                text="GuiH installer. written by: 9551Dev",
                bg=colors.black,
                fg=colors.white,
                transparent=true
            },
            graphic_order=6
        }
        gui.create.text{
            text=gui.text{
                x=4,y=15,
                text="install size: "..format_size(file_size),
                bg=colors.red,
                fg=colors.white,
            },
            graphic_order=6
        }
        gui.create.button{
            x=26,y=8,width=15,height=5,
            background_color=colors.green,
            graphic_order=5,
            text=gui.text{
                x=5,y=16,
                text="install",
                bg=colors.green,
                fg=colors.white,
                centered=true
            },
            on_click=function()
                for k,v in pairs(gui.gui) do
                    gui.gui[k] = {}
                end
                build_window(gui,"Gui-h installing...")
                local pb = gui.create.progressbar{
                    x=5,y=5,width=42,height=10,
                    graphic_order=5,
                    bg=colors.gray,
                    fg=colors.lime
                }
                local perc = gui.create.text{
                    text=gui.text{
                        x=43,y=15,
                        text="0%",
                        bg=colors.gray,
                        fg=colors.lime
                    },
                    graphic_order=7
                }
                gui.create.script{
                    graphic=function()
                        perc.text.text = tostring(math.ceil(pb.value)).."%"
                    end,
                    graphic_order=6
                }
                pb.value = 0
                local info_text = gui.create.text{
                    text=gui.text{
                        x=14,y=15,
                        text="installing...",
                        bg=colors.lightGray
                    },
                    graphic_order=5
                }
                local fls = gui.create.text{
                    text=gui.text{
                        x=14,y=16,
                        text="",
                        bg=colors.blue,
                        fg=colors.white
                    },
                    graphic_order=5
                }.text
                local installed = {}
                gui.create.button{
                    x=5,y=15,width=8,height=3,
                    background_color=colors.red,
                    graphic_order=5,
                    text=gui.text{
                        x=5,y=16,
                        text="cancel",
                        bg=colors.red,
                        fg=colors.white,
                        centered=true
                    },
                    on_click=function()
                        gui.term_object.setCursorPos(1,1)
                        gui.term_object.setBackgroundColor(colors.black)
                        gui.term_object.clear()
                        fs.delete(combine_path(path,"GuiH"))
                        running = false
                    end
                }
                local size_done = 0
                mGui.schedule(function()
                    local p = combine_path(path,"GuiH")
                    if not fs.exists(path) then fs.makeDir(path)
                    else if fs.exists(p) then fs.delete(p) end end
                    if not fs.exists(combine_path(p,"objects")) then fs.makeDir(combine_path(p,"objects")) end
                    if not fs.exists(combine_path(p,"apis")) then fs.makeDir(combine_path(p,"apis")) end
                    if not fs.exists(combine_path(p,"presets")) then fs.makeDir(combine_path(p,"presets")) end
                    for k,v in pairs(to_install) do
                        local path = combine_path(path,"GuiH",k)
                        local file = fs.open(path,"w")
                        file.write(v.data)
                        file.close()
                        fls.text = k
                        precise_sleep(v.size/50000)
                        size_done = size_done + v.size
                        pb.value = (size_done/file_size)*100
                    end
                    sleep(0.5)
                    install_done=true
                    error("installing finished",0)
                end,nil,true)
            end
        }
    end
})

build_window(gui,"Gui-h installer")

local err = mGui.execute(function()
    while running do sleep() end
end)

if box.input ~= "" or not install_done then fs.delete("GuiH") end

term.clear()
term.setCursorPos(1,1)

error(err == "ok" and "Canceled" or err,0)
