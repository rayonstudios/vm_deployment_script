#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# move to home path
cd ~

# Variables
CLONE_DIR="./physikomatics_be_$1"

# Remove existing repo if present
rm -rf $CLONE_DIR

# Clone the repository
git clone "$2" $CLONE_DIR

# Change to the repository directory
cd $CLONE_DIR

# Install dependencies
npm install

# Build the application
npm run build

# set the application
port=3000
if [[$1 == "production" ]]; then port=80; fi

# Start/Restart the application
pm2 stop "physikomatics_be_$1"
NODE_ENV="$1" PORT=$port pm2 start ./dist/server.js --name "physikomatics_be_$1"
