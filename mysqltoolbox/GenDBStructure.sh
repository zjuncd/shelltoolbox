#! /bin/sh

SCRIPTPATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
PATH_DBCONF=${SCRIPTPATH}/DBConnection.conf
param_conn_key="$1"

if [[ ${param_conn_key} = 'help' || "${param_conn_key}" = '' ]]; then
  echo "current configuration file is: ${PATH_DBCONF}"
  echo "---------------------------------------------"
  sed 'N;s/\# \(.*\)\n\([^:]*\):.*/\2 = \1/g' $PATH_DBCONF
  echo ""
else  
  cmd_conn="$(grep -E "^${param_conn_key}:" ${PATH_DBCONF} | cut -d":" -f2)"
  DBNAME="$(grep -E "^${param_conn_key}:" ${PATH_DBCONF} | sed -n 's/^.* \([0-9a-zA-Z]*\)$/\1/p')"
  BACKUPDIR_BASE=/backup/${param_conn_key}
  BACKUPDIR_TABLE=${BACKUPDIR_BASE}/tables
  BACKUPDIR_VIEW=${BACKUPDIR_BASE}/views
  BACKUPDIR_SP=${BACKUPDIR_BASE}/procedure
  BACKUPDIR_FUNC=${BACKUPDIR_BASE}'/function'

  if [ ! -d ${BACKUPDIR_TABLE} ]; then mkdir -p ${BACKUPDIR_TABLE} ; fi
  if [ ! -d ${BACKUPDIR_VIEW} ]; then mkdir -p ${BACKUPDIR_VIEW} ; fi
  if [ ! -d ${BACKUPDIR_SP} ]; then mkdir -p ${BACKUPDIR_SP} ; fi
  if [ ! -d ${BACKUPDIR_FUNC} ]; then mkdir -p ${BACKUPDIR_FUNC} ; fi

  echo "Backup DDL for Base Tables"
  mysql ${cmd_conn} -N -e "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = '${DBNAME}' AND TABLE_TYPE='BASE TABLE'" | while read tblname; do
  mysqldump ${cmd_conn} ${tblname} -d | sed -e '/^--/d' -e '/^\/\*\!/d' -e 's/^) ENGINE=InnoDB .*\;$/);/' -e '/^$/d' > ${BACKUPDIR_TABLE}/${tblname}.ddl
done

echo "Backup DDL for Views"
mysql ${cmd_conn} -N -e "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = '${DBNAME}' AND TABLE_TYPE='VIEW'" | while read viewname; do
  mysqldump ${cmd_conn} ${viewname} -d | sed -n '/-- Final view structure /, $p' | grep ' VIEW ' | sed -e 's/\/\*\!50001 //' -e 's/^VIEW /CREATE VIEW /' -e 's/\*\///' -e '/^$/d' > ${BACKUPDIR_VIEW}/${viewname}.ddl
done

echo "Backup DDL for SP"
mysql ${cmd_conn} -N -e "SELECT ROUTINE_NAME FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='${DBNAME}' AND ROUTINE_TYPE='PROCEDURE'" | while read spname; do
  mysql ${cmd_conn} -N -e "
    SELECT CONCAT('drop procedure if exists ', R.ROUTINE_NAME, ';', '\ncreate procedure ', R.ROUTINE_NAME, '(',P.Parameters,')', '\n', R.ROUTINE_DEFINITION)
    FROM information_schema.ROUTINES R 
    LEFT OUTER JOIN (SELECT SPECIFIC_NAME, GROUP_CONCAT(CONCAT(PARAMETER_MODE,' ', PARAMETER_NAME, ' ', DATA_TYPE, CASE WHEN DATA_TYPE IN ('char','varchar') THEN CONCAT('(', CHARACTER_MAXIMUM_LENGTH, ')') ELSE '' END)) AS Parameters
      FROM information_schema.PARAMETERS
      WHERE SPECIFIC_SCHEMA='${DBNAME}' AND SPECIFIC_NAME = '${spname}'
      GROUP BY SPECIFIC_NAME) P on P.SPECIFIC_NAME = R.ROUTINE_NAME
    WHERE R.ROUTINE_SCHEMA = '${DBNAME}' AND R.ROUTINE_TYPE = 'PROCEDURE' AND R.ROUTINE_NAME = '${spname}'
  " | sed -e 's/\\n/\n/g' -e 's/\\t/\t/g' > ${BACKUPDIR_SP}/${spname}.ddl
done

echo "Backup DDL for Function"
mysql ${cmd_conn} -N -e "SELECT ROUTINE_NAME FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='${DBNAME}' AND ROUTINE_TYPE='FUNCTION'" | while read funcname; do
  mysql ${cmd_conn} -N -e "
    SELECT CONCAT('drop function if exists ', R.ROUTINE_NAME, ';', '\ncreate function ', R.ROUTINE_NAME, '(',P.Parameters_In,')', '\n', P.Parameters_Out, '\n', R.ROUTINE_DEFINITION)
    FROM information_schema.ROUTINES R 
    LEFT OUTER JOIN (
      SELECT SPECIFIC_NAME
        , GROUP_CONCAT(CONCAT(PARAMETER_MODE,' ', PARAMETER_NAME, ' ', DATA_TYPE, CASE WHEN DATA_TYPE IN ('char','varchar') THEN CONCAT('(', CHARACTER_MAXIMUM_LENGTH, ')') ELSE '' END)) AS Parameters_In
        , CONCAT('returns ', GROUP_CONCAT(CASE WHEN PARAMETER_MODE IS NULL THEN CASE WHEN DATA_TYPE IN ('char','varchar') THEN CONCAT(DATA_TYPE, '(', CHARACTER_MAXIMUM_LENGTH, ')') ELSE DATA_TYPE END ELSE NULL END)) AS Parameters_Out
      FROM information_schema.PARAMETERS
      WHERE SPECIFIC_SCHEMA='${DBNAME}' AND SPECIFIC_NAME = '${funcname}'
      GROUP BY SPECIFIC_NAME
    ) P ON R.ROUTINE_NAME = P.SPECIFIC_NAME
    WHERE R.ROUTINE_SCHEMA = '${DBNAME}' AND R.ROUTINE_TYPE='FUNCTION' AND R.ROUTINE_NAME = '${funcname}'
  " | sed -e 's/\\n/\n/g' -e 's/\\t/\t/g' > ${BACKUPDIR_FUNC}/${funcname}.ddl
done
fi