FROM guacamole/guacamole

# Switch to root to install packages
USER root

# Install PostgreSQL client
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Copy the initialization script
COPY add_connection.sql ./add_connection.sql
RUN chmod +x ./add_connection.sql
COPY initdb.sh ./initdb.sh
RUN chmod +x ./initdb.sh

# Switch back to the default user
USER guacamole

CMD ["/bin/sh", "-c", "./initdb.sh"]
