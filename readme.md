# Guacamole with Nicotine+ Client

This project sets up a Guacamole server with an Alpine Linux-based VNC client running Nicotine+ (a Soulseek client) in fullscreen mode. The entire setup is containerized using Docker and orchestrated with Docker Compose.

## Prerequisites

- Docker
- Docker Compose

## Setup

1. Clone this repository:
   ```
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Build and start the containers:
   ```
   docker-compose up -d --build
   ```

3. Access Guacamole at `http://localhost:8080/guacamole/`

4. Log in with the default credentials:
   - Username: guacadmin
   - Password: guacadmin

5. The Nicotine+ VNC connection should be preconfigured and available.

## Usage

1. After logging in, click on the "Nicotine+" connection to connect to the Nicotine+ client.

2. Nicotine+ will start automatically in fullscreen mode.

3. Configure Nicotine+ with your Soulseek credentials and desired settings.

## Notes

- The VNC password is set to "password". Change this in the Dockerfile and initdb.sql for better security.
- Nicotine+ uses ports 2234-2239 by default. These are exposed in the Docker Compose file.
- This setup is for demonstration purposes. In a production environment, implement proper security measures.
- Nicotine+ is installed in a Python virtual environment within an Alpine Linux container.

## Legal Considerations

Using Soulseek and similar P2P networks may have legal implications depending on your jurisdiction and the content you're sharing. Ensure you comply with all relevant laws and regulations.

## Troubleshooting

If you encounter issues:
1. Check Docker logs: `docker-compose logs`
2. Ensure all ports are correctly mapped and not in use by other services.
3. Verify your firewall settings allow the required connections.
4. If Nicotine+ doesn't start, try connecting to the VNC session and starting it manually to see any error messages.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).