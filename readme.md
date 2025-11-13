# Google Cloud Shell WireGuard VPN

This script is designed to help you connect to a WireGuard VPN from within a Google Cloud Shell environment. It handles the necessary package installations and network configurations to establish a secure connection.

## How it Works

The `vpn.sh` script automates the process of:

1.  **Installing Dependencies:** It installs `wireguard-tools` and `resolvconf` using `apt-get`.
2.  **Configuration:** It copies your `vpn.conf` file to the appropriate system directory.
3.  **Connection:** It establishes the WireGuard connection using `wg-quick`.
4.  **Cleanup:** It provides a way to disconnect and securely remove your configuration and keys from the environment.

## Setup

1.  **Upload your VPN Configuration:** Place your `vpn.conf` file in the same directory as the `vpn.sh` script.
2.  **Edit `vpn.conf`:** Open your `vpn.conf` file and ensure the `DNS` line is commented out. This is crucial for the script to work in the Cloud Shell environment.

    ```
    [Interface]
    PrivateKey = YOUR_PRIVATE_KEY
    Address = YOUR_WIREGUARD_IP
    # DNS = 1.1.1.1  <-- Make sure this line starts with a '#'
    ```

## Usage

### Connect to the VPN

To connect to your VPN, run the following command:

```bash
./vpn.sh on
```

The script will then:

1.  Install the required packages.
2.  Set up the WireGuard interface.
3.  Connect to your VPN server.
4.  Show the connection status.

### Check the Connection Status

To check the status of your VPN connection at any time, run:

```bash
./vpn.sh status
```

This will show you the current WireGuard interface status, including data transfer and the latest handshake.

### Disconnect from the VPN

When you are finished using the VPN, you should disconnect by running:

```bash
./vpn.sh off
```

This command will:

1.  Disconnect from the VPN.
2.  **Securely delete** the `/etc/wireguard/wg0.conf` file, which contains your private key.

## Important Security Considerations

**Your `vpn.conf` file contains your private key, which is a secret and should be handled with care.**

1.  **Remove Your `vpn.conf` File:** After you are finished with your session and have run `./vpn.sh off`, you should also **delete your `vpn.conf` file** from the Cloud Shell environment. This ensures your private key is not left on the machine.

2.  **Disable Keys on Your VPN Server:** For the highest level of security, you should **disable the keys for your Cloud Shell client on your WireGuard server** when you are not using them. This way, even if you forget to remove your `vpn.conf` file, the keys cannot be used to access your VPN.

By following these steps, you can securely connect to your WireGuard VPN from a Google Cloud Shell environment.
