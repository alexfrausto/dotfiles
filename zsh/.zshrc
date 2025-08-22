autoload -U colors && colors
bindkey -v

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{159} %b%f'

PS1="%F{183}%~%f${vcs_info_msg_0_}%F{120}$ %f"

HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

autoload -Uz compinit
compinit

zmodload zsh/complist
_comp_options+=(globdots)

if [ -f /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]; then
  source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi

if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  FPATH=/opt/homebrew/share/zsh-completions:$FPATH
fi

if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  source <(fzf --zsh)
fi

setopt auto_cd
setopt cdable_vars

export PATH="$HOME/bin:/usr/local/bin:$PATH"
export LANG="en_US.UTF-8"

alias vim=nvim
alias vi="nvim"
export EDITOR="nvim"
export MANPAGER="nvim +Man!"
alias tt="taskwarrior-tui"
alias l='ls -lFh'
alias la='ls -lAFh'
alias ll='ls -l'
alias ..='cd ..'
alias ...='cd ../..'
alias df='df -h'
alias du='du -h'
alias c='clear'
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias lg='lazygit'

autoload edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line

finder() { open . }
zle -N finder
bindkey '^f' finder

zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

if command -v tmux >/dev/null 2>&1; then
  [ -z "$TMUX" ] && (tmux attach || tmux new -s main)
fi

setopt EXTENDED_GLOB
setopt NO_BEEP

cursor_block='\e[2 q'
cursor_beam='\e[6 q'

function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne "$cursor_block"
  else
    echo -ne "$cursor_beam"
  fi
}
zle -N zle-keymap-select

function zle-line-init {
  echo -ne "$cursor_beam"
}
zle -N zle-line-init

function zle-line-finish {
  echo -ne "$cursor_beam"
}
zle -N zle-line-finish

bindkey -v
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
