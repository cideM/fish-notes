
# Disable file completion
complete -c notes -f

# Command completion
complete -c notes -n "not __fish_seen_subcommand_from $commands" -a "tags" -d "list all tags" 
complete -c notes -n "not __fish_seen_subcommand_from $commands" -a "titles" -d "list all titles" 
complete -c notes -n "not __fish_seen_subcommand_from $commands" -a "new" -d "create a new entry" 
complete -c notes -n "not __fish_seen_subcommand_from $commands" -a "help" -d "show help and usage" 

# Switch/options completion
complete -c notes -s h -l help            -d "Help"

