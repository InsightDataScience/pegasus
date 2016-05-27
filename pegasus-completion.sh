# Bash completion for peg commands
# Usage:
#     - Export PEGASUS_HOME as an environment variable as follows - in your .bash_profile (for mac) and .bashrc (for linux)
#           export PEGASUS_HOME=[Path to Pegasus] 
#     - Put "source pegasus-completion.sh" into your .bash_profile (on mac) or .bashrc (on linux)
# 
# OR
#
# If you have bash_completion installed, 
#    [for linux]
#    - place this script under /etc/bash_completion.d folder (for linux)
#    and add the following lines to your .bashrc
#    if [ -f /etc/bash_completion ]; then 
#        . /etc/bash_completion 
#    fi
#
#    [for mac]
#    - place this script under `brew --prefix`/etc/bash_completion.d (for mac)
#    and add the following lines to your .bash_profile
#    if [ -f `brew --prefix`/etc/bash_completion ]; then 
#        . `brew --prefix`/etc/bash_completion 
#    fi

_peg() 
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    clusters=$(ls ${PEGASUS_HOME}/tmp)
    services=$(ls ${PEGASUS_HOME}/service)
    
    opts=" 
      config 
      aws 
      validate
      fetch
      describe
      up
      down
      install
      uninstall
      service
      ssh
      sshcmd
      scp
      retag
      start
      stop
      port-foward
      ${clusters}
      ${services}"

    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  
    return 0

}
complete -F _peg peg

# END peg completion


 	  	 
