
#!/bin/bash

LOG="/var/log/backup-daemon.log"
BACKUP_TARGETS=(
    "/root/backup-repo"
    "s3://thaipuri-backup"
    "rsync://backup.thaipuri.my.id"
    "https://api.telegram.org/botTOKEN/sendDocument"
)

backup_to_all() {
    TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
    
    # Backup database
    mysqldump -u root -pThaipuriKing2847 --all-databases | gzip > /tmp/db_$TIMESTAMP.sql.gz
    
    # Backup config
    tar -czf /tmp/config_$TIMESTAMP.tar.gz /etc/pterodactyl /etc/nginx /etc/mysql
    
    # Backup wings
    tar -czf /tmp/wings_$TIMESTAMP.tar.gz /var/lib/pterodactyl
    
    # Kirim ke semua target
    for target in "${BACKUP_TARGETS[@]}"; do
        echo "📤 Sending to $target..." | tee -a $LOG
        # Implementasi per target
    done
    
    # Git backup
    cd /root/backup-repo
    cp /tmp/*.sql.gz ./
    cp /tmp/*.tar.gz ./
    git add .
    git commit -m "Auto backup $TIMESTAMP"
    git push origin main
}

# Loop tiap 4 jam
while true; do
    backup_to_all
    sleep 14400  # 4 jam
done
