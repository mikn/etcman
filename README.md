# etcman
etcman: A Git-based system for managing /etc configurations and tracking manually installed packages on Debian-based systems.

```
 _____   _____   _____ __  __          _   _ 
| ____| |_   _| / ____|  \/  |   /\   | \ | |
|  _|     | |  | |    | \  / |  /  \  |  \| |
| |___    | |  | |    | |\/| | / /\ \ | . ` |
|_____|   |_|   \_____|_|  |_|/_/  \_\|_|\__|
```

Streamlined Git-based system for managing /etc configurations and tracking manually installed packages on individual Debian-based systems.

## Motivation

Configuration management and package tracking on Linux systems often involve complex, declarative tools that can be overkill for managing individual machines. etcman was created to provide a simpler, more direct approach:

- Directly version control your /etc directory
- Track manually installed packages without extra steps
- Maintain your usual workflow of editing files directly on the machine
- Easily backup your system configuration to a remote repository

etcman eliminates the need to copy files back and forth between a management repository and your system. Instead, you work directly in /etc, committing changes once they're working. This approach provides a straightforward backup mechanism for your system configuration, allowing easy recovery if the machine is lost.

## Who is this for?

etcman is designed for:

- Linux users who want a simple way to track changes to their system configuration
- System administrators managing individual Debian-based machines
- Anyone who finds tools like Ansible or Puppet too complex for their needs
- Users who prefer working directly on their system rather than managing configurations externally
- Those who want an easy way to backup and potentially restore their system configuration

If you've ever thought, "I just want to edit my config files and commit them without all the extra steps," etcman is for you.

## Features

- Direct Git-based version control for /etc
- Selective package tracking (manual installs/removals only)
- Simple backup and potential restore mechanism for system configurations
- Configurable debug logging
- APT hook integration for automatic package tracking

## Quick Start

1. Clone the repository:
   ```
   git clone https://github.com/mikn/etcman.git
   ```

2. Install etcman:
   ```
   cd etcman
   sudo make install
   ```

3. Use `etcman` to manage your /etc:
   ```
   sudo etcman status
   sudo etcman add /etc/some_config_file
   sudo etcman commit -m "Updated some_config_file"
   ```

4. View tracked packages:
   ```
   cat /etc/etcman/package-list.conf
   ```

5. Push your changes to a remote backup:
   ```
   sudo etcman push origin main
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
