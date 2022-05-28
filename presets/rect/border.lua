return function(border,bg)
    return {
        top_left={sym="\159",fg=bg,bg=border},
        top_right={sym="\144",fg=border,bg=bg},
        bottom_left={sym="\130",fg=border,bg=bg},
        bottom_right={sym="\129",fg=border,bg=bg},
        side_left={sym="\149",fg=bg,bg=border},
        side_right={sym="\149",fg=border,bg=bg},
        side_top={sym="\143",fg=bg,bg=border},
        side_bottom={sym="\131",fg=border,bg=bg},
        inside={sym=" ",bg=bg,fg=border},
    }
end