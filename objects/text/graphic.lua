return function(object)
    if object.text then
        object:update(object.text)
        object.text()
    end
end
