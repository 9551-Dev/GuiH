local objects = require("GuiH.object-loader")
local update = require("GuiH.a-tools.update")

local function create_gui_object(term_object)
    local gui_objects = {}
    for k,v in pairs(objects.types) do
        gui_objects[v] = {}
    end
    local gui = {
        term_object=term_object,
        gui=gui_objects,
        update=update,
        visible=true,
        id=os.epoch("utc")
    }
    local function updater(timeout,visible,is_child,data)
        update(gui,timeout,visible,is_child,data)
    end
    gui.create = objects.main(gui,gui.gui)
    gui.update = updater
    gui.text = function(data)
        data = data or {}
        return {
            text = data.text or "<TEXT OBJECT>",
            centered = (data.centered ~= nil) and data.centered or true,
            x = data or 1,
            y = data or 1,
            offset_x = data.offset_x or 0,
            offset_y = data.offset_y or 0,
            blit = data.blit or {("0"):rep(13),("f"):rep(13)}
        }
    end
    return gui
end

return create_gui_object