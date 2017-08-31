#!/bin/sh
### This Script is used for connecting to DB2 database with specified db alias name in the config file.
### Example:
### conndb2.sh DBAlias01
### This will connect to DBAlias01 with DBName/User/Password specified in the config file.
### Let's make it for git usage trainging
SCRIPTPATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
PATH_DBCONF=${SCRIPTPATH}/DBConnection.conf
while getopts ":hq:" optname; do
  case "$optname" in
  "h")
    echo "current configuration file is: ${PATH_DBCONF}"
    echo "---------------------------------------------"
    sed 'N;s/\# \(.*\)\n\([^:]*\):.*/\2 = \1/g' ${PATH_DBCONF}
    echo ""
    exit 0
    ;;
  "?") echo "Unknown option $OPTARG" ;;
  ":") echo "No argument value for option $OPTARG" ;;
  *) echo "Unknown error while processing options" ;;
  esac
  echo "OPTIND is now $OPTIND"
done
conn_db_rslt=1
param_conn_key=$1
if [[ ${param_conn_key} = 'help' || "${param_conn_key}" = '' ]]; then
  echo "current configuration file is: ${PATH_DBCONF}"
  echo "---------------------------------------------"
  sed 'N;s/\# \(.*\)\n\([^:]*\):.*/\2 = \1/g' ${PATH_DBCONF}
  echo ""
else
  strProc="ConnectDB2 - ${param_conn_key}"
  strState='Success'
  cmd_conn="$(grep -E "^${param_conn_key}:" ${PATH_DBCONF} | cut -d":" -f2)"
  db2 terminate
  db2 "${cmd_conn}"
fi