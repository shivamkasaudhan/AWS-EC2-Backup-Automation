# AWS-EC2-Backup-Automation
This project automates the backup of a directory using `rsync` and sends email notifications upon successful or failed backups. The backups are scheduled using `crontab`, and an SMTP setup is configured for sending email alerts.

## Prerequisites

- An AWS EC2 instance (or any Linux server)
- SSH access to the instance
- Installed rsync tool for efficient file transfer
- Postfix for sending emails via SMTP
- A Google account with an app-specific password for email notifications

---

## Setup Instructions

### 1. Create an EC2 Instance
- Launch an AWS EC2 instance and name it “Backup_project”.
- Connect to your EC2 instance via SSH using the following command:
  
  ```bash
  ssh -i "backup_project.pem" ubuntu@<instance-public-dns>
  ```

### 2. Install rsync
- Install `rsync`, which is efficient for transferring files as it only copies the differences between the source and destination.
  
  ```bash
  sudo apt-get install rsync
  ```

### 3. Create a Backup Directory
- Create a directory named `backup` to store your backup script and log files.
  
  ```bash
  mkdir ~/backup
  ```

### 4. Create a Shell Script (backup.sh)
- Inside the `backup` directory, create a shell script named `backup.sh` to automate the backup process.
  
  ```bash
  nano ~/backup/backup.sh
  ```

- Add the necessary commands in `backup.sh`, including the username, IP, source, and destination directories.

Example script:

```bash
#!/bin/bash

SOURCE_DIR="/home/ubuntu/code/"
DESTINATION_DIR="/home/ubuntu/backup/"
LOG_FILE="/home/ubuntu/backup/backup.log"
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
EMAIL="your-email@gmail.com"

rsync -avz --delete $SOURCE_DIR $DESTINATION_DIR >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "$TIMESTAMP: BACKUP SUCCESSFUL" >> $LOG_FILE
    echo "Backup was successful at $TIMESTAMP" | mail -s "Backup Success" $EMAIL
else
    echo "$TIMESTAMP: BACKUP FAILED" >> $LOG_FILE
    echo "Backup failed at $TIMESTAMP" | mail -s "Backup Failed" $EMAIL
fi
```

### 5. Create a Directory for Backup
- Create the directory that you want to back up automatically. For this example, the directory is named `code`.

  ```bash
  mkdir ~/code
  ```

### 6. Schedule Automatic Backups Using crontab
- Use `crontab` to schedule automatic backups every day at 5:40 PM.

  ```bash
  crontab -e
  ```

- Add the following line to the crontab file to run the backup script daily at 5:40 PM:

  ```bash
  40 17 * * * /home/ubuntu/backup/backup.sh
  ```

### 7. Manual Backup Command
- If you want to manually view the crontab list or schedule, use:

  ```bash
  crontab -l
  ```

### 8. Log File
- After each backup (whether successful or failed), the log will be stored in `backup.log` located in the `backup` directory.

---

## Email Notification Setup (SMTP using Postfix)

### 9. Configure Postfix for Email Notifications
- In the `/etc/postfix` folder, change the method for SMTP protocol and set `inet_protocols` to `ipv4` only. Open `main.cf` and modify the configuration:

  ```bash
  sudo nano /etc/postfix/main.cf
  ```

- Add the following lines to configure Gmail SMTP:

  ```bash
  relayhost = [smtp.gmail.com]:587
  smtp_sasl_auth_enable = yes
  smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
  smtp_sasl_security_options = noanonymous
  smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
  smtp_use_tls = yes
  ```

### 10. Generate an App-Specific Password for Gmail
- Create a Google App-specific password for Gmail (since direct login using Gmail is not allowed). Use this password in the SMTP configuration.

### 11. Create the `sasl_passwd` File
- Create a file named `sasl_passwd` in the `/etc/postfix` folder to store your Gmail SMTP credentials:

  ```bash
  sudo nano /etc/postfix/sasl_passwd
  ```

- Add the following content to the `sasl_passwd` file (replace with your actual email and app-specific password):

  ```bash
  [smtp.gmail.com]:587 your-email@gmail.com:your-app-specific-password
  ```

- Secure the `sasl_passwd` file and postmap it:

  ```bash
  sudo chmod 600 /etc/postfix/sasl_passwd
  sudo postmap /etc/postfix/sasl_passwd
  ```

### 12. Restart Postfix
- Restart the Postfix service to apply the changes:

  ```bash
  sudo systemctl restart postfix
  ```

---

## Troubleshooting & Monitoring

### 13. Check Mail Logs
- Use the following command to monitor mail logs:

  ```bash
  sudo tail -f /var/log/mail.log
  ```

### 14. Check the Mail Queue
- Use the following command to check the mail queue list:

  ```bash
  postqueue -p
  ```

- To remove a particular mail from the queue by its post ID:

  ```bash
  postsuper -d post_id
  ```

- To remove all mails from the queue:

  ```bash
  postsuper -d all
  ```

---

## License
This project is licensed under the MIT License.
```

This is a comprehensive `README.md` file detailing the steps taken for setting up the automatic backup, configuring email notifications, and troubleshooting the setup.
