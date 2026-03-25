#!/bin/bash
# automation_loop.sh

DATA_DIR="crawler_data"
KAGGLE_USER="anshstreek"
DATASET_NAME="grim-training-data"

if [ ! -f "$DATA_DIR/dataset-metadata.json" ]; then
    mkdir -p $DATA_DIR
    kaggle datasets init -p $DATA_DIR
    
    sed -i "s/INSERT_TITLE_HERE/$DATASET_NAME/g" $DATA_DIR/dataset-metadata.json
    sed -i "s/INSERT_SLUG_HERE/$DATASET_NAME/g" $DATA_DIR/dataset-metadata.json
    
    kaggle datasets create -p $DATA_DIR
fi

echo "[$(date)] Step A: Starting UNLIMITED crawler in background..."
python smart_crawler.py &
CRAWLER_PID=$!

trap "echo 'Stopping crawler...'; kill $CRAWLER_PID; exit" INT TERM

while true; do
    echo "[$(date)] Crawler is running. Sleeping for 2 hours before next Kaggle push..."
    sleep 7200
    
    echo "[$(date)] Step B: Pushing new data to Kaggle Dataset..."
    kaggle datasets version -p $DATA_DIR -m "Automated data upload $(date)" --dir-mode zip
    
    echo "[$(date)] Step C: Triggering Kaggle GPU Training..."
    kaggle kernels push -p .
done
