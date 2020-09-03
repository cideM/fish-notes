# List all commands, useful for the -n option of the complete function
set -l commands tags titles new help search

# Disable file completion
complete -c notes -f

# Command completion
complete -c notes -n "not __fish_seen_subcommand_from $commands" -a "tags" -d "list all tags" 
complete -c notes -n "not __fish_seen_subcommand_from $commands" -a "titles" -d "list all titles" 
complete -c notes -n "not __fish_seen_subcommand_from $commands" -a "new" -d "create a new entry" 
complete -c notes -n "not __fish_seen_subcommand_from $commands" -a "help" -d "show help and usage" 
complete -c notes -n "not __fish_seen_subcommand_from $commands" -a "search" -d "find a single note" 

# Switch/options completion
complete -c notes -s h -l help            -d "Help"
complete -c notes -s t -l tags            -n "__fish_seen_subcommand_from search new" -d "Tags" -a "(notes tags)"   -r -f
complete -c notes -s T -l title           -n "__fish_seen_subcommand_from search new" -d "Title" -a "(notes titles)"  -r -f

