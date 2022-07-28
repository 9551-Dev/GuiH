return function(lerp,t)
    local c4 = (2*math.pi)/3;

    return t == 0 and 0 or (t == 1 and 1 or (
        -2^(10*t-10)*math.sin((t*10-10.75)*c4)
    ))
end