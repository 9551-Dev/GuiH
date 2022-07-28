return function(lerp,t)
    local c5 = (2*math.pi) / 4.5
    return t==0 and 0 or (t == 1 and 1 or (t < 0.5
    and -(2^(20*t-10)  * math.sin((20*t - 11.125) * c5))/2
    or   (2^(-20*t+10) * math.sin((20*t - 11.125) * c5))/2 + 1))
end