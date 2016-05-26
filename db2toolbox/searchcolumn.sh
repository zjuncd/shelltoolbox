#! /bin/sh
SCRIPTPATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
PATH_DBCONF=${SCRIPTPATH}/DBConnection.conf
conn_db_rslt=1
param_conn_key=$1
param_schema_key=$2
param_colname_key=$3
param_fuzzy_key=$4
if [[ ${param_conn_key} = 'help' || "${param_conn_key}" = '' ]]; then
  echo "Run command like: describetable [DBAlias] [schema] [columnname] [FuzzySearchFlag]"
  echo "Using DB Alias in configuration file as 1st parameter!"
  echo "current configuration file is: ${PATH_DBCONF}"
  echo "---------------------------------------------"
  sed 'N;s/\# \(.*\)\n\([^:]*\):.*/\2 = \1/g' $PATH_DBCONF
  echo ""
  echo "If FuzzySearchFlag set to 2, it will search the columns using COLUMNANME Like '%columnname%' "
elif [[ $(grep -cE "^${param_conn_key}:" ${PATH_DBCONF}) -eq 0 ]]; then
  echo "Using DB Alias in configuration file as 1st parameter!"
  echo "current configuration file is: ${PATH_DBCONF}"
  echo "---------------------------------------------"
  sed 'N;s/\# \(.*\)\n\([^:]*\):.*/\2 = \1/g' $PATH_DBCONF
  echo ""
else
  conndb2 ${param_conn_key}
  SQLStr="SELECT TABLE_NAME, COLUMN_NAME FROM SYSIBM.COLUMNS WHERE TABLE_SCHEMA='${param_schema_key}' AND COLUMN_NAME='${param_colname_key}'"
  if [ ${param_fuzzy_key} -eq 2 ]; then
    SQLStr="SELECT TABLE_NAME, COLUMN_NAME FROM SYSIBM.COLUMNS WHERE TABLE_SCHEMA='${param_schema_key}' AND COLUMN_NAME LIKE '%${param_colname_key}%'"
  fi
  db2 "${SQLStr}"
  db2 terminate  
fi