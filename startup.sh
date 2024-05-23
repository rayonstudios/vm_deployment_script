set -v

REPO_URL="https://github.com/rayonstudios/vm_deployment_script.git"
NODE_VERSION="20.13.1"

# Install logging monitor. The monitor will automatically pick up logs sent to
# syslog.
curl -s "https://storage.googleapis.com/signals-agents/logging/google-fluentd-install.sh" | bash
source ~/.bashrc
service google-fluentd restart &

# Install dependencies from apt
apt-get update
apt-get install -yq ca-certificates git build-essential supervisor

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc

# Install nodejs
nvm install $NODE_VERSION

# Get the application source code from the Google Cloud Repository.
# git requires $HOME and it's not set during the startup script.
export HOME=/root
sudo apt install -yq git-all
rm -rf /opt/app/vm_deployment_script
git clone $REPO_URL /opt/app/vm_deployment_script

# Install app dependencies
cd /opt/app/vm_deployment_script
npm install

# Create a nodeapp user. The application will run as this user.
useradd -m -d /home/nodeapp nodeapp
chown -R nodeapp:nodeapp /opt/app

# Install pm2
npm install -g pm2@5.3.1

# build
npm run build

pm2 start ./dist/server.js --name vm_deployment_script

supervisorctl reread
supervisorctl update

# run the apps for the first time
# curl http://localhost:3001/deploy
# curl http://localhost:3001/deploy?env=production