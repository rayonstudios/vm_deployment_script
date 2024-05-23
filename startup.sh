set -v

REPO_URL="https://github.com/org/repo"
NODE_VERSION="20.13.1"
USER="thetrendshakers"

# Install logging monitor. The monitor will automatically pick up logs sent to
# syslog.
curl -s "https://storage.googleapis.com/signals-agents/logging/google-fluentd-install.sh" | bash
source ~/.bashrc
service google-fluentd restart &

# Install dependencies from apt
apt-get update
apt-get install -yq ca-certificates git build-essential

# Clone vm_deployment_script repo
# git requires $HOME and it's not set during the startup script.
export HOME=/root
apt install -yq git-all
rm -rf /opt/app/vm_deployment_script
git clone "https://github.com/rayonstudios/vm_deployment_script.git" /opt/app/vm_deployment_script
cd /opt/app/vm_deployment_script

# Install nvm
sudo -u $USER curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
sudo -u $USER source ~/.bashrc

# Install nodejs
sudo -u $USER nvm install $NODE_VERSION

# Create .env with REPO_URL secret
echo "REPO_URL=$REPO_URL" > ./.env

# Install app dependencies
sudo -u $USER npm install

# Install pm2
sudo -u $USER npm install -g pm2@5.3.1

# build
sudo -u $USER npm run build

sudo -u $USER pm2 start -f ./dist/server.js --name vm_deployment_script

# run the apps for the first time
curl http://localhost:3001/deploy
# curl http://localhost:3001/deploy?env=production