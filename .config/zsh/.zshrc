# add empty line on start
#echo
export CONFIG_HOME="${XDG_CONFIG_HOME:=$HOME/.config}"

export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=/opt/homebrew/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="$CONFIG_HOME/zsh"

# Set name of the theme to load --- if set to "random", it will
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="pi-mod"
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
# Standard plu/Users/henry gins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
	#git
	macos
	fzf
	z
	copypath
	sprunge
	dircycle
	zsh-interactive-cd
	macos
	misc-user-plugins
	
	# non Oh my zsh
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vi=nvim

export DOWNLOADS=$HOME/Downloads


eval $(thefuck --alias)



# Key bindings {{{1

bindkey '^F' autosuggest-accept
bindkey '^W' kill-word
# Move cursor forward a word
bindkey '^L' forward-word
# Move cursor backward a word
bindkey '^H' backward-word
bindkey '^E' fzf-cd-widget

#bindkey " " magic-space

# 1}}}

export FZF_DEFAULT_COMMAND='fd --max-depth 4'

# remove underline in PATH suggestion
# To differentiate aliases from other command types
#ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'
# Declare the variable
typeset -A ZSH_HIGHLIGHT_STYLES
# To have paths colored instead of underlined
ZSH_HIGHLIGHT_STYLES[path]=none

eval "$(starship init zsh)"
