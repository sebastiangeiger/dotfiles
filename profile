. ~/.connect_ssh

alias la="ls -a"
alias l="ls"
alias ll="ls -l"
if command -v gvim > /dev/null; then
  alias mvim="gvim"
fi


#Activate Colors
export CLICOLOR=true
export LSCOLORS=fxgxcxdxbxegedabagacad

# JAVA
export PLAY_HOME=/Developer/SDKs/play-1.2.3

#VIM
export EDITOR='/usr/local/bin/mvim'

# PATH
export PATH=/usr/local/bin:/usr/bin:/opt/local/bin:/opt/local/sbin:/opt/subversion/bin:/opt/local/libexec/git-core:/usr/local/mysql/bin:/usr/local/git/bin:/opt/local/lib/postgresql83/bin:/System/Library/Frameworks/JRuby.framework/Versions/jruby-1.5.3/bin:/usr/local/etc:/usr/texbin:/usr/local/sbin:/Developer/SDKs/android-sdk-mac_x86/tools:/Developer/SDKs/android-sdk-mac_x86/platform-tools:/Developer/SDKs/play-1.2.3:$PATH
test -d /opt/local/man && export MANPATH=${MANPATH}:/opt/local/man:/usr/local/man

#Bash Completion
# if [ -f `brew --prefix`/etc/bash_completion ]; then
#  . `brew --prefix`/etc/bash_completion
# fi

# R~/VM
if [ -e "$HOME/.rvm" ]
then
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # This loads RVM into a shell session.
  # [[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion
fi

#iTerm/Terminal Tab Title
export PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007"'

#Customize Commandpromt
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
 
function customize_git_commandprompt {
  local BRANCHCOLOR="\[\033[32m\]"
  local   PATHCOLOR="\[\033[38;5;197m\]"
  local EXITCODECOLOR="\[\033[31m\]"
  local NOCOLOR="\[\033[m\]"
  case $TERM in
    xterm*)
    TITLEBAR='\[\033]0;\u@\h:\w\007\]'
    ;;
    *)
    TITLEBAR=""
    ;;
  esac
 
PS1="${TITLEBAR}\
$NOCOLOR$PATHCOLOR\w$BRANCHCOLOR\$(parse_git_branch)$NOCOLOR: "
if [ -e "$HOME/.rvm" ]
then
  PS1="\$(~/.rvm/bin/rvm-prompt u)$PS1" #rvm
fi
PS2='> '
PS4='+ '
}
customize_git_commandprompt
