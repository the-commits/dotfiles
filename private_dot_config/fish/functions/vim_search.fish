function vim_search
    set RELOAD "reload:rg --column --color=always --smart-case {q} || :"

    fzf --disabled --ansi --multi \
        --bind "start:$RELOAD" --bind "change:$RELOAD" \
        --bind "enter:execute(vim +{2} {1})" \
        --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
        --delimiter : \
        --preview 'bat --style=full --color=always --highlight-line {2} (string escape {1})' \
        --preview-window '~4,+{2}+4/3,<80(up)'
end

