# .bash_profile

# Get the aliases and functions
[[ -f ~/.bashrc ]] && . ~/.bashrc

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin:$HOME/.composer/vendor/drush/drush/

export PATH
#
function t() { 
  if [ $# -eq 0 ]; then
    todo.sh -d ~/.todo.cfg ls
  else
    todo.sh -d ~/.todo.cfg $* 
  fi
}
