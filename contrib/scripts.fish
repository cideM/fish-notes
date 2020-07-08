#!/usr/bin/env fish

function __handle_results
    read -la f

    for v in $f
        set -l dir (dirname $v)

        echo "-------------------------------------------------------------"

        printf "Title: %s\n" (cat $dir/title) 
        printf "Tags: %s\n" (cat $dir/tags) 
        printf "Date: %s\n" (cat $dir/date) 
        echo ""
        fold $dir/body*

        echo ""
        echo ""
    end
end

function __notes_by_title
    rg --files-with-matches -S $argv[1] $FISH_NOTES_DIR/*/title | __handle_results
end

function __notes_by_tags
    set -l results $FISH_NOTES_DIR/*/tags

    for tag in $argv
        set results (grep -l "$tag" $results)
    end

    echo "$results" | __handle_results
end

function __notes_all
    set -l notes $FISH_NOTES_DIR/*/title

    echo "$notes" | __handle_results
end

# Requires a note with title #TODO#
function __notes_todo
    $EDITOR (dirname (rg --files-with-matches -wF '#TODO#' $FISH_NOTES_DIR/*/title))/body*
end

# Requires a note with title #TODO#
function __notes_todo_work
    $EDITOR (dirname (rg --files-with-matches -wF '#TODO_WORK#' $FISH_NOTES_DIR/*/title))/body*
end


