return function(lerp,t)
    return t < 0.5 and 8*t^4 or 1 - (-2*t+2)^4 / 2
end