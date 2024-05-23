#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
REPO_URL="https://github.com/org/repo"
CLONE_DIR="./physikomatics_be_${$1}"

# Remove existing repo if present
rm -rf $CLONE_DIR

# Clone the repository
git clone $REPO_URL $CLONE_DIR

# Change to the repository directory
cd $CLONE_DIR

# Install dependencies
npm install

# Build the application
npm run build

# Install pm2
npm install -g pm2@5.3.1

# Run the application
port=3000
if [[$1 == "production" ]]; then port=80; fi
NODE_ENV="$1" PORT=$port pm2 start ./dist/server.js
