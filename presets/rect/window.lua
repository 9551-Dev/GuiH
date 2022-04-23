return function(side,bg)
    return {
        top_left={sym=" ",bg=side,fg=bg},
        top_right={sym=" ",bg=side,fg=bg},
        bottom_left={sym=" ",bg=bg,fg=side},
        bottom_right={sym=" ",bg=bg,fg=side},
        side_left={sym=" ",bg=bg,fg=side},
        side_right={sym=" ",bg=bg,fg=side},
        side_top={sym=" ",bg=side,fg=bg},
        side_bottom={sym=" ",bg=bg,fg=side},
        inside={sym=" ",bg=bg,fg=side},
    }
end