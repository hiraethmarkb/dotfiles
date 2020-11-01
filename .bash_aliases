# .bash_aliases
#

# set an "alert" alias for long running commands. Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# set alias for buku.
alias b="buku --suggest"

# clear screen.
alias cls="clear"

#
alias ftc="ls | rev | cut -d"." -f1 | rev | sort | uniq -c"

# set some aliases for grep(s).
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias grep="grep --color=auto"

# force gitk to run with '--all' parameter.
alias gitkall="gitk --all &"

# set alias for history search
alias gh='history|grep'

# set alias for history
alias h.="history"

# set some aliases for ls.
alias l="ls -CF"
alias la="ls -A"
alias ll="ls -alF"
alias ls="ls --color=auto"
alias lt='ls --human-readable --size -1 -S --classify'

# Print my public IP
alias myip='curl ipinfo.io/ip'

# set alias for the python 3 pip.
alias pip3="python3 -m pip"

# set alias for todo.sh.
alias t='todo.sh -d ~/.config/todotxt/config'

# set alias for tmux.
alias tmux='tmux -2'  # for 256color

# set alias for tmuxinator.
alias mux='tmuxinator'

# set aliases for topydo.
alias tp='cls && topydo'
alias tc='cls && topydo columns'

# open man files in yelp.
#man () { yelp "man:$@"; }
