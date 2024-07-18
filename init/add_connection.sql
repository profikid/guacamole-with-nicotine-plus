BEGIN;

-- Create default user "guacadmin" with password "guacadmin" if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM guacamole_entity WHERE name = 'guacadmin' AND type = 'USER') THEN
        INSERT INTO guacamole_entity (name, type) VALUES ('guacadmin', 'USER');
        INSERT INTO guacamole_user (entity_id, password_hash, password_salt, password_date)
        SELECT entity_id, x'CA458A7D494E3BE824F5E1E175A1556C0F8EEF2C2D7DF3633BEC4A29C4411960', -- 'guacadmin'
               x'FE24ADC5E11E2B25288D1704ABE67A79E342ECC26064CE69C5B3177795A82264',
               CURRENT_TIMESTAMP
        FROM guacamole_entity WHERE name = 'guacadmin';
    END IF;
END $$;

-- Grant this user all system permissions if not already granted
INSERT INTO guacamole_system_permission (entity_id, permission)
SELECT entity_id, permission::guacamole_system_permission_type
FROM (
    VALUES
        ('guacadmin', 'CREATE_CONNECTION'),
        ('guacadmin', 'CREATE_CONNECTION_GROUP'),
        ('guacadmin', 'CREATE_SHARING_PROFILE'),
        ('guacadmin', 'CREATE_USER'),
        ('guacadmin', 'ADMINISTER')
) permissions (username, permission)
JOIN guacamole_entity ON permissions.username = guacamole_entity.name AND guacamole_entity.type = 'USER'
WHERE NOT EXISTS (
    SELECT 1
    FROM guacamole_system_permission gsp
    WHERE gsp.entity_id = guacamole_entity.entity_id
    AND gsp.permission::text = permissions.permission
);

-- Create the Nicotine+ VNC connection
INSERT INTO guacamole_connection (connection_name, protocol)
VALUES ('Nicotine+', 'vnc');

-- Set the VNC connection parameters
DO $$
DECLARE
    connection_id INT;
BEGIN
    SELECT currval(pg_get_serial_sequence('guacamole_connection', 'connection_id')) INTO connection_id;

    INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
    VALUES
    (connection_id, 'hostname', 'alpine-client'),
    (connection_id, 'port', '5900'),
    (connection_id, 'password', 'password'),
    (connection_id, 'ignore-cert', 'true'),
    (connection_id, 'width', '1280'),
    (connection_id, 'height', '800');

    -- Grant the guacadmin user access to this connection
    INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
    SELECT guacamole_entity.entity_id, connection_id, permission::guacamole_object_permission_type
    FROM (
        VALUES
            ('guacadmin', 'READ'),
            ('guacadmin', 'UPDATE'),
            ('guacadmin', 'DELETE'),
            ('guacadmin', 'ADMINISTER')
    ) permissions (username, permission)
    JOIN guacamole_entity ON permissions.username = guacamole_entity.name AND guacamole_entity.type = 'USER';
END $$;

COMMIT;
