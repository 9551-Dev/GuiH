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
        update=update
    }
    local function updater(wait_for_click,visible)
        update(gui,wait_for_click,visible)
    end
    gui.create = objects.main(gui)
    gui.update = updater
    return gui
end

return create_gui_object