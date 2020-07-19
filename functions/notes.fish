#!/usr/bin/env fish

# Initialize the data directory based on
# https://wiki.archlinux.org/index.php/XDG_Base_Directory
set -q XDG_DATA_DIR; or set XDG_DATA_DIR "$HOME/.local/share"
set -q FISH_NOTES_DIR; or set FISH_NOTES_DIR "$XDG_DATA_DIR/fish_notes"
set -q FISH_NOTES_EXTENSION; or set FISH_NOTES_EXTENSION ".md"
set -q TMPDIR; or set TMPDIR "/tmp"

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
    | sed '/^$/d'                \
    | string join " "            \
    | string split " "           \
    | sort                       \
    | uniq
end

function __notes_list_titles
    cat $FISH_NOTES_DIR/*/title\
    | sed '/^$/d'                \
    | sort                       \
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
        case search_content
            __notes_by_content
        case search_tags
            __notes_by_tags
        case \*
            set -e argv[1]
            __notes_help
    end
end

# This is the function used for the --preview argument when previewing tag
# search results. See 'man fzf' for details, but here's a quick summary:
# > Use {+n} if you want all index numbers when multiple lines are selected
# Careful with quoting in here, it's easy to overlook that this is a string.
# Especially single quotes can be tricky.
set __tags_preview_func_string '\
    if test (count {2..}) -eq 0
        return
    end

    set -l tag_results $FISH_NOTES_DIR/*/tags

    for tag in {2..}
        set tag_results (rg --files-with-matches $tag $tag_results)
    end

    for r in $tag_results
        set -l dn (dirname $r)
        printf "Title: %s\n" (cat $dn/title)
        printf "Tags: %s\n" (cat $dn/tags | string join " ")
        cat $dn/body*
    end\
'

function __notes_by_tags
    if not type -q rg
        echo 'Ripgrep is required but not found'
    end

    if not type -q fzf
        echo 'FZF is required but not found'
    end

    # Gather all tags and make them sorted and unique
    set -l tags (rg '.*' $FISH_NOTES_DIR/*/tags | sed '/^$/d' | sort | uniq | string collect)

    # This stores the filenames that the user chose through FZF
    set -l results (                                  \
         echo $tags | fzf                             \
                --delimiter ':'                       \
                --preview $__tags_preview_func_string \
                --multi                               \
                --with-nth 2..                        \
                --preview-window down:wrap            \
    )

    for v in $results
        set -l dir (dirname $v)

        printf "%s\n" (string repeat -n 80 "-")

        printf "Title: %s\n" (cat $dir/title)
        printf "Tags: %s\n" (string join " " < $dir/tags)
        printf "Date: %s\n" (cat $dir/date)
        fold -s $dir/body*
    end
end

function __notes_by_content
    if not type -q rg
        echo 'Ripgrep is required but not found'
    end

    if not type -q fzf
        echo 'FZF is required but not found'
    end

    set -l result (\
        rg '.*' $FISH_NOTES_DIR/**/body.md          \
            | sed '/:$/d'                           \
            | fzf --height 70%                      \
                --preview 'cat (dirname {1})/body*' \
                --delimiter ':'                     \
                --with-nth 2..                      \
                --preview-window down:wrap)

    if not test -n "$result"
        return
    end

    set -l dir (dirname $result)

    printf "%s\n" (string repeat -n 80 "-")

    printf "Title: %s\n" (cat $dir/title)
    printf "Tags: %s\n" (string join " " < $dir/tags)
    printf "Date: %s\n" (cat $dir/date)
    fold -s $dir/body*
end

function __notes_help
    echo 'Usage:'
    echo 'notes help/--help/-h     Show this help'
    echo ''
    echo 'notes search_tags        Search through notes by tags'
    echo '                         Requires ripgrep and FZF'
    echo ''
    echo 'notes search_content     Search through notes by their content'
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
