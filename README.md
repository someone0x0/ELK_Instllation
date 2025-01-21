# ELK Automation Script




[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)
[![Elastic-logo](https://www.svgrepo.com/show/303574/elasticsearch-logo.svg)](https://github.com/ellerbrock/open-source-badges/)






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
![Elastic_stack](https://github.com/user-attachments/assets/a4545f17-d2fc-4fee-b181-1cd4b0580811)


## Components
- **Elasticsearch:** Centralized search and analytics engine.
- **Logstash:** Data processing pipeline for ingesting logs.
- **Kibana:** Visualization and monitoring interface.

---




## Contribution
Contributions are welcome! Feel free to open issues or submit pull requests to enhance functionality or add features.

---

## License
For information about Elastic Stack subscriptions, visit [Elastic Subscriptions](https://www.elastic.co/subscriptions).


---

## Contact
For inquiries or feedback, contact: someone0x00@proton.me
