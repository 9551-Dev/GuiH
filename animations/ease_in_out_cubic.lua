return function(lerp,t)
    return t < 0.5 and 4 * t^3 or 1-(-2*t+2)^3 / 2
end