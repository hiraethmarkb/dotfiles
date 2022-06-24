#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

#
# # mkcd - Create directory and change into it
# # usage: mkcd <directory>
function mkcd () {
  mkdir -p -- "$1" && cd -P -- "$1"
}

#
# # up - Change into the parent directory, x levels up
# # usage: up <number_of_levels>
function up () {
  levels=$1
  
  while [ "$levels" -gt "0" ]; do
    cd ..
    levels=$(($levels - 1))
  done
}

