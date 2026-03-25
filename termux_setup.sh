#!/bin/bash
# termux_setup.sh

pkg update -y && pkg upgrade -y
pkg install python python-dev clang libxml2 libxslt libffi openssl git -y
pip install --upgrade pip
pip install requests trafilatura beautifulsoup4 kaggle cloudscraper

mkdir -p ~/.kaggle
echo "===================================================="
echo "SETUP COMPLETE."
echo "ACTION REQUIRED: Place your kaggle.json in ~/.kaggle/"
echo "Then run: chmod 600 ~/.kaggle/kaggle.json"
echo "===================================================="
