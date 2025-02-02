# /etc/bash.bashrc for SuSE Linux
LANG=ja_JP.UTF-8
TERM=xterm

#
# PLEASE DO NOT CHANGE /etc/bash.bashrc There are chances that your changes
# will be lost during system upgrades.  Instead use /etc/bash.bashrc.local
# for bash or /etc/ksh.kshrc.local for ksh or /etc/zsh.zshrc.local for the
# zsh or /etc/ash.ashrc.local for the plain ash bourne shell  for your local
# settings, favourite global aliases, VISUAL and EDITOR variables, etc ...

#
# Check which shell is reading this file
#
if test -z "$is" ; then
 if test -f /proc/mounts ; then
  if ! is=$(readlink /proc/$$/exe 2>/dev/null) ; then
    case "$0" in
    *pcksh)	is=ksh	;;
    *)		is=sh	;;
    esac
  fi
  case "$is" in
    */bash)	is=bash
	case "$0" in
	sh|-sh|*/sh)
		is=sh	;;
	esac		;;
    */ash)	is=ash  ;;
    */dash)	is=ash  ;;
    */ksh)	is=ksh  ;;
    */ksh93)	is=ksh  ;;
    */pdksh)	is=ksh  ;;
    */*pcksh)	is=ksh  ;;
    */zsh)	is=zsh  ;;
    */*)	is=sh   ;;
  esac
  #
  # `r' in $- occurs *after* system files are parsed
  #
  for a in $SHELL ; do
    case "$a" in
      */r*sh)
        readonly restricted=true ;;
      -r*|-[!-]r*|-[!-][!-]r*)
        readonly restricted=true ;;
      --restricted)
        readonly restricted=true ;;
    esac
  done
  unset a
 else
  is=sh
 fi
fi

#
# Call common progams from /bin or /usr/bin only
#
path ()
{
    if test -x /usr/bin/$1 ; then
	${1+"/usr/bin/$@"}
    elif test -x   /bin/$1 ; then
	${1+"/bin/$@"}
    fi
}


#
# ksh/ash sometimes do not know
#
test -z "$UID"  && readonly  UID=`path id -ur 2> /dev/null`
test -z "$EUID" && readonly EUID=`path id -u  2> /dev/null`

test -s /etc/profile.d/ls.bash && . /etc/profile.d/ls.bash

#
# Avoid trouble with Emacs shell mode
#
if test "$EMACS" = "t" ; then
    path tset -I -Q
    path stty cooked pass8 dec nl -echo
fi

#
# Set prompt and aliases to something useful for an interactive shell
#
case "$-" in
*i*)
    #
    # Set prompt to something useful
    #
    case "$is" in
    bash)
	# Append history list instead of override
	shopt -s histappend
	# All commands of root will have a time stamp
	if test "$UID" -eq 0  ; then
	    HISTTIMEFORMAT=${HISTTIMEFORMAT:-"%F %H:%M:%S "}
	fi
	# Force a reset of the readline library
	unset TERMCAP
	# Returns short path (last two directories)
	spwd () {
	  ( IFS=/
	    set $PWD
	    if test $# -le 3 ; then
		echo "$PWD"
	    else
		eval echo \"..\${$(($#-1))}/\${$#}\"
	    fi ) ; }
	# Set xterm prompt with short path (last 18 characters)
	ppwd () {
	    local _t="$1" _w _x _u="$USER" _h="$HOST"
	    test -n "$_t"    || return
	    test "${_t#tty}" = $_t && _t=pts/$_t
	    test -O /dev/$_t || return
	    _w="$(dirs +0)"
	    _x=$((${#_w}-18))
	    test ${#_w} -le 18 || _w="...${_w#$(printf "%.*s" $_x "$_w")}"
	    printf "\e]2;%s@%s:%s\007\e]1;%s\007" "$_u" "$_h" "$_w" "$_h" > /dev/$_t
	    }
	# If set: do not follow sym links
	# set -P
	#
	# Other prompting for root
	_t=""
	if test "$UID" -eq 0  ; then
	    _u="\h"
	    _p=" #"
	else
	    _u="\u@\h"
	    _p=">"
	    if test \( "$TERM" = "xterm" -o "${TERM#screen}" != "$TERM" \) \
		    -a -z "$EMACS" -a -z "$MC_SID" -a -n "$DISPLAY" \
		    -a ! -r $HOME/.bash.expert
	    then
		_t="\$(ppwd \l)"
	    fi
	    if test -n "$restricted" ; then
		_t=""
	    fi
	fi
	case "$(declare -p PS1 2> /dev/null)" in
	*-x*PS1=*)
	    ;;
	*)
	    # With full path on prompt
	    PS1="${_t}${_u}:\w${_p} "
#	    # With short path on prompt
#	    PS1="${_t}${_u}:\$(spwd)${_p} "
#	    # With physical path even if reached over sym link
#	    PS1="${_t}${_u}:\$(pwd -P)${_p} "
	    ;;
	esac
	# Colored root prompt (see bugzilla #144620)
	if test "$UID" -eq 0 -a -n "$TERM" -a -t ; then
	    _bred="$(path tput bold 2> /dev/null; path tput setaf 1 2> /dev/null)"
	    _sgr0="$(path tput sgr0 2> /dev/null)"
	    PS1="\[$_bred\]$PS1\[$_sgr0\]"
	    unset _bred _sgr0
	fi
	unset _u _p _t
	;;
    ash)
	cd () {
	    local ret
	    command cd "$@"
	    ret=$?
	    PWD=$(pwd)
	    if test "$UID" = 0 ; then
		PS1="${HOST}:${PWD} # "
	    else
		PS1="\[${USER}@${HOST}:${PWD}\] "
	    fi
	    return $ret
	}
	cd .
	;;
    ksh)
	# Some users of the ksh are not common with the usage of PS1.
	# This variable should not be exported, because normally only
	# interactive shells set this variable by default to ``$ ''.
	if test "${PS1-\$ }" = '$ ' ; then
	    if test "$UID" = 0 ; then
		PS1="${HOST}:"'${PWD}'" # "
	    else
		PS1="${USER}@${HOST}:"'${PWD}'"> "
	    fi
	fi
	;;
    zsh)
#	setopt chaselinks
	if test "$UID" = 0; then
	    PS1='%n@%m:%~ # '
	else
	    PS1='%n@%m:%~> '
	fi
	;;
    *)
#	PS1='\u:\w> '
	PS1='\[\h:\w\]$ '
	;;
    esac
    PS2='> '

    if test "$is" = "ash" ; then
	# The ash shell does not have an alias builtin in
	# therefore we use functions here. This is a seperate
	# file because other shells may run into trouble
	# if they parse this even if they do not expand.
	test -s /etc/profile.d/alias.ash && . /etc/profile.d/alias.ash
    else
	test -s /etc/profile.d/alias.bash && . /etc/profile.d/alias.bash
	test -s $HOME/.alias && . $HOME/.alias
    fi

    #
    # Expert mode: if we find $HOME/.bash.expert we skip our settings
    # used for interactive completion and read in the expert file.
    #
    if test "$is" = "bash" -a -r $HOME/.bash.expert ; then
	. $HOME/.bash.expert
    elif test "$is" = "bash" ; then
	# Complete builtin of the bash 2.0 and higher
	case "$BASH_VERSION" in
	[2-9].*)
	    if test -e $HOME/.bash_completion ; then
		. $HOME/.bash_completion
	    elif test -e /etc/bash_completion ; then
		. /etc/bash_completion
	    elif test -s /etc/profile.d/complete.bash ; then
		. /etc/profile.d/complete.bash
	    fi
	    for s in /etc/bash_completion.d/*.sh ; do
		test -r $s && . $s
	    done
	    if test -f /etc/bash_command_not_found ; then
		. /etc/bash_command_not_found
	    fi
	    ;;
	*)  ;;
	esac
    fi

    # Do not save dupes and lines starting by space in the bash history file
    HISTCONTROL=ignoreboth
    if test "$is" = "ksh" ; then
	# Use a ksh specific history file and enable
    	# emacs line editor
    	: ${HISTFILE=$HOME/.kshrc_history}
    	: ${VISUAL=emacs}
	case $(set -o) in
	*multiline*) set -o multiline
	esac
    fi
    # command not found handler in zsh version
    if test "$is" = "zsh" ; then
	if test -f /etc/zsh_command_not_found ; then
	    . /etc/zsh_command_not_found
	fi
    fi
    ;;
esac

#
# Just in case the user excutes a command with ssh
#
if test -n "$SSH_CONNECTION" -a -z "$PROFILEREAD" ; then
    _SOURCED_FOR_SSH=true
    . /etc/profile > /dev/null 2>&1
    unset _SOURCED_FOR_SSH
fi

#
# Set GPG_TTY for curses pinentry
# (see man gpg-agent and bnc#619295)
#
if test -t && type -p tty > /dev/null 2>&1 ; then
    GPG_TTY="`tty`"
    export GPG_TTY
fi

#
# And now let us see if there is e.g. a local bash.bashrc
# (for options defined by your sysadmin, not SuSE Linux)
#
case "$is" in
bash) test -s /etc/bash.bashrc.local && . /etc/bash.bashrc.local ;;
ksh)  test -s /etc/ksh.kshrc.local   && . /etc/ksh.kshrc.local ;;
zsh)  test -s /etc/zsh.zshrc.local   && . /etc/zsh.zshrc.local ;;
ash)  test -s /etc/ash.ashrc.local   && . /etc/ash.ashrc.local
esac
test -s /etc/sh.shrc.local && . /etc/sh.shrc.local

if test -n "$restricted" -a -z "$PROFILEREAD" ; then
    PATH=/usr/lib/restricted/bin
    export PATH
fi


#
# Color set
#
# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White


#
# End of /etc/bash.bashrc
#

### pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

### rbenv
PATH=/sbin:/usr/sbin:$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"

function share_history {
   history -a
   history -c
   history -r
}
PROMPT_COMMAND='share_history'
shopt -u histappend
export HISTSIZE=1000000

export HISTIGNORE="fg:history*"
IGNOREEOF=1
HISTTIMEFORMAT='%Y%m%d %T  ';
export HISTTIMEFORMAT

# crontab -r を封印する
function crontab() {
  local opt
  for opt in "$@"; do
    if [[ $opt == -r ]]; then
      echo 'crontab -r is sealed!'
      return 1
    fi
  done
  command crontab "$@"
}


alias grep='grep --color'
alias fgrep='fgrep --color'
alias egrep='egrep --color'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ..='cd ..'
alias df='df -T -x tmpfs -x devtmpfs -x squashfs'
alias sl='ls'
alias ls='ls -vF --color=auto --show-control-chars --time-style=long-iso'
alias less='less -X'

alias heisei='date "+%EY"'
alias reiwa='date "+%EY"'
alias psnup='psnup -pa4 -m30'
alias w3m='w3m -cookie'
alias wget='wget --no-check-certificate'
alias x='xset dpms force off'

alias rdesktop='rdesktop -g 1124x768'
alias kterm='LANG=ja_JP.eucJP kterm -bg black -fg white +xim -j -sb -sk'
alias xterm='xterm -bg black -fg white -j -sb -sk -rightbar -fn 7x14 -cjk_width'
alias uxterm='uxterm -bg black -fg white -j -sb -sk -rightbar -fn 7x14 +cjk_width'
alias ipcount="ipcount $1 2>/dev/null"
alias supertux="supertux -j /dev/input/js0 --joymap 0:1:0:2:10"
alias youtube-dl="yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'"
alias yt-dlp="yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'"
alias winzip="wine /home/koga/bin/ERANGE.EXE"
alias top2='glances'


#ibus 1.4
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=xim

# fcitx
#export GTK_IM_MODULE=fcitx
#export QT_IM_MODULE=xim
#export QT4_IM_MODULE=xim
#export XMODIFIERS=@im=fcitx
#export QT_QPA_PLATFORMTHEME="qt5ct"
#export QT_AUTO_SCREEN_SCALE_FACTOR=1

set bell-style none

# X.org related variable ##################################
if [ "${DISPLAY}" != "" ]; then
   /usr/bin/xmodmap $HOME/.xmodmap
   xrdb ~/.Xresources 
   xset r rate 200 75
   xset mouse default
fi


stty -ixon

# https://wiki.archlinuxjp.org/index.php/Bash_%E3%82%AB%E3%83%A9%E3%83%BC%E3%83%97%E3%83%AD%E3%83%B3%E3%83%97%E3%83%88
#PS1='[\u@\h%\w]$ '
PS1='\[\e[0m[\u@\e[7;32m\]\h\e[0m%\w]$ '
PS1='[\u@\[\033[30;42m\]\h\[\033[00m\]%\w\[\033[1;31m\]$(__git_ps1)\[\033[00m\]]\$ ' 

# export QT_FONT_DPI=96

source ${HOME}/.bashrc.private
