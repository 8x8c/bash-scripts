#!/usr/bin/env bash
set -e

sudo apt update
sudo apt install -y mariadb-server expect

# Start and enable the service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Run mysql_secure_installation non-interactively
SECURE_MARIA=$(expect -c "
set timeout 10
spawn sudo mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"\r\"

expect \"Set root password?\"
send \"Y\r\"
expect \"New password:\"
send \"SuperSecurePassword\r\"
expect \"Re-enter new password:\"
send \"SuperSecurePassword\r\"

expect \"Remove anonymous users?\"
send \"Y\r\"

expect \"Disallow root login remotely?\"
send \"Y\r\"

expect \"Remove test database and access to it?\"
send \"Y\r\"

expect \"Reload privilege tables now?\"
send \"Y\r\"

expect eof
")

echo "$SECURE_MARIA"
