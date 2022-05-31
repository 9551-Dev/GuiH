local graphic = require("graphic_handle").code

local function depattern(str)
    return str:gsub("[%[%]%(%)%.%+%-%%%$%^%*%?]", "%%%1")
end

return function(object)
    local term = object.canvas.term_object
    local text,mv = object.input,0
    if #object.input >= object.positioning.width-1 then
        text = object.input:sub(#object.input-object.positioning.width+1-object.shift,#object.input-object.shift)
        mv = #object.input-#text
    end
    local cursor_x = (object.positioning.x+object.cursor_pos)-mv
    term.setCursorPos(object.positioning.x,object.positioning.y)
    local or_text = text
    text = text:gsub(" ",object.space_symbol)..object.background_symbol:rep(object.positioning.width-#text+1)
    local rChar
    if object.replace_char then
        rChar = object.replace_char:rep(#or_text)..object.background_symbol:rep(object.positioning.width-#or_text+1)
    end
    term.blit(
        rChar or text,
        graphic.to_blit[object.text_color]:rep(#text),
        graphic.to_blit[object.background_color]:rep(#text)
    )
    if object.selected and (object.char_limit > object.cursor_pos) then
        term.setCursorPos(math.max(cursor_x+object.shift,object.positioning.x),object.positioning.y)
        if cursor_x+object.shift < object.positioning.x then
            object.shift = object.shift + 1
        end
        if cursor_x+object.shift > object.positioning.x+object.positioning.width then
            object.shift = object.shift - 1
        end
        local cursor
        if object.cursor_pos < object.positioning.width then
            cursor = object.input:sub(object.cursor_pos+1,object.cursor_pos+1)
            object.cursor_x = object.cursor_pos+1
        else
            cursor = object.input:sub(object.cursor_pos+1,object.cursor_pos+1)
            term.setCursorPos(cursor_x+object.shift,object.positioning.y)
        end
        object.cursor_x = cursor_x+object.shift
        term.blit(
            (cursor) ~= "" and (object.replace_char or cursor) or "_",
            cursor ~= "" and graphic.to_blit[object.background_color] or graphic.to_blit[object.text_color],
            cursor ~= "" and graphic.to_blit[object.text_color] or graphic.to_blit[object.background_color]
        )
    else
        term.setCursorPos(object.positioning.x+object.positioning.width,object.positioning.y)
        term.blit(
            "\127",
            graphic.to_blit[object.text_color],
            graphic.to_blit[object.background_color]
        )
    end
    if object.autoc.str_diff then
        term.setCursorPos(object.cursor_x+object.shift,object.positioning.y)
        local str = object.autoc.sorted[object.autoc.selected]
        if str then
            local mid = object.input:match("%S+$") or ""
            local diff = str:gsub("^"..mid:gsub(" $",""),"")
            if object.cursor_pos >= #object.input then
                local diff = diff:gsub("%%(.)", "%1")
                local max_x = object.positioning.x+object.positioning.width+1
                local autoc_x = object.cursor_x+object.shift+#diff
                if autoc_x > max_x and not object.autoc.ignore_width then
                    local ndiff = autoc_x-max_x
                    diff = diff:sub(1,#diff-ndiff)
                end
                term.blit(
                    diff,
                    graphic.to_blit[object.autoc.fg]:rep(#diff),
                    graphic.to_blit[object.autoc.bg]:rep(#diff)
                )
            end
        end
    end
end