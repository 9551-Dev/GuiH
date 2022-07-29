local api = require("util")

local function depattern(str)
    return str:gsub("[%[%]%(%)%.%+%-%%%$%^%*%?]", "%%%1")
end


local function likeness(str1,str2,give_default)
    local likeness = 0
    local len1 = string.len(str1)
    local len2 = string.len(str2)
    local minlen = math.min(len1, len2)
    if str1 == str2 then return 0 end
    if len1 == 0 and give_default then return 0.4 end
    for i = 1, minlen do
        if str1:sub(i, i) == str2:sub(i, i) then
            likeness = likeness + 1
        end
    end
    return likeness
end

local function get_keys(array)
    local temp = {}
    for k,v in pairs(array) do
        temp[#temp+1] = {key=k,value=v}
    end
    return temp
end

local function sort_strings_likeness(input,string_array)
    local strings_likeness = {}
    local out = {}
    local give_default = string_array.show_default
    local zero_likeness = {}
    for k,v in ipairs(string_array) do
        local likeness = likeness(input,v,give_default)
        if likeness > 0 and type(k) == "number" then
            if strings_likeness[likeness] then table.insert(strings_likeness[likeness],v)
            else strings_likeness[likeness] = {v} end
        else table.insert(zero_likeness,v) end
    end
    local keys = get_keys(strings_likeness)
    table.sort(keys,function(a,b) return a.key > b.key end)
    for k,v in ipairs(keys) do
        for _k,_v in ipairs(v.value) do
            table.insert(out,_v)
        end
    end
    local out_len = table.getn(out)
    for k,v in pairs(zero_likeness) do out[1+out_len+k] = v end
    return out
end

return function(object,event)
    local term = object.canvas.term_object
    if event.name == "mouse_click" or event.name == "monitor_touch" then
        if api.is_within_field(
            event.x,
            event.y,
            object.positioning.x,
            object.positioning.y,
            object.positioning.width+1,
            1
        ) then
            if object.selected then
                object.cursor_pos = math.min(object.cursor_pos + (event.x-object.cursor_x),#object.input)
            else
                object.cursor_pos = object.old_cursor or 0
                object.on_change_select(object,event,true)
            end
            object.selected = true
        else
            if object.selected then
                object.on_change_select(object,event,false)
                object.old_cursor = object.cursor_pos
                object.cursor_pos = -math.huge
            end
            object.selected = false
        end
    end
    local a = object.input:sub(1,object.cursor_pos)
    local b = object.input:sub(object.cursor_pos+1,#object.input)
    if next(object.autoc.strings) or next(object.autoc.spec_strings) and object.selected then
        local search_string = depattern(a):match("%S+$") or ""
        local search_string = search_string:gsub("%%(.)", "%1")
        local array = object.autoc.spec_strings[select(2,a:gsub("%W+",""))+1] or object.autoc.strings
        if array then
            local sorted = sort_strings_likeness(search_string,array)
            object.autoc.sorted = sorted
            if object.autoc.selected > #sorted then
                object.autoc.selected = #sorted
            end
            if sorted[1] ~= search_string then
                object.autoc.current = search_string
                object.autoc.str_diff = object.autoc.sorted[object.autoc.selected]
                if not object.autoc.str_diff then object.autoc.str_diff = "" end
                object.autoc.current_likeness = likeness(search_string,object.autoc.str_diff)
            end
        end
    end
    if event.name == "char" and object.selected and event.character:match(object.pattern) then
        if #object.input < object.char_limit then
            if not object.insert then
                object.input = a..event.character..b
                object.cursor_pos = object.cursor_pos + 1
            else
                object.input = a..event.character..b:gsub("^.","")
                object.cursor_pos = object.cursor_pos + 1
            end
            object.autoc.selected = 1
            object.on_change_input(object,event,object.input)
        end
    end
    if event.name == "key_up" and object.selected then
        if event.key == keys.leftCtrl or event.key == keys.rightCtrl then
            object.ctrl = false
        end
    end
    if event.name == "key" and object.selected then
        if event.key == keys.leftCtrl or event.key == keys.rightCtrl then
            object.ctrl = true
        elseif event.key == keys.backspace then
            object.input = a:gsub(".$","")..b
            object.autoc.selected = 1
            object.cursor_pos = math.max(object.cursor_pos-1,0)
            object.on_change_input(object,event,object.input)
        elseif event.key == keys.left then
            if not object.ctrl then object.cursor_pos = math.max(object.cursor_pos-1,0)
            else
                local diff = a:reverse():find(" ")
                object.cursor_pos = diff and #a-diff or 0
            end
        elseif  event.key == keys.right then
            if not object.ctrl then object.cursor_pos = math.min(math.max(object.cursor_pos+1,0),#object.input)
            else
                local diff = b:sub(2,#b):find(" ")
                object.cursor_pos = diff and diff+#a or #object.input
            end
        elseif event.key == keys.tab and not object.ignore_tab and not event.held and (next(object.autoc.strings) or next(object.autoc.spec_strings) and object.selected) then
            local diff = #object.autoc.str_diff-#object.autoc.current
            local res = object.input:gsub(object.autoc.current.."$",object.autoc.str_diff)
            if #res <= object.char_limit and object.cursor_pos >= #object.input then
                if object.autoc.put_space then
                    object.input = res.." "
                    object.cursor_pos = object.cursor_pos + diff + 1
                else
                    object.input = res
                    object.cursor_pos = object.cursor_pos + diff
                end
                object.autoc.sorted = {}
                object.autoc.str_diff = ""
                object.on_change_input(object,event,object.input)
            end
        elseif event.key == keys.home then
            object.cursor_pos = 0
        elseif event.key == keys["end"] then
            object.cursor_pos = #object.input
        elseif event.key == keys.delete then
            object.input = a..b:gsub("^.","")
            object.autoc.selected = 1
            object.on_change_input(object,event,object.input)
        elseif event.key == keys.insert and not event.held then
            object.insert = not object.insert
        elseif event.key == keys.down then
            if object.autoc.sorted then
                if object.autoc.selected+1 <= #object.autoc.sorted then
                    object.autoc.selected = object.autoc.selected + 1
                end
            end
        elseif event.key == keys.up then
            if object.autoc.sorted then
                if object.autoc.selected > 1 then
                    object.autoc.selected = object.autoc.selected - 1
                end
            end
        elseif event.key == keys.enter and object.selected then
            local arguments = {}
            object.input:gsub("%S+",function(str) table.insert(arguments,str) end)
            object.on_enter(object,event,arguments)
        end
    end
    if event.name == "paste" then
        object.autoc.selected = 1
        object.input = a..event.text..b
        object.cursor_pos = object.cursor_pos+#event.text
        object.on_change_input(object,event,object.input)
    end
end
