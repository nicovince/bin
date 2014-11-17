# in ~/bin/gitprompt.csh:
#  
setenv GIT_BRANCH_CMD "sh -c 'git branch --no-color 2> /dev/null' | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1] /'"
set prompt = "%{\033[1;34m%}%P %{\033[1;30m%}%D.%W%{\033[01;35m%}[%n@%{\033[0;32m%}%m%{\033[1;35m%}%b][%h] %{\033[0m%}%b%~ %B%#%b %{\033[00m%} `$GIT_BRANCH_CMD`"
#set prompt="%m:%~ `$GIT_BRANCH_CMD`%B%#%b "
