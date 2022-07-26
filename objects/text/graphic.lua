return function(object)
    if object.text then
        object:update()
        object.text()
    end
end
