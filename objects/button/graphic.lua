return function(object)
    local term = object.canvas.term_object
    term.setCursorPos(object.temp.x,object.temp.y)
    term.write(object.value)
end