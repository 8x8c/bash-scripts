#!/usr/bin/env bash
set -e

# Configuration variables (CHANGE THESE TO SECURE VALUES)
ROOT_PASSWORD="RootSecurePassword123!"
DB_NAME="myappdb"
DB_USER="myappuser"
DB_USER_PASSWORD="UserSecurePassword123!"

# Update and install MariaDB and expect
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
send \"${ROOT_PASSWORD}\r\"
expect \"Re-enter new password:\"
send \"${ROOT_PASSWORD}\r\"

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

# Now that root password is set, create the database and user
echo "Creating database and user..."
echo "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" | mysql -u root -p"${ROOT_PASSWORD}"
echo "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_USER_PASSWORD}';" | mysql -u root -p"${ROOT_PASSWORD}"
echo "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';" | mysql -u root -p"${ROOT_PASSWORD}"
echo "FLUSH PRIVILEGES;" | mysql -u root -p"${ROOT_PASSWORD}"

# Load the schema from db.sql
if [ -f db.sql ]; then
    echo "Loading schema from db.sql into ${DB_NAME}..."
    mysql -u root -p"${ROOT_PASSWORD}" "${DB_NAME}" < db.sql
    echo "Schema loaded successfully."
else
    echo "db.sql not found, skipping schema load. Please provide db.sql to set up the database schema."
fi

echo "Installation and setup complete."
