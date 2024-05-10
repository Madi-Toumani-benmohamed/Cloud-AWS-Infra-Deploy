#!/bin/bash  
  
touch new_infra.tf  
  
for A in $(cat infra.csv)  
do  
 ITEM_TYPE=$(echo $A | cut -d";" -f1)  
 ITEM_NAME=$(echo $A | cut -d";" -f2)  
 ITEM_PARAMS=$(echo $A | cut -d";" -f3)  
  
 TFILE=templates/${ITEM_TYPE}.template  
 if [ ! -f ${TFILE} ]  
 then  
  echo "Le template ${ITEM_TYPE} est manquant"  
  continue  
 fi  
  
 echo "Il faut creer un ${ITEM_TYPE} qui s'appelle ${ITEM_NAME} avec les options ${ITEM_PARAMS}"  
  
 NB_PARAMS=$(cat ${TFILE} | sed 's|<###|\n|g' | sed 's|###>|\n|g' | grep PARAM_ | sort | uniq | wc -l)  
  
 cat ${TFILE} >> new_infra.tf
 echo >> new_infra.tf  
 sed -i "s|<###ITEM_NAME###>|${ITEM_NAME}|g" new_infra.tf  
  
 for B in $(seq 1 ${NB_PARAMS})  
 do  
  CURRENT_PARAM=$(echo ${ITEM_PARAMS} | cut -d"#" -f ${B})  
  sed -i "s|<###PARAM_${B}###>|${CURRENT_PARAM}|g" new_infra.tf  
 done  
  
done