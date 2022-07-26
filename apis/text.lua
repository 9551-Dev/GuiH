local expect = require("cc.expect").expect

local function wrap_text(str,lenght,nnl)
    expect(1,str,"string")
    expect(2,lenght,"number")
    local words,out,outstr = {},{},""
    for c in str:gmatch("[%w%p%a%d]+%s?") do table.insert(words,c) end
    if lenght == 0 then return "" end
    while outstr < str and not (#words == 0) do
        local line = ""
        while words ~= 0 do
            local word = words[1]
            if not word then break end
            if #word > lenght then
                local espaces = word:match("% +$") or ""
                if not ((#word-#espaces) <= lenght) then
                    local cur,rest = word:sub(1,lenght),word:sub(lenght+1)
                    if #(line..cur) > lenght then words[1] = wrap_text(cur..rest,lenght,true) break end
                    line,words[1],word = line..cur,rest,rest
                else word = word:sub(1,#word-(#word - lenght)) end
            end
            if #(line .. word) <= lenght then
                line = line .. word
                table.remove(words,1)
            else break end
        end
        table.insert(out,line)
    end
    return table.concat(out,nnl and "" or "\n")
end

local function cut_parts(str,part_size)
    expect(1,str,"string")
    expect(2,part_size,"number")
    local parts = {}
    for i = 1, #str, part_size do
        parts[#parts+1] = str:sub(i, i+part_size-1)
    end
    return parts
end

local function ensure_size(str,width)
    expect(1,str,"string")
    expect(2,width,"number")
    local f_line = str:sub(1, width)
    if #f_line < width then
        f_line = f_line .. (" "):rep(width-#f_line)
    end
    return f_line
end

local function newline(tbl)
    expect(1,tbl,"table")
    return table.concat(tbl,"\n")
end

return {
    wrap = wrap_text,
    cut_parts = cut_parts,
    ensure_size = ensure_size,
    newline = newline
}
