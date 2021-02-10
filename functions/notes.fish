#!/usr/bin/env fish

# Initialize the data directory based on
# https://wiki.archlinux.org/index.php/XDG_Base_Directory
set -q XDG_DATA_DIR; or set XDG_DATA_DIR "$HOME/.local/share"
set -q FISH_NOTES_DIR; or set FISH_NOTES_DIR "$XDG_DATA_DIR/fish_notes"
set -q FISH_NOTES_EXTENSION; or set FISH_NOTES_EXTENSION ".md"
set -q TMPDIR; or set TMPDIR "/tmp"
set -g fish_notes_version 0.0.1


set -q __notes_entry_template
or set __notes_entry_template (\
function __notes_entry_template
    echo ""
end)

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

    # Use ISO 8601 so folders are automatically easy to sort
    # lexicographicically and therefore by date 
    set -l entry_dir $FISH_NOTES_DIR/(date -Iseconds)

    if test -d $entry_dir
        echo "$entry_dir already exists!"
        echo "This is extremely rare, since these names"
        echo "are generated with the 'random' command."
        echo "Please just create a new entry one more time."
        echo "If the problem persists, please create an issue"
        return 1
    end
    mkdir -p "$entry_dir"

    set -l template (echo $__notes_entry_template | string collect)

    set -l tmpfile (mktemp $TMPDIR/"fish_notes_XXXX"$FISH_NOTES_EXTENSION)
    echo $template | string join \n >"$tmpfile"

    # Ask user for note
    $EDITOR "$tmpfile"

    set -l content (cat $tmpfile)
    # Check if files are different, meaning, check
    # if user actually made any changes to the template
    if test "$content" = "$template"
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

    # Store date in a format which can be sorted lexicographicically Means you can 
    # sort dates by their character value. 2020 > 2019 then month 05 > 04, 
    # and so on
    date -Iseconds >$entry_dir/date

    # Store post
    cat "$tmpfile"  >"$entry_dir"/body$FISH_NOTES_EXTENSION

    echo "Created new note '$entry_dir'"
end

function __notes_search
    set -l options \
        (fish_opt -s t -l tags -r --multiple-vals) \
        (fish_opt -s T -l title -r)
    argparse -i $options -- $argv
    if not argparse -i $options -- $argv
        echo "failed to parse arguments" 1>&2
        return 1
    end

    set -l results (for result in $FISH_NOTES_DIR/*/body*; dirname $result; end)
    if test (count $results) -eq 0
        echo "You don't have any notes!"
        return 0
    end

    # For each category (tags, title), find all matches. Then return
    # the intersection of the matches. That's how this search works in a
    # nutshell and most of the code is plumbing and boilerplate since Fish
    # (obviously) doesn't have set functions (union, intersection, etc). If
    # a category is not defined, for example if the user did not supply
    # tags to search, consider all files to match. So if we have one match
    # for the given title, return the intersection of the title matches
    # (one file) and the tag matches (all files).

    if set -q _flag_t
        for tag in $_flag_t
            # Ignore "file not found" because if a post doesn't have a tags
            # file then we can just ignore it. Same for title.
            set results (grep -l "$tag" $results/tags 2> /dev/null | while read -la result
                dirname $result
            end)
        end
    end

    if set -q _flag_T
        set results (grep -l "$_flag_T" $results/title 2> /dev/null | while read -la result
            dirname $result
        end)
    end

    for f in (string join \n $results | sort -r)
      echo $f
    end
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
            set -e argv[1]
            __notes_search $argv
        case \*
            set -e argv[1]
            __notes_help
    end
end

function __notes_help
    echo 'Usage:'
    echo 'notes help/--help/-h     Show this help'
    echo ''
    echo 'notes new                Create a new note'
    echo '      -t/--tag   TAG     Can be passed multiple times'
    echo '                         Each passed value will be one tag of the new entry'
    echo '      -T/--title TITLE   Title for new note'
    echo 'notes search             List notes (without options, list all entries)'
    echo '        -t/--tags TAG    Can be passed multiple times'
    echo '                         Show only entries which match all values passed as TAG'
    echo '                         Show all entries matching foo AND bar'
    echo '                         notes search -t foo -t bar'
    echo '        -T/--title TITLE Show only entries whose title is contained in TITLE'
    echo '                         Show all entries where title includes foo'
    echo '                         notes search -T foo'
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
