--
-- Create default user "guacadmin" with password "guacadmin"
--

INSERT INTO guacamole_entity (name, type) VALUES ('guacadmin', 'USER');
INSERT INTO guacamole_user (entity_id, password_hash, password_salt, password_date)
SELECT entity_id, x'CA458A7D494E3BE824F5E1E175A1556C0F8EEF2C2D7DF3633BEC4A29C4411960', -- 'guacadmin'
       x'FE24ADC5E11E2B25288D1704ABE67A79E342ECC26064CE69C5B3177795A82264',
       CURRENT_TIMESTAMP
FROM guacamole_entity WHERE name = 'guacadmin';

--
-- Grant this user all system permissions
--

INSERT INTO guacamole_system_permission (entity_id, permission)
SELECT entity_id, permission
FROM (
    VALUES
        ('guacadmin', 'CREATE_CONNECTION'),
        ('guacadmin', 'CREATE_CONNECTION_GROUP'),
        ('guacammin', 'CREATE_SHARING_PROFILE'),
        ('guacadmin', 'CREATE_USER'),
        ('guacadmin', 'ADMINISTER')
) permissions (username, permission)
JOIN guacamole_entity ON permissions.username = guacamole_entity.name AND guacamole_entity.type = 'USER';

--
-- Create the Nicotine+ VNC connection
--

INSERT INTO guacamole_connection (connection_name, protocol)
VALUES ('Nicotine+', 'vnc');

--
-- Set the VNC connection parameters
--

INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT connection_id, 'hostname', 'alpine-client'
FROM guacamole_connection
WHERE connection_name = 'Nicotine+';

INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT connection_id, 'port', '5900'
FROM guacamole_connection
WHERE connection_name = 'Nicotine+';

INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT connection_id, 'password', 'password'
FROM guacamole_connection
WHERE connection_name = 'Nicotine+';

--
-- Grant the guacadmin user access to this connection
--

INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
SELECT guacamole_entity.entity_id, guacamole_connection.connection_id, permission
FROM (
    VALUES
        ('guacadmin', 'READ'),
        ('guacadmin', 'UPDATE'),
        ('guacadmin', 'DELETE'),
        ('guacadmin', 'ADMINISTER')
) permissions (username, permission)
JOIN guacamole_entity ON permissions.username = guacamole_entity.name AND guacamole_entity.type = 'USER'
JOIN guacamole_connection ON guacamole_connection.connection_name = 'Nicotine+';
