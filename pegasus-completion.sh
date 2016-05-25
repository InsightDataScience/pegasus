# Bash completion for peg commands
# Usage: Put "source pegasus-completion.sh" into your .bash_profile (on mac) or .bashrc (on linux)
# If you are using bash_completion, just place this script 
_peg() 
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    clusters=$(ls ${PEGASUS_HOME}/tmp)
    
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
      ${clusters}"

    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  
    return 0

}
complete -F _peg peg

# END tmux completion


 	  	 
