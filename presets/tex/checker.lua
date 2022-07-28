--* builds a checkerboard texture with any amount of colors

local api = require("util")
local graphic = require("graphic_handle")

return function(...)
    local out = api.tables.createNDarray(2,{
        offset = {5, 13, 11, 4}
    })
    local cols = {...}
    local y = 1
    for k,v in pairs(cols) do
        local colors_collumn = {}
        for i=1,table.getn(cols) do
            local index = ((i+y)-2)%table.getn(cols)+1
            colors_collumn[i] = cols[index]
        end
        for k,v in pairs(colors_collumn) do
            out[k+4][y+8] = {s=" ",t="f",b=graphic.code.to_blit[v]}
        end
        y=y+1
    end
    return graphic.load_texture(out)
end