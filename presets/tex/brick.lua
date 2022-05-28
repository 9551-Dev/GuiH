--* creates a custom brick texture

local graphic = require("graphic_handle")

return function(bg,brick)
    if not bg then bg = colors.gray end
    if not brick then brick = colors.lightGray end
    local def = [[{
        [3] = {[5] = {b = "background", s = "", t = "brick"}, [6] = {b = "background", s = "", t = "brick"}},
        [4] = {[5] = {b = "background", s = "", t = "brick"}, [6] = {b = "background", s = "", t = "brick"}},
        [5] = {[5] = {b = "background", s = "", t = "brick"}, [6] = {b = "background", s = "", t = "brick"}},
        offset = {3, 9, 11, 4}
    }]]
    local out = def:gsub("background",graphic.code.to_blit[bg]):gsub("brick",graphic.code.to_blit[brick])
    return graphic.load_texture(textutils.unserialize(out))
end