return function(object,event)
    if type(object.value) == "boolean" then object.value = 0 end
    object.value = object.value + 1
    object.temp = event
end