return function(lerp,t)
    return t < 0.5 and 2*t^2 or 1-(-2*t+2)^2/2
end