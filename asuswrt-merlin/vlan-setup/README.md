# ASUSWRT-Merlin VLAN Setup Scripts

This directory contains scripts and configuration files to help set up VLANs on various ASUSWRT-Merlin supported routers. These scripts are tailored for different router models and are intended to automate and simplify VLAN configuration, especially for advanced networking setups such as AiMesh, guest networks, and custom VLAN bridging.

## Directory Structure

- **AC3100/**
  - `RT-AC3100.sh`: VLAN setup script for the RT-AC3100 router.
  - `services-start`: Custom startup script for VLAN configuration.
  - `README.md`: Model-specific notes and instructions.
- **AC55/**
  - `AC55.sh`: VLAN setup script for the AC55 router.
- **AC68U/**
  - `AC68U.sh`: VLAN setup script for the AC68U router.
- **AX11000/**
  - `AX11000.sh`: VLAN setup script for the AX11000 router.
  - `aimesh-vlan-bridge.sh`: Script for AiMesh VLAN bridging on AX11000.
  - `services-start`: Custom startup script for VLAN configuration.
  - `README.md`: Model-specific notes and instructions.

## Usage

1. **Choose your router model**: Navigate to the folder matching your router (e.g., `AC3100`, `AX11000`).
2. **Review the README.md**: Each model folder may contain a `README.md` with model-specific instructions or notes.
3. **Copy scripts to your router**: Use SCP or another method to transfer the relevant `.sh` and `services-start` scripts to your router's `/jffs/scripts/` directory.
4. **Set permissions**: Ensure scripts are executable. Example:
   ```sh
   chmod +x /jffs/scripts/*.sh
   chmod +x /jffs/scripts/services-start
   ```
5. **Reboot or restart services**: Reboot your router or restart the necessary services to apply the VLAN configuration.

## Notes
- These scripts are intended for advanced users familiar with ASUSWRT-Merlin firmware and custom scripting.
- Always back up your router configuration before applying custom scripts.
- Scripts may need to be adapted for firmware updates or different network setups.

## Contributing
Feel free to submit pull requests or open issues for improvements, bug fixes, or support for additional router models.

## License
See the main repository for license information.
