# .bash_aliases
#

# clear screen
alias cls='clear'

# force gitk to run with '--all' parameter
alias gitkall="gitk --all &"

# set alias for the python 3 pip
alias pip3="python3 -m pip"

# set alias for todo.sh
alias t='todo.sh -d ~/.config/todotxt/config'

# set alias for tmux
alias tmux='tmux -2'  # for 256color

# set aliases for topydo
alias tp='cls && topydo'
alias tc='cls && topydo columns'

# open man files in yelp
man () { yelp "man:$@"; }
