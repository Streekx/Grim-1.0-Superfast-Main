#!/bin/bash
# start_training.sh

echo "Triggering Kaggle GPU Training in the Cloud..."
kaggle kernels push -p .
echo "Cloud training job submitted successfully!"
