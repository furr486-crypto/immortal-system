#!/bin/bash

LOG="/var/log/guardian.log"
PREDICTIVE_MODEL="/root/ai_model.pkl"

echo "🧠 GUARDIAN AI ACTIVATED — PREDICTIVE WATCHDOG" | tee -a $LOG

# Simulasi AI training (real-nya pake data historis)
train_ai() {
    echo "Training AI model from logs..." | tee -a $LOG
    python3 -c "
import pandas as pd
import pickle
from sklearn.ensemble import RandomForestClassifier

# Simulasi data
data = pd.DataFrame({
    'cpu_usage': [10,20,30,40,50,60,70,80,90,95,99],
    'memory_usage': [20,30,40,50,60,70,80,85,90,95,99],
    'service_down': [0,0,0,0,0,0,0,0,1,1,1]
})
X = data[['cpu_usage','memory_usage']]
y = data['service_down']
model = RandomForestClassifier()
model.fit(X, y)
with open('$PREDICTIVE_MODEL', 'wb') as f:
    pickle.dump(model, f)
print('✅ AI Model Trained')
"
}

predict_failure() {
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    MEM=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
    
    PRED=$(python3 -c "
import pickle
import numpy as np
with open('$PREDICTIVE_MODEL', 'rb') as f:
    model = pickle.load(f)
X = np.array([[$CPU, $MEM]])
pred = model.predict(X)
print(pred[0])
")
    
    if [ "$PRED" -eq "1" ]; then
        echo "⚠️ AI PREDICTS FAILURE! Preemptive action taken." | tee -a $LOG
        /usr/local/bin/phoenix.sh --quick
    fi
}

# Train on startup
train_ai

# Watch loop
while true; do
    predict_failure
    
    # Cek semua services
    for svc in pterodactyl-panel wings mysql nginx redis-server docker; do
        if ! systemctl is-active --quiet $svc; then
            echo "🔴 $svc DOWN! Restarting..." | tee -a $LOG
            systemctl restart $svc
        fi
    done
    
    # Cek health endpoint panel
    if ! curl -s -o /dev/null http://localhost/health; then
        echo "🔴 Panel HEALTH FAIL! FULL REBUILD..." | tee -a $LOG
        /usr/local/bin/phoenix.sh --force
    fi
    
    sleep 300  # 5 menit
done
