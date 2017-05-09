######################################################
#                                                    #
#  Database DDL Backup                              #
#                                                    #
######################################################
#!/bin/bash
SCRIPTPATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
log_file=${SCRIPTPATH}/log_ddl_backup.log

BackupEnv=$1
# env in dev prod prior uat
case "$BackupEnv" in
"dev")
  sdmspath=/projects/sdms/dev
  ;;
"prod")
  sdmspath=/projects/sdms/prod
  ;;
"prior")
  sdmspath=/projects/sdms/prior
  ;;
"uat")
  sdmspath=/projects/sdms/uat_automation
  ;;
*)
  echo "Acceptable Values for env param are: dev prod prior uat"
  exit 1
  ;;
esac

OUTPUTPATH=${SCRIPTPATH}/DDL/${BackupEnv}
if [[ ! -d ${OUTPUTPATH} ]]; then
  mkdir -p ${OUTPUTPATH}
fi
. ${sdmspath}/sdms_setenv.ksh

echo "Start to Backup At ${BackupEnv}">${log_file}
rm ${OUTPUTPATH}/*.ddl

SchemaList="SDMS SDMS_TEMP"

for schema_item in ${SchemaList}; do
  db2 "connect to ${sdmsdbname} user ${sdmsuser} using ${sdmspasswd}"
  if [[ $? -ne 0 ]]; then
    echo "Connect to ${sdmsdbname} Failed!" | tee -a ${log_file}
    exit 1
  fi
  db2 -x "SELECT TABLE_NAME FROM SYSIBM.TABLES WHERE TABLE_SCHEMA = '${schema_item}' ORDER BY TABLE_NAME" | sed -n 's/\s\s*//gp' | while read table_item; do
    echo "Generating Table: ${schema_item}.${table_item}" | tee -a ${log_file}
    db2look -d ${sdmsdbname} -e -x -z ${schema_item} -t ${table_item} -i ${sdmsuser} -w ${sdmspasswd} -o ${OUTPUTPATH}/${schema_item}.${table_item}.ddl > /dev/null 2>>${log_file}
  done
  db2 terminate
done
echo "Backup Finished!"