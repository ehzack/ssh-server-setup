# SSH Server Setup Script

Simplify your workflow with key-based SSH access! This script automatically sets up your remote server so that, once configured, you can connect without entering a password. After running the setup, simply use:

```bash
ssh {serverName}
```

Replace `{serverName}` with the alias you chose during setup, and enjoy an automatic, secure login.

## Features

- **Single SSH Key:**  
  Utilizes one RSA key pair for all servers.
- **Automatic SSH Config:**  
  Adds or updates your SSH configuration file so you can connect via server aliases.
- **Key Deployment:**  
  Automatically copies your public key to the target server if key-based authentication is not already set up.
- **Portability:**  
  Designed to work on both macOS and Linux.

## Requirements

- **Bash**
- **ssh, ssh-keygen,** and **ssh-copy-id** (usually available on Unix-like systems)

## Installation

1. **Clone this repository:**

   ```bash
   git clone https://github.com/ehzack/ssh-server-setup.git
   cd ssh-server-setup
   ```

2. **Make the script executable:**

   ```bash
   chmod +x setup_ssh.sh
   ```

## Usage

Run the script with the following parameters:

```bash
./setup_ssh.sh <server_alias> <server_ip> <username>
```

After running the script:

- A new RSA key pair is generated (if not already available).
- Your public key is deployed to the server.
- Your SSH configuration is updated so that you can simply type:

  ```bash
  ssh <server_alias>
  ```

to log in automatically without a password.

## How It Works

1. **SSH Key Generation:**  
   The script checks for an existing RSA key (`~/.ssh/server_id_rsa`). If it doesn't exist, a new 4096-bit RSA key pair is created.
2. **Public Key Deployment:**  
   It uses `ssh-copy-id` to copy your public key to the remote server, enabling key-based authentication.
3. **SSH Config Update:**  
   An entry is added or updated in your `~/.ssh/config` file that maps your server alias to the server's hostname, username, key file, and port.

## Contributing

Contributions, bug reports, and feature requests are welcome! Please open an issue or submit a pull request via [GitHub Issues](https://github.com/ehzack/ssh-server-setup/issues).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
