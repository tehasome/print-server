# How to install
1. curl -O https://raw.githubusercontent.com/tehasome/print-server/main/install.sh
2. bash install.sh


# How to stop pm2
## stop for name
pm2 stop print-monitor

## stop for id
pm2 list
pm2 stop 0


# install node last version
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# install redis
sudo apt install redis -y