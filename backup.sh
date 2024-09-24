#!/bin/bash

SOURCE_DIR="/home/ubuntu/code/"
DESTINATION_DIR="/home/ubuntu/backup/"
LOG_FILE="/home/ubuntu/backup/backup.log"
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
EMAIL="shivamkasaudhan266@gmail.com"

# Rsync command to backup files
rsync -avz --delete $SOURCE_DIR $DESTINATION_DIR >> $LOG_FILE 2>&1

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "$TIMESTAMP: BACKUP SUCCESSFUL" >> $LOG_FILE
    echo "Backup was successful at $TIMESTAMP" | mail -s "Backup Success" $EMAIL
else
    echo "$TIMESTAMP: BACKUP FAILED" >> $LOG_FILE
    echo "Backup failed at $TIMESTAMP" | mail -s "Backup Failed" $EMAIL
fi

