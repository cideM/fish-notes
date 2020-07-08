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
    echo "Title: "
    echo "Tags: "
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

function notes
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

    $EDITOR "$tmpfile"

    # Check if files are different, meaning, check
    # if user actually made any changes to the template
    if test (cat $tmpfile | string collect) = "$template"
        echo "You didn't change the default template, so I'll delete the entry again"
        rm -r $entry_dir
        return 0
    end

    # Each line has meaning:
    # 1. Title (after "Title: ")
    # 2. Tags (after "Tags: ")
    # 3. Empty line
    # 4. This line including all others are content of note
    set -l title (sed -n '1p' $tmpfile | sed 's/^Title: //')
    set -l tags (sed -n '2p' $tmpfile | sed 's/^Tags: //')
    set -l body (sed -n '4,$p' $tmpfile)

    __notes_date_lexicographic (date) >$entry_dir/date
    echo "$title" >"$entry_dir"/title
    echo "$tags"  >"$entry_dir"/tags
    echo "$body"  >"$entry_dir"/body$FISH_NOTES_EXTENSION

    echo "Created new note '$entry_dir'"
end
