# ELK Automation Script

![ELK Logo](assets/logo-kibana-32-color.svg)


## Overview
This repository contains an automated script to simplify the installation and configuration of the Elastic Stack (Elasticsearch, Logstash, and Kibana) on Linux systems. The project aims to streamline the deployment process, making it faster, more efficient, and less prone to human error.

The script supports Fedora and Debian-based distributions, enabling a robust setup for Security Information and Event Management (SIEM) solutions.

---

## Features
- **Automation Configuration:** Minimal manual intervention required.
- **Multi-OS Support:** Works seamlessly on Fedora and Debian-based systems.
- **Version Handling:** Allows users to specify Elastic Stack versions.
- **Error Logging:** Comprehensive error handling and logs.
- **Customizable Configuration:** Supports user-defined IP addresses, ports, and other configurations.

---

## Prerequisites
Before running the script, ensure the following:

- Root access to the system.
- Internet connection to download repositories and packages.
- Supported Linux distribution (Fedora or Debian-based).

---

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/someone0x0/elk-automation.git
   cd elk-automation
   ```

2. Make the script executable:
   ```bash
   chmod +x ELK.sh
   ```

3. Run the script as root:
   ```bash
   sudo ./ELK.sh
   ```

---

## Usage

The script will guide you through the setup process with prompts:

1. Select the major Elastic Stack version (e.g., 8, 7, 6).
2. Configure IP addresses and ports for Elasticsearch and Kibana.
3. Set up services to start automatically on boot.
4. Review logs in `/var/log/elk/elk.log` for any errors.

---

## Example Output
- Successful installation and configuration messages.
- Logs for error handling stored at `/var/log/elk/elk.log`.

---

## Project Goals
This project aims to:

1. Enhance the stability of Elastic Stack deployments.
2. Provide flexibility for different environments.
3. Reduce manual effort and errors during installation.

---

## Components
- **Elasticsearch:** Centralized search and analytics engine.
- **Logstash:** Data processing pipeline for ingesting logs.
- **Kibana:** Visualization and monitoring interface.

---

## Known Limitations
- Requires root access to execute.
- Internet connectivity is mandatory for fetching packages.

---

## Contribution
Contributions are welcome! Feel free to open issues or submit pull requests to enhance functionality or add features.

---

## License
This project is licensed under the [MIT License](LICENSE).


---

## Contact
For inquiries or feedback, contact: someone0x00@proton.me
