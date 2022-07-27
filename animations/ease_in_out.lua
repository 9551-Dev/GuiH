return function(lerp,t)
    return lerp(
        t^3,
        1-((1-t)^3),
        t
    )
end