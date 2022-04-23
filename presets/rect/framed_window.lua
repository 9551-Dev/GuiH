return function(side,bg)
    return {
        top_left={sym=" ",bg=side,fg=bg},
        top_right={sym=" ",bg=side,fg=bg},
        bottom_left={sym="\138",bg=side,fg=bg},
        bottom_right={sym="\133",bg=side,fg=bg},
        side_left={sym="\149",bg=bg,fg=side},
        side_right={sym="\149",bg=side,fg=bg},
        side_top={sym=" ",bg=side,fg=bg},
        side_bottom={sym="\143",bg=side,fg=bg},
        inside={sym=" ",bg=bg,fg=side}
    }
end