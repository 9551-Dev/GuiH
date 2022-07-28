return function(lerp,t)
    return t == 0 and 0 or (t == 1 and 1 or (
        t < 0.5 and 2^(20*t-10)/2
        or    (2-2^(-20*t+10)) /2
    ))
end