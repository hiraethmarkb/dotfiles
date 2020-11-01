#
function mkcd () {
  mkdir -p -- "$1" && cd -P -- "$1"
}

#
function up () {
  levels=$1
  
  while [ "$levels" -gt "0" ]; do
    cd ..
    levels=$(($levels - 1))
  done
}
