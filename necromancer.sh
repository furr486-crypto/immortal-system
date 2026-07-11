
#!/bin/bash

LOG="/var/log/necromancer.log"
HEARTBEAT_URL="https://heartbeat.railway.app/thaipuri"

echo "💀 NECROMANCER ACTIVATED — RESURRECTION READY" | tee -a $LOG

resurrect() {
    echo "☠️ SYSTEM DETECTED DEAD. RESURRECTING..." | tee -a $LOG
    
    # Kill semua yang stuck
    killall -9 panel wings 2>/dev/null
    
    # Force restart services
    systemctl restart docker
    systemctl restart mysql
    systemctl restart nginx
    systemctl restart redis-server
    
    # Rebuild wings
    nohup /usr/local/bin/phoenix.sh --quick &
}

# Cek heartbeat
send_heartbeat() {
    curl -s -X POST $HEARTBEAT_URL \
         -H "Content-Type: application/json" \
         -d '{"status": "alive", "timestamp": "'$(date -Iseconds)'"}' \
         > /dev/null 2>&1
}

# Main loop
while true; do
    send_heartbeat
    
    # Cek apakah system mati total
    if ! systemctl is-active --quiet pterodactyl-panel && \
       ! systemctl is-active --quiet wings; then
        resurrect
    fi
    
    # Cek disk space
    USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ $USAGE -gt 90 ]; then
        echo "⚠️ DISK SPACE CRITICAL! Cleaning..." | tee -a $LOG
        docker system prune -f
        apt autoremove -y
    fi
    
    sleep 60
done
