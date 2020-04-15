# zmodload zsh/zprof
### Basic Settings {{{
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

export TERM=xterm-256color tmux

export PATH="$HOME/neovim/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

autoload -U colors zsh-mime-setup select-word-style
colors
zsh-mime-setup
select-word-style bash

# fpath=($HOME/.zsh $fpath)
# autoload $(ls $HOME/.zsh)
# fpath=(~/.zsh/functions $fpath)
# autoload $(ls ~/.zsh/functions)

## Vi-Mode {{{
set editing-mode vi
set show-mode-in-prompt on
set vi-ins-mode-string  "\1\e[5 q\2"
set vi-cmd-mode-string "\1\e[2 q\2"

# optionally:
# switch to block cursor before executing a command
set keymap vi-insert RETURN: "\e\n"

# bindkey -v      # vi mode
# vim_ins_mode="%{$fg[yellow]%}[INS]%{$reset_color%}"
# vim_cmd_mode="%{$fg[cyan]%}[CMD]%{$reset_color%}"
# vim_mode=$vim_ins_mode

# function zle-keymap-select {
#     vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
#     zle reset-prompt
# }
# zle -N zle-keymap-select

# function zle-line-finish {
#     vim_mode=$vim_ins_mode
# }
# zle -N zle-line-finish
# }}}

## pushd {{{
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_silent
setopt pushd_to_home
# }}}
# }}}

### Keybinding {{{
# Updates editor information when the keymap changes.
function zle-keymap-select() {
  # update keymap variable for the prompt
  VI_KEYMAP=$KEYMAP

  zle reset-prompt
  zle -R
}

zle -N zle-keymap-select

function vi-accept-line() {
  VI_KEYMAP=main
  zle accept-line
}

zle -N vi-accept-line

bindkey -e  # vi
bindkey '^b'      backward-word           # Ctrl+b
bindkey '^e'      forward-word            # Ctrl+e
bindkey '\e[2~'   overwrite-mode          # Insert
bindkey '^R'      history-incremental-pattern-search-backward

# kill line
bindkey '^[[3~'   kill-line               # Del
bindkey '^[[3;2~' backward-kill-line      # S-Del

# open editor to edit long command
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# if mode indicator wasn't setup by theme, define default
if [[ "$MODE_INDICATOR" == "" ]]; then
  MODE_INDICATOR="%{$fg_bold[red]%}<%{$fg[red]%}<<%{$reset_color%}"
fi

function vi_mode_prompt_info() {
  echo "${${VI_KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
}
# }}}

### History {{{
HISTFILE=$HOME/.zsh_history
HISTSIZE=1024
SAVEHIST=1024
setopt append_history
setopt hist_ignore_all_dups
unsetopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt inc_append_history  # append while typing, default is save on exit
setopt share_history
setopt bang_hist
# }}}

### Autocomplete {{{
autoload -Uz compinit
for dump in ./.zcompdump(N.mh+24); do # dump once every 24 hours
  compinit
done
compinit -C
zmodload -i zsh/complist
setopt hash_list_all
setopt completealiases
setopt always_to_end
setopt complete_in_word
setopt correct
setopt list_ambiguous

zstyle ':completion::complete:*' use-cache 1                  # completion caching, rehash to clear
zstyle ':completion::complete:*' cache-path $HOME/.zsh/cache
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'     # case insensitive
zstyle ':completion:*' menu select=2                          # menu if number of items > 2
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate  # list of completers

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'\e[00;34m%d'
zstyle ':completion:*:messages' format $'\e[00;31m%d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true

zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=29=34"
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

users=($USER root)
zstyle ':completion:*' users $users

zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or a character to insert%s'

# generic completion with --help
compdef _gnu_generic gcc
compdef _gnu_generic gdb

expand-or-complete-with-dots() {
  # toggle line-wrapping off and back on again
  [[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti rmam
  print -Pn "%{%F{red}......%f%}"
  [[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti smam

  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

zstyle :compinstall filename "$HOME/.zshrc"
# }}}

### Functions {{{
trim () {
  local r=$(echo $@ | awk '{ $1 = $1 }; 1')
  echo "$r"
}

mkd () {
  mkdir -p "$@" && cd "$@"
}

exists() {
  command -v "$1" > /dev/null 2>&1
}

ips () {
  ifconfig | grep "inet " | awk '{ print $2 }'
}

deets () {
  echo "$(whoami) @ $(hostname)"
  echo "$(ips)"
}

aptc () {
  sudo apt clean
  sudo apt autoclean
  sudo apt autoremove
}

update () {
  sudo apt update && sudo apt upgrade
  aptc
}

safe-add-apt-source () {
  SRC=$(trim $1)
  FLE=$(trim $2)

  sudo sh -c "echo '$SRC' > /etc/apt/sources.list.d/$FLE"
}

safe-add-apt-key () {
  KEY=$(trim $@)
  PTH="/tmp/$KEY"
  gpg --keyserver keyserver.ubuntu.com --recv $KEY && gpg --export --armor $KEY > $PTH
  cat $PTH | sudo apt-key add -
  rm -f $PTH
}

killit () {
  ps aux | grep -v "grep" | grep "$@" | awk '{ print $2 }' | xargs kill -9
}

skillit () {
  ps aux | grep -v "grep" | grep "$@" | awk '{ print $2 }' | xargs sudo kill -9
}

portkill() {
  lsof -nt  -i4TCP:$1 -sTCP:LISTEN | awk '{ print $1; }' | xargs kill -9
}

sportkill() {
  lsof -nt  -i4TCP:$1 -sTCP:LISTEN | awk '{ print $1; }' | xargs sudo kill -9
}

extract () {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)  tar xjf $1    ;;
      *.tar.gz)   tar xzf $1    ;;
      *.bz2)      bunzip2 $1    ;;
      *.rar)      unrar $1      ;;
      *.gz)       gunzip $1     ;;
      *.tar)      tar xf $1     ;;
      *.tbz2)     tar xjf $1    ;;
      *.tgz)      tar xzf $1    ;;
      *.zip)      unzip $1      ;;
      *.Z)        uncompress $1 ;;
      *.7z)       7zr x $1      ;;
      *)          echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

json () {
  arg=$(trim $1)
  if [ -z $arg ]; then
    echo "Really?!? No input!"
    return
  fi

  indent=2
  if [ ! -z $2 ]; then
    indent=$2
  fi

  if exists node; then
    cmd="console.log(JSON.stringify(JSON.parse(process.argv[1]), null, $indent))"
    if [ -f $arg ]; then
      cat $arg | xargs -0 node -e $cmd
    elif [[ $arg =~ ^https?:\/\/ ]]; then
      curl -sS $arg | xargs -0 node -e $cmd
    else
      echo $arg | xargs -0 node -e $cmd
    fi
  else
    cmd="import json, sys; print(json.dumps(json.loads(sys.stdin.read()), indent=$indent));"
    if [ -f $arg ]; then
      cat $arg | python -c $cmd
      # python -m json.tool $(trim $arg)
    elif [[ $arg =~ ^https?:\/\/ ]]; then
      curl -sS $arg | python -c $cmd
    else
      echo $arg | python -c $cmd
      # echo $arg | python -m json.tool
    fi
  fi
}

isjson () {
  arg=$(trim $1)

  if [ -z $arg ]; then
    echo "Really?!? No input!"
    return
  fi

  if exists node; then
    cmd="try { JSON.parse(process.argv[1]); console.log('yes') } catch(e) { console.log('no') }"
    if [ -f $arg ]; then
      cat $arg | xargs -0 node -e $cmd
    elif [[ $arg =~ ^https?:\/\/ ]]; then
      curl -sS $arg | xargs -0 node -e $cmd
    else
      echo $arg | xargs -0 node -e $cmd
    fi
  else
    cmd="
import json, sys
try:
    json.loads(sys.stdin.read())
except:
    print('no')
else:
    print('yes')
sys.exit(0)
"
    if [ -f $arg ]; then
      cat $arg | python -c $cmd
    elif [[ $arg =~ ^https?:\/\/ ]]; then
      curl -sS $arg | python -c $cmd
    else
      echo $arg | python -c $cmd
    fi
  fi
}

ghget () {
  URL=$(trim $1)
  # DIR=$(trim $2)

  USER=$(echo $URL | tr "/" " " | awk '{ print $1 }')
  REPO=$(echo $URL | tr "/" " " | awk '{ print $2 }')

  # if [ "$#" -e 2 ]; then
  #   mkd "$HOME/$DIR/github.com/$USER"
  # fi

  git clone "https://github.com/$URL"
  cd $REPO
}

# ghcodes () {
#   ghget $@ 'codes'
#   # USER=$(echo $@ | tr "/" " " | awk '{ print $1 }')
#   # REPO=$(echo $@ | tr "/" " " | awk '{ print $2 }')
#   # mkd "$HOME/codes/github.com/$USER"
#   # git clone "https://github.com/$@"
#   # cd $REPO
# }

# ghsoft () {
#   ghget $@ 'softwares'
# }

# colorslist() {
  # for code in {000..255};
  # do print -P -- "$code: %F{$code}"
# }

# if [ -z "\${which tree}" ]; then
#   tree() {
#     find $@ -print |
#   }
# fi
# }}}

### Aliases {{{
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias ~='cd ~'
# alias -- -='cd -'

color_flag=''
if which dircolors &> /dev/null; then
  color_flag='--color=auto'
fi

alias ls='ls -Flh $color_flag --group-directories-first'
alias la='ls -lhA $color_flag'
alias lr='ls -lR $color_flag'
alias lf='ls -lA $color_flag | grep "^-"'
alias l.f='ls -l $color_flag .* | grep "^-"'
alias ld='ls -lA $color_flag | grep "^d"'
alias l.d='ls -lA $color_flag .* | grep "^d"'
alias links='ls -lA $color_flag | grep "^l"'

alias fd='find . -type d -name'
alias ff='find . -type f -name'
alias fl='find . -type l -name'

alias h='history'
alias hgrep='history | grep --color=auto '

alias lgrep='ls -l | grep --color=auto'
alias lagrep='ls -lA | grep --color=auto'
alias sgrep='grep -R -n -H -C 5 --color=auto --exclude-dir={.git,.svn,.tldr,node_modules,Trash,vendor}'

alias cp='cp -iv'
alias mv='mv -iv'
alias ln='ln -iv'
alias lns='ln -siv'
alias mkdir='mkdir -v'
alias rm='rm -i'
alias rmf='rm -rf'

alias p='ps axo pid,user,pcpu,command'
alias pgrep='ps axo pid,user,pcpu,command | grep -v "grep" | grep '

alias sizeof='wget --no-config --spider'

alias timer='echo "Timer started. Stop with Ctrl-D." && date "+%a, %d %b %H:%M:%S" && time cat && date "+%a, %d %b %H:%M:%S"'
alias weather='curl -s "https://wttr.in/New%20Delhi?m2" | sed -n "1,28p"'

# alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

alias df='df -h'  # Disk free in GB
alias du='du -h -c'  # Disk usage by directory

alias servethis='python -m http.server'
alias pycclean='find . | grep -E "(__pycache__|\.pyc|\.pyo)$" | xargs rm -rf'

# curl for useragents
alias iecurl="curl -H \"User-Agent: Mozilla/5.0 (Windows; U; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)\""
alias ffcurl="curl -H \"User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.8) Gecko/2009032609 Firefox/3.0.0 (.NET CLR 3.5.30729)\""

# aliases for development
# alias vanilla-ui=". $HOME/Documents/softwares/.dotfiles/boilerplates/vanilla-ui/setup.sh "

# run previous command with sudo
alias really='sudo $(fc -ln -1)'

alias vimdiff='nvim -d -c "norm ]c[c"'  # jump to first difference

alias vi="vi -c 'set nocp nu rnu tabstop=2 shiftwidth=2 softtabstop=2 shiftround expandtab nowrap backspace=indent,eol,start'"
# }}}

### Languages {{{
## Node.js {{{
nvm() {
  unset -f nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  nvm "$@"
}

node() {
  unset -f nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  node "$@"
}

npm() {
  unset -f nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  npm "$@"
}
# }}}

## Conda (Miniconda) {{{
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# export PATH="$HOME/miniconda3/bin:$PATH"
# conda config --set changeps1 False
# conda config --set auto_activate_base False
# <<< conda initialize <<<
# }}}
## pyenv {{{
# >>> pyenv >>>
# export VIRTUAL_ENV_DISABLE_PROMPT=1
# eval "$(pyenv init -)"
# <<< pyenv <<<
# }}}

## rbenv {{{
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
# rbenv() {
#   eval "$(command rbenv init -)"
#   rbenv "$@"
# }
# }}}
# }}}

### Miscellaneous {{{
watch=all                       # watch all logins
logcheck=30                     # every 30 seconds
WATCHFMT="%n from %M has %a tty%l at %T %W"

setopt auto_cd  # if command is a path, cd into it
cdpath=($HOME/Documents;)
setopt auto_remove_slash
setopt chase_links
setopt extended_glob
setopt glob_dots
setopt check_jobs
setopt notify
setopt interactive_comments
setopt print_exit_value
unsetopt beep
unsetopt bg_nice
unsetopt clobber
unsetopt ignore_eof
unsetopt hup
unsetopt list_beep
unsetopt rm_star_silent
setxkbmap -option compose-ralt
print -Pn "\e]0; %n@%M: %~\a"

autoload -U tetris

# }}}

### Command line tools {{{
## direnv {{{
if exists direnv; then
  eval "$(direnv hook $SHELL)"
fi
# }}}
# }}}

### Version control systems {{{
autoload -U add-zsh-hook
autoload -Uz vcs_info
autoload +X VCS_INFO_nvcsformats

add-zsh-hook precmd vcs_info

zstyle ':vcs_info:*' enable git svn hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git*' git-revision true
zstyle ':vcs_info:*' use-simple false

# functions[VCS_INFO_nvcsformats]=${functions[VCS_INFO_nvcsformats]/local -a msgs/}
# zstyle ':vcs_info:*' stagedstr '%{%F{green}%B%} ● %{%b%f%}'
# zstyle ':vcs_info:*' unstagedstr '%{%F{red}%B%} ● %{%b%f%}'
zstyle ':vcs_info:*' stagedstr '%{%F{green}%B%} staged%{%b%f%}'
zstyle ':vcs_info:*' unstagedstr '%{%F{red}%B%} unstaged%{%b%f%}'
# zstyle ':vcs_info:*' formats '%{%F{cyan}%}%45<…<%R%<</%{%f%}%{%F{green}%}(%25>…>%b%<<)%{%f%}%{%F{cyan}%}%S%{%f%}%c%u'
# zstyle ':vcs_info:*' actionformats '%{%F{cyan}%}%45<…<%R%<</%{%f%}%{%F{red}%}(%a|%m)%{%f%}%{%F{cyan}%}%S%{%f%}%c%u'
# zstyle ':vcs_info:*' nvcsformats '%{%F{cyan}%}%~%{%f%}'
# zstyle ':vcs_info:git:*' patch-format '%10>…>%p%<< (%n applied)'

# zstyle ':vcs_info:svn*' formats "%{%F{cyan}%}%R/ %{%F{red}%}[%b] (%a) %m%u%c%{%f%} %S"
# zstyle ':vcs_info:svn*' actionformats "%{%F{cyan}%}%r/%{%F{red}%}(%b)%{%f%}%S"

# zstyle ':vcs_info:git*' formats "%{%F{cyan}%}%R/ %{%F{magenta}%}[%b] (%a) %m%u%c%{%f%} %S"
zstyle ':vcs_info:git*' formats "%R %{%F{magenta}%}[%s ±]%{%f%}%{%F{cyan}%}[%b]%{%f%}%u%c%m %S"
zstyle ':vcs_info:git*' actionformats "%R %{%F{magenta}%}[%s ±]%{%f%}%{%F{cyan}%}[%b|%a]%{%f%}%u%c%m %S"

zstyle ':vcs_info:svn*' formats "%R %{%F{red}%}[%s ⚡]%{%f%}%{%F{cyan}%}[%b]%{%f%}%u%c %S"
zstyle ':vcs_info:svn*:*' branchformat "%b|%r"

zstyle ':vcs_info:hg*' formats "%R [%s ☿] [%b] %c"
# zstyle ':vcs_info:git*' actionformats "(%s|%a) %12.12i %c %u %b %m"

zstyle ':vcs_info:*' nvcsformats '%d'

# zstyle ':vcs_info:*+set-message:*' hooks home-path
# Replace $HOME with ~
function +vi-home-path() {
  hook_com[base]="$(echo ${hook_com[base]} | sed "s/${HOME:gs/\//\\\//}/~/" )"
}

# Checks if working tree is dirty
function parse_git_dirty() {
  local STATUS
  local -a FLAGS
  FLAGS=('--porcelain' '--ignore-submodules=dirty' '--untracked-files=no')
  # if [[ "$(command git config --get hide-dirty)" != "1" ]]; then
    # if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
      # FLAGS+='--untracked-files=no'
    # fi
  # fi
  STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
  if [[ -n $STATUS ]]; then
    echo " %{%F{red}%}(*)%{%f%}"
  else
    echo ""
  fi
}

zstyle ':vcs_info:git+set-message:*' hooks git-untracked git-num-commits git-remote
function +vi-git-untracked() {
  local hasuntracked

  untracked=$(git status --porcelain | grep '??' 2> /dev/null | wc -l)
  if [[ $untracked -ne 0 ]]; then
    hook_com[staged]+=' untracked'
  fi
}

# show number of commits ahead-of or behind
function +vi-git-num-commits() {
  local ahead behind
  local -a gitstatus

  # for git prior to 1.7
  # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
  ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
  (( $ahead )) && gitstatus+=( " ${c3}+${ahead}${c2} " )

  # for git prior to 1.7
  # behind=$(git rev-list HEAD..origin/${hook_com[branch]} | wc -l)
  behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
  (( $behind )) && gitstatus+=( " ${c4}-${behind}${c2} " )

  hook_com[misc]+=${(j:/:)gitstatus}
}

# Show remote ref name
function +vi-git-remote() {
  local remote

  # Are we on a remote-tracking branch?
  remote=${$(git rev-parse --verify ${hook_com[branch]}@{upstream} \
      --symbolic-full-name 2>/dev/null)/refs\/remotes\/}

  if [[ -n ${remote} ]] ; then
      hook_com[branch]="${hook_com[branch]} <- ${remote}"
  fi
}

zstyle ':vcs_info:git*+set-message:*' hooks git-stash
# Show count of stashed changes
function +vi-git-stash() {
  local -a stashes

  if [[ -s ${hook_com[base]}/.git/refs/stash ]] ; then
    stashes=$(git stash list 2>/dev/null | wc -l)
    hook_com[misc]+=" (${stashes} stashed)"
  fi
}

# zstyle ':vcs_info:git+post-backend:*' hooks git-remote-staged
# function +vi-git-remote-staged() {
  # Show "unstaged" when changes are not staged or not committed
  # Show "staged" when last committed is not pushed

  # See original VCS_INFO_get_data_git for implementation details
#
  # Set "unstaged" when git reports either staged or unstaged changes
  # if (( gitstaged || gitunstaged )) ; then
    # gitunstaged=1
  # fi
#
  # Set "staged" when current HEAD is not present in the remote branch
  # if (( querystaged )) && \
     # [[ "$(${vcs_comm[cmd]} rev-parse --is-inside-work-tree 2> /dev/null)" == 'true' ]] ; then
      # Default: off - these are potentially expensive on big repositories
      # if ${vcs_comm[cmd]} rev-parse --quiet --verify HEAD &> /dev/null ; then
          # gitstaged=1
          # if ${vcs_comm[cmd]} status --branch --short | head -n1 | grep -v ahead > /dev/null ; then
            # gitstaged=
          # fi
      # fi
  # fi
#
  # hook_com[staged]=$gitstaged
  # hook_com[unstaged]=$gitunstaged
# }

# zstyle ':vcs_info:git*' formats "%{$fg[grey]%}%s %{$reset_color%}%r/%S%{$fg[grey]%} %{$fg[blue]%}%b%{$reset_color%}%m%u%c%{$reset_color%} "
# zstyle ':vcs_info:git*' actionformats "%s  %r/%S %b %m%u%c "
# }}}

# function source_if_exists() {
#   if [[ -s $1 ]]; then
#     source $1
#   fi
# }

# source_if_exists $HOME/.zprofile
# source_if_exists $HOME/.zsh/_basics
# source_if_exists $HOME/.zsh/_keybindings
# source_if_exists $HOME/.zsh/_history
# source_if_exists $HOME/.zsh/_autocomplete
# source_if_exists $HOME/.zsh/_aliases
# source_if_exists $HOME/.zsh/_functions
# source_if_exists $HOME/.zsh/_languages
# source_if_exists $HOME/.zsh/_proxy
# source_if_exists $HOME/.zsh/_vcs
# source_if_exists $HOME/.zsh/_miscellaneous
[ -s $HOME/.harshgupta/.zsh-prompt ] && . $HOME/harshgupta/.zsh-prompt
# source_if_exists $HOME/.zsh-prompt
# source_if_exists $HOME/.zsh/zsh.local

# zprof
# vim: set ft=zsh nowrap textwidth=0 foldlevel=0 foldmethod=marker :
