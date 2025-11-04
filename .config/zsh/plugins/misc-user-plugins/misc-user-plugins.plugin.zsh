
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
    yadm status
  fi
}
#}}}1


weather(){
    curl wttr.in\?m
}
weatherh(){
    curl wttr.in\?format=v2\&m
}

#{{{ cd to a folder in class with depth=1
classd() {
    cd $OBSIDIAN_CURRENT_CLASS
    FI=$(fd . -t d -d 1 | fzf --preview 'tree -C {} -L 1')
    if [ -n "$FI" ]; then
        cd $FI
    fi
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

#{{{
send_to_kindle() {
  echo mobi | mutt -s mobi -a "$argv[1]" -- dannytechn@kindle.com
}

#{{{
fzf-dir() {
  local result
  result=$(fd --type d --hidden --exclude ".*" | fzf --preview 'tree -C {} | head -100')
  [[ -n $result ]] && LBUFFER+="$result"
}


#{{{ file handler
upload-file() {
  if [[ -z "$1" ]]; then
    echo "Usage: bashupload <file>"
    return 1
  fi
  curl bashupload.com -T "$1"
}


#}}}

zip-protect() {
  # Check if at least one file is given
  if [[ $# -eq 0 ]]; then
    echo "Usage: zip-protect <file1> [file2 ...]"
    return 1
  fi

  local files=("$@")

  # Default zip name (remove extension from first file)
  local base_name="${files[1]%.*}"
  local default_zip="${base_name}.zip"

  # Prompt for zip name
  echo "Enter zip file name (default: $default_zip):"
  read zip_name
  zip_name=${zip_name:-$default_zip}

  # Prompt for password
  echo "Enter password for the zip file (default: 5678VBNM&):"
  read -s password
  password=${password:-5678VBNM&}

  # Create password-protected zip
  zip -r -P "$password" "$zip_name" "${files[@]}"

  echo "Created $zip_name with password protection."
}

