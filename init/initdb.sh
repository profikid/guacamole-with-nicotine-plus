#!/bin/sh

set -e

echo "Starting Guacamole database initialization..."

# Generate SQL script
if ! /opt/guacamole/bin/initdb.sh --postgresql > /tmp/initdb.sql; then
    echo "Failed to generate initdb.sql"
    exit 1
fi

echo "Generated initdb.sql successfully"

# Remove the copy step as it's causing permission issues and is unnecessary

# Wait for PostgreSQL to be ready
until PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOSTNAME -U $POSTGRES_USER -d $POSTGRES_DATABASE -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing script"

# Execute initdb.sql script
if ! PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOSTNAME -U $POSTGRES_USER -d $POSTGRES_DATABASE -f /tmp/initdb.sql; then
    echo "Failed to execute initdb.sql"
    exit 1
fi

echo "Executed initdb.sql successfully"

# Execute add_connection.sql script
if ! PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOSTNAME -U $POSTGRES_USER -d $POSTGRES_DATABASE -f /opt/guacamole/add_connection.sql; then
    echo "Failed to execute add_connection.sql"
    exit 1
fi

echo "Executed add_connection.sql successfully"
echo "Guacamole database initialization and connection setup completed"
