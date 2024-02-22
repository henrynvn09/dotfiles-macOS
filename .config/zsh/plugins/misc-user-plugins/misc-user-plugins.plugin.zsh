
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
	nvim +4 "$HOME/Documents/obsidian/300 - week notes/todo-weekly.md"
}

#{{{ open class todo
tdc() {
	local week_number=$(date +%V)
  local year=$(date +%Y)
	nvim +31 "$HOME/Documents/obsidian/300 - week notes/weekly/${year}-W${week_number}.md"
}
