
#!/bin/bash

LOG="/var/log/oracle.log"
PREDICT_FILE="/root/predictions.json"

echo "🔮 ORACLE ACTIVATED — PREDICTING THE FUTURE" | tee -a $LOG

# Kumpulkan metrics
collect_metrics() {
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    MEM=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
    DISK=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1)
    
    echo "{\"cpu\":$CPU,\"memory\":$MEM,\"disk\":$DISK,\"load\":$LOAD}" > $PREDICT_FILE
}

# Predict failure time
predict() {
    CPU=$(cat $PREDICT_FILE | jq '.cpu')
    MEM=$(cat $PREDICT_FILE | jq '.memory')
    DISK=$(cat $PREDICT_FILE | jq '.disk')
    
    # Rule-based prediction (ganti dengan ML real)
    if [ $CPU -gt 90 ] || [ $MEM -gt 85 ] || [ $DISK -gt 80 ]; then
        echo "⚠️ FAILURE PREDICTED IN 15-30 MINUTES!" | tee -a $LOG
        echo "🔄 Preemptive action taken." | tee -a $LOG
        /usr/local/bin/phoenix.sh --quick
    fi
}

# Loop
while true; do
    collect_metrics
    predict
    sleep 120  # 2 menit
done
