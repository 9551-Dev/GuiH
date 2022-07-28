return function(lerp,t)
    return t < 0.5 and 16*t^5 or 1-(-2*t+2)^5 / 2
end