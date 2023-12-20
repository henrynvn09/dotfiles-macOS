
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

#{{{ open todo
td() {
	nvim "/Users/henry/Documents/obsidian/300 - week notes/to-be-synced/todo-weekly.md"
}

#{{{ open class todo
tdc() {
	week_number=$(date +%V)
	nvim "/Users/henry/Documents/obsidian/300 - week notes/2023-W$week_number.md"
}
