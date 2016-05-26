export TOOLBOX=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
export PATH=$PATH:${TOOLBOX}

export PS1='shelltoolbox@'`hostname -s`':${PWD}> '

alias conndb2="source ${TOOLBOX}/conndb2.sh"
alias findcatalog="source ${TOOLBOX}/find_catalog.ksh"
alias describetable="source ${TOOLBOX}/describetable.sh"
alias searchcolumn="source ${TOOLBOX}/searchcolumn.sh"