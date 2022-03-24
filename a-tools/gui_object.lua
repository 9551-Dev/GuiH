local objects = require("GuiH.object-loader")

local function create_gui_object(term_object)
    local gui = {
        term_object=term_object,
    }
    gui.create = objects(gui)
    return gui
end

return create_gui_object