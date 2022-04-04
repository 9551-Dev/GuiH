local objects = require("GuiH.object-loader")
local update = require("GuiH.a-tools.update")

local function create_gui_object(term_object)
    local gui_objects = {}
    local type = "term_object"
    pcall(function()
        type = peripheral.getType(term_object)
    end)
    for k,v in pairs(objects.types) do
        gui_objects[v] = {}
    end
    local gui = {
        term_object=term_object or term.current(),
        gui=gui_objects,
        update=update,
        visible=true,
        id=os.epoch("utc")
    }
    local function updater(timeout,visible,is_child,data)
        return update(gui,timeout,visible,is_child,data)
    end
    if type == "monitor" then
        gui.monitor = peripheral.getName(term_object)
    else
        gui.monitor = "term_object"
    end
    gui.create = objects.main(gui,gui.gui)
    gui.update = updater
    gui.text = function(data)
        data = data or {}
        return setmetatable({
            text = data.text or "<TEXT OBJECT>",
            centered = (data.centered ~= nil) and data.centered or true,
            x = data or 1,
            y = data or 1,
            offset_x = data.offset_x or 0,
            offset_y = data.offset_y or 0,
            blit = data.blit or {("0"):rep(13),("f"):rep(13)}
        },{
            __call=function(self)
                local term = gui.term_object
                if self.centered then
                    local w,h = term.getSize()
                    local y = h/2
                    local x = math.ceil((w/2)-(#self.text/2))
                    term.setCursorPos(x+self.offset_x,y+self.offset_y)
                else
                    term.setCursorPos(self.x+self.offset_x,self.y+self.offset_y)
                end
                term.blit(self.text,unpack(self.blit))
            end
        })
    end
    return gui
end

return create_gui_object