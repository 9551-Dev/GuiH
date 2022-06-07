local e=require("api")return function(t,a)if type(a.visible)~="boolean"then
a.visible=true end if type(a.reactive)~="boolean"then a.reactive=true end if
not a.autoc then a.autoc={}end if type(a.autoc.put_space)~="boolean"then
a.autoc.put_space=true end local o={name=a.name or
e.uuid4(),visible=a.visible,reactive=a.reactive,react_to_events={["mouse_click"]=true,["monitor_touch"]=true,["char"]=true,["key"]=true,["key_up"]=true,["paste"]=true},positioning={x=a.x
or 1,y=a.y or 1,width=a.width or 0,},pattern=a.pattern
or".",selected=a.selected or
false,insert=false,ctrl=false,btn=a.btn,cursor_pos=a.cursor_pos or
0,char_limit=a.char_limit or a.width or
math.huge,input="",background_color=a.background_color or
t.term_object.getBackgroundColor(),text_color=a.text_color or
t.term_object.getTextColor(),order=a.order or
1,logic_order=a.logic_order,graphic_order=a.graphic_order,shift=0,space_symbol=a.space_symbol
or"\175",background_symbol=a.background_symbol
or" ",on_change_select=a.on_change_select or
function()end,on_change_input=a.on_change_input or
function()end,on_enter=a.on_enter or
function()end,replace_char=a.replace_char,ignore_tab=a.ignore_tab,autoc={strings=a.autoc.strings
or{},spec_strings=a.autoc.spec_strings or{},bg=a.autoc.bg or a.background_color
or t.term_object.getBackgroundColor(),fg=a.autoc.fg or a.text_color or
t.term_object.getTextColor(),current="",selected=1,put_space=a.autoc.put_space}}o.cursor_x=o.positioning.x
return o
end