return function(lerp,t)
    local c1 = 1.70158;
    local c2 = c1 * 1.525;
    return t < 0.5 and
        ((2*t)^2*((c2+1)*2*t-c2))/2
        or ((2*t-2)^2*((c2+1)*(t*2-2)+c2)+2)/2
end