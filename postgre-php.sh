#!/usr/bin/env bash
set -e

# Configuration (change these as needed)
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="myphpdb"
DB_USER="myphpuser"
DB_PASSWORD="changeme"   # Change to a secure password in production
ADMIN_PASSWORD="af3"      # Change to a secure password in production

# Check if config.php already exists
if [ -f config.php ]; then
    echo "config.php file already exists. Aborting to prevent overwriting."
    exit 1
fi

echo "=== Automated Installation Starting for PHP App ==="

# Ensure db.sql is present
if [ ! -f db.sql ]; then
    echo "db.sql file not found. Please provide a db.sql script to set up the database schema."
    exit 1
fi

echo "Creating PostgreSQL user and database..."
# Check if the user exists
USER_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'")
if [ "${USER_EXISTS}" != "1" ]; then
    sudo -u postgres createuser "${DB_USER}"
    sudo -u postgres psql -c "ALTER USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';"
fi

# Check if the database exists
DB_EXISTS=$(sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -w "${DB_NAME}" || true)
if [ -z "${DB_EXISTS}" ]; then
    sudo -u postgres createdb -O "${DB_USER}" "${DB_NAME}"
fi

echo "Database and user created or already exist."

echo "Generating config.php file..."
cat > config.php <<EOF
<?php
// Generated configuration file for the PHP application

// Database connection details
\$DATABASE_URL = "postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}";

// Admin password for the admin panel
\$ADMIN_PASSWORD = "${ADMIN_PASSWORD}";
EOF

chmod 600 config.php
echo "config.php file created."

echo "Running db.sql to set up schema..."
export PGPASSWORD="${DB_PASSWORD}"
psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -f db.sql

echo "Database schema and seed data loaded."
echo "=== Installation Complete ==="
echo "Your PHP application can now include 'config.php' to access the database credentials."
echo "For example, in your PHP code:"
echo "    require_once __DIR__ . '/config.php';"
echo "Then you can use \$DATABASE_URL and \$ADMIN_PASSWORD within your PHP application."
