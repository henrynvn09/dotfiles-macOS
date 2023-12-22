
#{{{ nvim file with fzf in .config
dot() {
    cd $HOME/.config/
    FI=$(fd . -t f -d 4 | fzf --preview 'cat {} || tree -C {} -L 2')
    if [ -n "$FI" ]; then
        nvim $FI
    fi
    cd -
}

#{{{ nvim folder with fzf in .config
dotd() {
    cd $HOME/.config/
    FI=$(fd . -t d -d 3 | fzf --preview 'tree -C {} -L 2')
    if [ -n "$FI" ]; then
        cd $FI
    fi
}

#{{{1 yadm -> y
# No arguments: `yadm status`
# With arguments: acts like `yadm`
y() {
  if [[ $# -gt 0 ]]; then
    yadm "$@"
  else
    yadm status -unormal
  fi
}
#}}}1


weather(){
    curl wttr.in\?m
}
weatherh(){
    curl wttr.in\?format=v2\&m
}


#{{{ open todo
readme() {
	nvim "$HOME/README.md"
}

#{{{ open todo
td() {
	nvim "/Users/henry/Documents/obsidian/300 - week notes/to-be-synced/todo-weekly.md"
}

#{{{ open class todo
tdc() {
	week_number=$(date +%V)
	nvim "/Users/henry/Documents/obsidian/300 - week notes/2023-W$week_number.md"
}
