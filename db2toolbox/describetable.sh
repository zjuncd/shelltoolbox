#! /bin/sh
SCRIPTPATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
PATH_DBCONF=${SCRIPTPATH}/DBConnection.conf
conn_db_rslt=1
param_conn_key=$1
param_table_key=$2
if [[ ${param_conn_key} = 'help' || "${param_conn_key}" = '' ]]; then
  echo "Run command like: describetable [DBAlias] [schema] [columnname] [FuzzySearchFlag]"
  echo "Using DB Alias in configuration file as 1st parameter!"
  echo "current configuration file is: ${PATH_DBCONF}"
  echo "---------------------------------------------"
  sed 'N;s/\# \(.*\)\n\([^:]*\):.*/\2 = \1/g' $PATH_DBCONF
  echo ""
elif [[ $(grep -cE "^${param_conn_key}:" ${PATH_DBCONF}) -eq 0 ]]; then
  echo "Using DB Alias in configuration file as 1st parameter!"
  echo "current configuration file is: ${PATH_DBCONF}"
  echo "---------------------------------------------"
  sed 'N;s/\# \(.*\)\n\([^:]*\):.*/\2 = \1/g' $PATH_DBCONF
  echo ""
else
  conndb2 ${param_conn_key}
  db2 describe table ${param_table_key}
  db2 terminate
fi