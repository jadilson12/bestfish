function _bestfish_editor --description 'Echo $EDITOR, or the fallback given as argument'
    # Stands in for bash's ${EDITOR:-vim}, which fish has no syntax for.
    if test -n "$EDITOR"
        echo $EDITOR
    else
        echo $argv[1]
    end
end
