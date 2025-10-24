#! /bin/ash
adduser -D -h /home/container container
chown -R container: /mnt/server/

# Ensure OpenSSL is installed
if ! command -v openssl >/dev/null 2>&1; then
    echo "Installing OpenSSL..."
    apk add --no-cache openssl
fi

# Ensure cURL is installed
if ! command -v curl >/dev/null 2>&1; then
    echo "Installing cURL..."
    apk add --no-cache curl
fi

# Initialize PostgreSQL with scram-sha-256
su container -c 'initdb -D /mnt/server/postgres_db/ -A scram-sha-256 -U "$PGUSER" --pwfile=<(echo "$PGPASSWORD")'

mkdir -p /mnt/server/postgres_db/run/

# Generate SSL certificate if missing
SSL_DIR="/mnt/server/postgres_db"
SSL_KEY="$SSL_DIR/server.key"
SSL_CERT="$SSL_DIR/server.crt"

if [ ! -f "$SSL_CERT" ] || [ ! -f "$SSL_KEY" ]; then
    echo "Generating self-signed SSL certificate..."
    
    openssl req -new -x509 -days 365 -nodes -subj "/CN=postgres" \
        -keyout "$SSL_KEY" -out "$SSL_CERT"

    chmod 600 "$SSL_KEY" # Required for PostgreSQL
    chmod 644 "$SSL_CERT"
    
    SSL_DIR="/home/container/postgres_db"
    SSL_KEY="$SSL_DIR/server.key"
    SSL_CERT="$SSL_DIR/server.crt"

    echo "SSL certificate generated."
fi

# Configure postgresql.conf to use SSL
POSTGRESQL_CONF="/mnt/server/postgres_db/postgresql.conf"
if ! grep -q "ssl = on" "$POSTGRESQL_CONF"; then
    echo "ssl = on" >> "$POSTGRESQL_CONF"
    echo "ssl_cert_file = '$SSL_CERT'" >> "$POSTGRESQL_CONF"
    echo "ssl_key_file = '$SSL_KEY'" >> "$POSTGRESQL_CONF"
    echo "password_encryption = scram-sha-256" >> "$POSTGRESQL_CONF"
fi

# Configure pg_hba.conf
PG_HBA="/mnt/server/postgres_db/pg_hba.conf"
cat <<EOF > "$PG_HBA"
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# Allow local PgBouncer connection
host    all             all             127.0.0.1/32            md5

# Allow all local connections (no password)
local   all             all                                     trust

# Allow external connections with SSL + scram-sha-256
hostssl all             all             0.0.0.0/0               scram-sha-256
hostssl all             all             ::/0                    scram-sha-256
EOF

echo "PostgreSQL setup complete."

# ==========================
# Setup PgBouncer
# ==========================

# Ensure PgBouncer is installed
echo "Installing PgBouncer..."
apk add --no-cache pgbouncer

pgbouncer --version

mkdir -p /mnt/server/pgbouncer

# Create PgBouncer config
cat <<EOF > /mnt/server/pgbouncer/pgbouncer.ini
[databases]
* = host=127.0.0.1 port=5432

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 6543
auth_type = scram-sha-256
auth_file = /home/container/pgbouncer/userlist.txt
admin_users = postgres
pool_mode = transaction
max_client_conn = 100
default_pool_size = 20
reserve_pool_size = 5
reserve_pool_timeout = 3
server_reset_query = DISCARD ALL
server_idle_timeout = 30
log_connections = 1
log_disconnections = 1
pidfile = /home/container/pgbouncer/pgbouncer.pid
client_tls_sslmode = require
client_tls_key_file = /home/container/postgres_db/server.key
client_tls_cert_file = /home/container/postgres_db/server.crt
EOF

curl -fsSL https://raw.githubusercontent.com/enum314/pterodactyl-files/refs/heads/main/eggs/postgres/userlist.sh -o /mnt/server/userlist.sh

echo "PgBouncer setup complete on port 6543."