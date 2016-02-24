#!/bin/bash


read -p "Please input Path: " Path
read -p "Please input interval:(min) " INTERVAL

SCRIPT_NAME=`echo $Path | awk -F "/" '{print $NF}'`
info="
#!/bin/bash\n
#description $Path Backup Script\n

BACKUP_SERVER=\"backup.sa.beyond.com\"\n
HOSTNAME=\`hostname\`\n
MODULE=\"Backup\"\n
USER=backup\n
PASSWORD_FILE=/data/script/backup_lib/passwd\n
LOCAL_FILE=$Path\n
DATE=\`date +%Y%m%d%H%M\`\n
REMOTE_NAME=\`echo \$LOCAL_FILE | awk -F \"/\" '{print \$NF}'\`\n
LOG=./backup.log\n
/usr/bin/rsync -avzP \${LOCAL_FILE} backup@\${BACKUP_SERVER}::\$MODULE/\$HOSTNAME/\${REMOTE_NAME}_\$DATE/ --password-file=\${PASSWORD_FILE} >> \$LOG\n
"

echo -e  $info > bak_${SCRIPT_NAME}.sh

echo "*/$INTERVAL * * * * root /bin/bash /data/script/backup_lib/bak_${SCRIPT_NAME}.sh > /dev/null 2>&1"  >> /etc/cron.d/backup
