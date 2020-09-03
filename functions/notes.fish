#!/usr/bin/env fish

# Initialize the data directory based on
# https://wiki.archlinux.org/index.php/XDG_Base_Directory
set -q XDG_DATA_DIR; or set XDG_DATA_DIR "$HOME/.local/share"
set -q FISH_NOTES_DIR; or set FISH_NOTES_DIR "$XDG_DATA_DIR/fish_notes"
set -q FISH_NOTES_EXTENSION; or set FISH_NOTES_EXTENSION ".md"
set -q TMPDIR; or set TMPDIR "/tmp"
set -g fish_notes_version 0.0.1

# Date format which can be sorted lexicographicically Means you can 
# sort dates by their character value. 2020 > 2019 then month 05 > 04, 
# and so on
set __notes_date_format "%Y-%m-%d %T"

set -q __notes_entry_template
or set __notes_entry_template (\
function __notes_entry_template
    echo ""
end)

# Takes a date string and formats it in a way which can be used for 
# lexicographic sorting. Works with BSD and GNU date.
function __notes_date_lexicographic
    # This kinda sorta detects if we're dealing with GNU or BSD date
    if date --version >/dev/null 2>&1
        echo (date -d $argv[1] +$__notes_date_format)
    else
        echo (date -j -f "%a %b %d %T %Z %Y" $argv[1] +$__notes_date_format)
    end
end

function __notes_dir_name
    echo $FISH_NOTES_DIR/(random 100000 1000000)
end

function __notes_new
    if not set -q EDITOR
        echo "Please set $EDITOR variable"
        return 1
    end

    # Make sure directory exists and that it is a directory
    if not test -d "$FISH_NOTES_DIR"
        echo "Creating $FISH_NOTES_DIR to store notes"
        mkdir -p "$FISH_NOTES_DIR"
    end

    if test \( -d "$FISH_NOTES_DIR" \) -a \( -f "$FISH_NOTES_DIR" \)
        echo "$FISH_NOTES_DIR is a file, exiting"
        return 1
    end

    set -l options \
        (fish_opt -s t -l tags -r --multiple-vals) \
        (fish_opt -s T -l title -r)

    argparse $options -- $argv
    if not argparse -i $options -- $argv
        echo "failed to parse arguments" 1>&2
        return 1
    end

    set -l entry_dir (__notes_dir_name)

    if test -d $entry_dir
        echo "$entry_dir already exists!"
        echo "This is extremely rare, since these names"
        echo "are generated with the 'random' command."
        echo "Please just create a new entry one more time."
        echo "If the problem persists, please create an issue"
        return 1
    end
    mkdir -p "$entry_dir"

    set -l template (__notes_entry_template | string collect)

    set -l tmpfile (mktemp $TMPDIR/"fish_notes_XXXX"$FISH_NOTES_EXTENSION)
    echo $template >"$tmpfile"

    # Ask user for note
    $EDITOR "$tmpfile"

    # Check if files are different, meaning, check
    # if user actually made any changes to the template
    if test (cat $tmpfile | string collect) = "$template"
        echo "You didn't change the default template, so I'll delete the entry again"
        rm -r $entry_dir
        return 0
    end

    # Store title
    touch "$entry_dir"/title
    if set -q _flag_T
        echo "$_flag_T" >"$entry_dir"/title
    else
        touch "$entry_dir"/title
    end

    # Store tags
    touch "$entry_dir"/tags
    if set -q _flag_t
        for tag in $_flag_t
            echo "$tag" >>"$entry_dir"/tags
        end
    else
        touch "$entry_dir"/tags
    end

    # Store date
    __notes_date_lexicographic (date) >$entry_dir/date

    # Store post
    cat "$tmpfile"  >"$entry_dir"/body$FISH_NOTES_EXTENSION

    echo "Created new note '$entry_dir'"
end

function __notes_list_tags
    cat $FISH_NOTES_DIR/*/tags \
    | sed '/^$/d'              \
    | sort                     \
    | uniq
end

function __notes_list_titles
    cat $FISH_NOTES_DIR/*/title \
    | sed '/^$/d'               \
    | sort                      \
    | uniq
end

function notes -a cmd -d "Fish Notes"
    set -l options \
        (fish_opt -s h -l help)

    argparse -i $options -- $argv
    if not argparse -i $options -- $argv
        echo "failed to parse arguments" 1>&2
        return 1
    end

    switch "$cmd"
        case tags
            __notes_list_tags
        case titles
            __notes_list_titles
        case new
            set -e argv[1]
            __notes_new $argv
        case search
            __search
        case \*
            set -e argv[1]
            __notes_help
    end
end

function __search
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

function __notes_help
    echo 'Usage:'
    echo 'notes help/--help/-h     Show this help'
    echo ''
    echo 'notes search             Find a single note based on all its content (title, tags, body, date)'
    echo '                         Requires ripgrep and FZF'
    echo ''
    echo 'notes new                Create a new note'
    echo '      -t/--tag   TAG     Can be passed multiple times'
    echo '                         Each passed value will be one tag of the new entry'
    echo '      -T/--title TITLE   Title for new note'
    echo ''
    echo 'Customziations:'
    echo 'You can customize the default template, meaning the text that will be'
    echo 'shown when $EDITOR is opened. Just override __notes_entry_template, like so:'
    echo '$ function __notes_entry_template; echo "foo"; end; notes'
    echo ''
    echo 'FISH_NOTES_DIR can be used to store the notes in a custom location'
    echo 'set FISH_NOTES_DIR ~/my_notes; notes new'
    echo ''
    echo 'FISH_NOTES_EXTENSION determines the file extension of new entries'
    echo 'set FISH_NOTES_EXTENSION '.md'; notes new'
end
