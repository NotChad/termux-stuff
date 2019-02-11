[[ $- != *i* ]] && return

shopt -s checkwinsize
shopt -s cmdhist
shopt -s globstar
shopt -s histappend
shopt -s histverify

# Configure bash history.
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=4096
export HISTFILESIZE=16384
export HISTCONTROL="ignoreboth"

# Prompt.
PS1="\\[\\e[01;34m\\][\\[\\e[0m\\]\\[\\e[00;32m\\]\\w\\[\\e[0m\\]\\[\\e[01;34m\\]]\
\\[\\e[0;34m\\]:\\[\\e[0m\\]\\[\\e[1;37m\\]\\$\\[\\e[0m\\]\\[\\e[00;37m\\] \\[\\e[0m\\]"
PS2='> '
PS3='> '
PS4='+ '

# Terminal title.
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;termux: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# Prettify message when command is not found.
command_not_found_handle() {
    "$PREFIX/libexec/termux/command-not-found" "$1"
}

# Colorful output & useful aliases for 'ls' and 'grep'.
if [ -x "$PREFIX/bin/dircolors" ] && [ -f "$PREFIX/etc/dircolors.conf" ]; then
    eval "$(dircolors -b $PREFIX/etc/dircolors.conf)"
fi
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias dir='dir --color=auto'
alias l='ls --color=auto'
alias l.='ls --color=auto -d .*'
alias ls='ls --color=auto'
alias la='ls --color=auto -a'
alias ll='ls --color=auto -Fhl'
alias ll.='ls --color=auto -Fhl -d .*'
alias lo='ls --color=auto -Fho'
alias lo.='ls --color=auto -Fho -d .*'
alias vdir='vdir --color=auto -h'

# Safety.
alias cp='cp -i'
alias ln='ln -i'
alias mv='mv -i'
alias rm='rm -i --preserve-root'
