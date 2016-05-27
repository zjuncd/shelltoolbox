#! /bin/sh
### This script is used for get the DB2 Catalog info from Linux Server 
### It accept 1 parameter as the DBAlias Name
if [[ $# -eq 0 ]]; then
  echo "Available DBAlias as Below: "
  db2 list db directory | sed -n 's/^ *Database alias *= *//gp' | sort | more
else
  DBName=$1
  if [[ $(db2 list db directory | sed -n 's/^ *Database alias *= *//gp' | grep -cE "^${DBName}$") -eq 0 ]]; then
    echo "DB Alias Name illegal!"
  else
    db2 list db directory | sed -n '/^Database [0-9]* entry/{N;N;/Database alias\s*= '${DBName}'$/b a;d;:a;N;N;p}'
    NodeName=$(db2 list db directory | sed -n '/^Database [0-9]* entry/{N;N;/Database alias\s*= '${DBName}'/b a;d;:a;N;N;p}'|grep 'Node name'|cut -d= -f2)    
    NodeName=${NodeName# *}
    if [[ $(db2 list node directory | sed -n 's/^ *Node name *= *//gp' | grep -cE "^${NodeName}$") -eq 0 ]]; then
    	echo "No Node found for DBAlias ${DBName}"
    else
      db2 list node directory | sed -n '/^Node [0-9]* entry/{N;N;/Node name\s*= '$NodeName'/b a;d;:a;N;N;N;N;N;p}'
    fi
  fi
fi