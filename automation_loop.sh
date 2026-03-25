#!/bin/bash
# automation_loop.sh

DATA_DIR="crawler_data"
KAGGLE_USER="yourusername"
DATASET_NAME="llm-raw-text-corpus"

if [ ! -f "$DATA_DIR/dataset-metadata.json" ]; then
    mkdir -p $DATA_DIR
    kaggle datasets init -p $DATA_DIR
    
    sed -i "s/INSERT_TITLE_HERE/$DATASET_NAME/g" $DATA_DIR/dataset-metadata.json
    sed -i "s/INSERT_SLUG_HERE/$DATASET_NAME/g" $DATA_DIR/dataset-metadata.json
    
    kaggle datasets create -p $DATA_DIR
fi

echo "[$(date)] Starting UNLIMITED crawler in background..."
python smart_crawler.py &
CRAWLER_PID=$!

trap "echo 'Stopping crawler...'; kill $CRAWLER_PID; exit" INT TERM

while true; do
    sleep 7200
    echo "[$(date)] Pushing new data to Kaggle..."
    kaggle datasets version -p $DATA_DIR -m "Automated data upload $(date)" --dir-mode zip
done
