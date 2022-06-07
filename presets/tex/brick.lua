local e=require("graphic_handle")return function(t,a)if not t then
t=colors.gray end if not a then a=colors.lightGray end local
o=[[{
        [3] = {[5] = {b = "background", s = "", t = "brick"}, [6] = {b = "background", s = "", t = "brick"}},
        [4] = {[5] = {b = "background", s = "", t = "brick"}, [6] = {b = "background", s = "", t = "brick"}},
        [5] = {[5] = {b = "background", s = "", t = "brick"}, [6] = {b = "background", s = "", t = "brick"}},
        offset = {3, 9, 11, 4}
    }]]local
i=o:gsub("background",e.code.to_blit[t]):gsub("brick",e.code.to_blit[a])return
e.load_texture(textutils.unserialize(i))end