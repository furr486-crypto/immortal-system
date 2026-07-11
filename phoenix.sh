
#!/bin/bash

LOG="/var/log/phoenix.log"
GITHUB_REPO="https://github.com/thaipuri/immortal-backup.git"
BACKUP_DIR="/root/immortal-backup"

echo "🔥 PHOENIX RISING — SELF-REBUILD ACTIVATED" | tee -a $LOG

rebuild_full() {
    echo "🔥 FULL REBUILD STARTED" | tee -a $LOG
    
    # Clone backup terakhir
    rm -rf $BACKUP_DIR
    git clone $GITHUB_REPO $BACKUP_DIR
    
    # Restore database
    if [ -f "$BACKUP_DIR/backups/db_latest.sql" ]; then
        mysql -u root -pThaipuriKing2847 < $BACKUP_DIR/backups/db_latest.sql
    fi
    
    # Restore configs
    if [ -d "$BACKUP_DIR/configs" ]; then
        cp -r $BACKUP_DIR/configs/* /etc/
    fi
    
    # Reinstall panel
    bash <(curl -s https://pterodactyl-installer.se) <<EOF
0
y
y
y
y
y
y
root
ThaipuriKing2847
panel
localhost
http://localhost
y
admin@panel.com
admin
admin123
y
EOF
    
    # Reinstall wings
    bash <(curl -s https://pterodactyl-installer.se) <<EOF
1
y
y
http://localhost
asdqwe123
y
EOF
    
    # Start all services
    systemctl restart mysql nginx redis-server pterodactyl-panel wings
    
    echo "✅ PHOENIX REBUILD COMPLETE" | tee -a $LOG
}

quick_rebuild() {
    echo "⚡ QUICK REBUILD — Panel only" | tee -a $LOG
    systemctl restart pterodactyl-panel
    systemctl restart wings
}

case "$1" in
    --force)
        rebuild_full
        ;;
    --quick)
        quick_rebuild
        ;;
    *)
        rebuild_full
        ;;
esac
