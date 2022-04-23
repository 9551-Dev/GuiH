return function(side,bg)
    return {
        top_left={sym="\151",bg=bg,fg=side},
        top_right={sym="\148",bg=side,fg=bg},
        bottom_left={sym="\138",bg=side,fg=bg},
        bottom_right={sym="\133",bg=side,fg=bg},
        side_left={sym="\149",bg=bg,fg=side},
        side_right={sym="\149",bg=side,fg=bg},
        side_top={sym="\131",bg=bg,fg=side},
        side_bottom={sym="\143",bg=side,fg=bg},
        inside={sym=" ",bg=bg,fg=side}
    }
end