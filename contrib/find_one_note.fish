# Requires ripgrep and FZF
function find_note -d "Find a single note interactively based on all its content"
    if not type -q rg
        echo 'Ripgrep is required but not found'
    end

    if not type -q fzf
        echo 'FZF is required but not found'
    end

    # 1. Pipe all lines with ripgrep into fzf
    # 2. Preview only the body (note content)
    # 3. Result will be path/to/file:matched term -> split it and keep only first
    # 4. Echo the directory name
    rg '.*' $FISH_NOTES_DIR\
        | fzf --preview 'cat (dirname {1})/body*' --delimiter ':' --with-nth '2..'\
        | string split ':'\
        | head -n 1 |\
        read -l foo; echo (dirname $foo)
end
