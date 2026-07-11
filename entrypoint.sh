#!/bin/bash

echo "🔥🔥🔥 IMMORTAL SYSTEM ACTIVATED 🔥🔥🔥"
echo "NEO-TOKYO 2847 — PTERODACTYL LEVEL 100"
echo "MODE: $IMMORTAL_MODE"

# Start semua services
service ssh start
service cron start

# Jalankan semua daemon di background
/usr/local/bin/guardian.sh &
/usr/local/bin/oracle.sh &
/usr/local/bin/backup-daemon.sh &

# Jalankan Phoenix (self-rebuild)
if [ ! -f /root/.phoenix_done ]; then
    /usr/local/bin/phoenix.sh
    touch /root/.phoenix_done
fi

# Jalankan Hydra (multi-cloud failover)
/usr/local/bin/hydra.sh &

# Keep alive dengan necromancer
while true; do
    /usr/local/bin/necromancer.sh
    sleep 60
done
