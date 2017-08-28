
function share_history {
   history -a
   history -c
   history -r
}
PROMPT_COMMAND='share_history'
shopt -u histappend
export HISTSIZE=10000

export HISTIGNORE="fg:history*"

alias grep='grep --color'
alias fgrep='fgrep --color'
alias egrep='egrep --color'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ..='cd ..'
alias df='df -T -x tmpfs -x rootfs -x devtmpfs'
alias ls='ls -F --color=auto'
alias w='w -f'

alias heisei='date "+%EY"'
alias psnup='psnup -pa4 -m30'
alias w3m='w3m -cookie'
alias wget='wget --no-check-certificate'
