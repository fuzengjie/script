#!/bin/bash
 #description /data/repo Backup Script
 BACKUP_SERVER="backup.sa.beyond.com"
 HOSTNAME=`hostname`
 MODULE="Backup"
 USER=backup
 PASSWORD_FILE=/data/script/backup_lib/passwd
 LOCAL_FILE=/data/repo
 DATE=`date +%Y%m%d%H%M`
 REMOTE_NAME=`echo $LOCAL_FILE | awk -F "/" '{print $NF}'`
 LOG=/data/logs/backup.log
 /usr/bin/rsync -avzP --bwlimit=1000 ${LOCAL_FILE} backup@${BACKUP_SERVER}::$MODULE/$HOSTNAME/${REMOTE_NAME}_$DATE/ --password-file=${PASSWORD_FILE} >> $LOG

