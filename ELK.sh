#!/bin/bash

# Some variables for the script
LOG_FILE="/var/log/elk/elk.log"                     # Path for error logging 
REPOSITORY="/etc/yum.repos.d"                       # Repository path in RPM (Fedora)
DEFAULT_JAVA_VERSION="java-1.8.0-openjdk-devel"     # Recommended 

# Ensure log directory exists
mkdir -p /var/log/elk

# Function to log errors
log_error() {
    echo "$1" | tee -a "$LOG_FILE" >&2
    exit 1
}

# Function to run a command with error checking
run_command() {
    "$@" 2>>"$LOG_FILE" || log_error "Error: '$*' failed. Check $LOG_FILE"
}

check_major_version() {
    major_version=$1

    echo -e "\e[32mThis will talk few second's\e[0m"    
    # Fetching available major versions from Elastic's past releases page
    available_major_versions=$(curl -s https://www.elastic.co/downloads/past-releases#elasticsearch | grep -oP "elasticsearch-\K[1-9]+" | sort -uVr)
    
    # Check if the user-specified major version exists in the list
    if echo "$available_major_versions" | grep -qw "$major_version"; then
        echo "✅ Major version $major_version.x is available."
        ELASTIC_VERSION=$major_version.x
        return 0
    else
        echo "❌ Major version $major_version.x is not available."
        echo "Fetching available Elastic major versions..."
        curl -s https://www.elastic.co/downloads/past-releases#elasticsearch | grep -oP "elasticsearch-\K[1-9]+" | sort -uVr | while read -r version; do echo "$version.x"; done

        exit 1
    fi
}



# Function to install requirements for Fedora
install_requirements_for_fedora() {

    echo -e "\e[32mUpdating package lists...\e[0m"
    run_command dnf update -y
    echo -e "\e[32mEnter the major Elastic version you want to install (e.g., 8, 7, 6): \e[0m"
    read  user_major_version
    run_command check_major_version $user_major_version
    echo -e "\e[32mInstalling Java...\e[0m"
    run_command dnf install $DEFAULT_JAVA_VERSION -y
    echo -e "\e[32mInstalling Nginx...\e[0m"
    run_command dnf install nginx -y
    echo -e "\e[32mAdding Elasticsearch GPG Key...\e[0m"
    run_command rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch


    # Add Elasticsearch repository
cat <<EOF >$REPOSITORY/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for $ELASTIC_VERSION packages
baseurl=https://artifacts.elastic.co/packages/$ELASTIC_VERSION/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

 # Add Kibana repository
cat <<EOF >$REPOSITORY/kibana.repo
[kibana]
    name=Kibana repository for $ELASTIC_VERSION packages
    baseurl=https://artifacts.elastic.co/packages/$ELASTIC_VERSION/yum
    gpgcheck=1
    gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
    enabled=0
    autorefresh=1
    type=rpm-md
EOF

 # Add Logstash repository
cat <<EOF >$REPOSITORY/logstash.repo
[logstash]
    name=Elastic repository for $ELASTIC_VERSION packages
    baseurl=https://artifacts.elastic.co/packages/$ELASTIC_VERSION/yum
    gpgcheck=1
    gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
    enabled=1
    autorefresh=1
    type=rpm-md
EOF
    
}

# Function to install Elasticsearch stack on Fedora
install_elk_for_fedora() {

    echo -e "\e[32mInstalling elasticsearch ...\e[0m"
    run_command dnf install --enablerepo=elasticsearch elasticsearch -y
        for service in  kibana logstash; do
        echo -e "\e[32mInstalling $service...\e[0m"
        run_command dnf install $service -y
        run_command systemctl enable $service
        run_command systemctl start $service
        done
}

# Function to install requirements for Debian
install_requirements_for_deb() {
    echo -e "\e[32mAdding Elasticsearch GPG Key...\e[0m"
    run_command wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg
    
    # Prompt the user for the major version
    echo -e "\e[32mEnter the major Elastic version you want to install (e.g., 8, 7, 6): \e[0m"
    read  user_major_version
    run_command check_major_version $user_major_version


    echo -e "\e[32mAdding Elasticsearch APT repository...\e[0m"
    echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/$ELASTIC_VERSION/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic.list

    run_command apt update
    run_command apt install apt-transport-https openjdk-11-jdk nginx -y
}

# Function to install Elasticsearch stack on Debian
install_elk_for_deb() {
    for service in elasticsearch kibana logstash; do
        echo -e "\e[32mInstalling $service...\e[0m"
        run_command apt install $service -y
        run_command systemctl enable $service
        run_command systemctl start $service
    done
}

# Function to configure Elasticsearch
configuration_elasticsearch() {

    # For talking a backup file for the config file
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    if ! cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.backup.$timestamp; then
    log_error "Failed to backup Elasticsearch configuration."
fi
        # Choese the IP address
    echo -e "\e[32m Configuring Elasticsearch... \e[0m" 
    default_value_for_IP="localhost"
    read -p "Enter the IP Address for Server (default is '${default_value_for_IP}'): " IP_Address
    IP_Address=${IP_Address:-$default_value_for_IP}

        # Choese the port 
    default_value_for_port="9200"
    read -p "Enter the Port Number for Service (default is '${default_value_for_port}'): " port
    port_elasticsearch=${port_elasticsearch:-$default_value_for_port}

        # Add the custom config
    sed -i "s/#network.host: 192.168.0.1/network.host: $IP_Address/" /etc/elasticsearch/elasticsearch.yml  
    sed -i "s/#http.port: 9200/http.port: $port_elasticsearch/" /etc/elasticsearch/elasticsearch.yml
    
    


    run_command systemctl restart elasticsearch.service
    echo -e "\e[32m Setup Username & Password for Elasticsearch  \e[0m"
    run_command /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive 
    run_command systemctl restart elasticsearch.service  
    echo -e "\e[32m Finished \e[0m" 
}

# Function to configure Kibana
configuration_kibana() {

    # For talking a backup file for the config file
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
   if ! cp /etc/kibana/kibana.yml /etc/kibana/kibana.yml.backup.$timestamp; then
    log_error "Failed to backup Kibana configuration."
fi

    echo -e "\e[32m Configuring Kibana...  \e[0m" 
         # Choese the IP address
    default_value_for_IP="localhost"
    read -p "Enter the IP Address for Server (default is '${default_value_for_IP}'): " IP_address
    IP_address=${IP_address:-$default_value_for_IP}
        # Choese the port
    default_value_for_port="5601"
    read -p "Enter the Port Number for Elasticsearch (default is '${default_value_for_port}'): " port
    port=${port:-$default_value_for_port}
       
    read -p "Enter the Kibana password for Elasticsearch: " password
    sed -i "s/#\s*server.host:\s*\"localhost\"/server.host: \"$IP_address\"/" /etc/kibana/kibana.yml
    sed -i "s|#\s*server.port:5601|server.port: $port|"  /etc/kibana/kibana.yml
    sed -i "s|#\s*elasticsearch.hosts:\s*\[\"http://localhost:9200\"\]|elasticsearch.hosts: [\"http://$IP_address:$port_elasticsearch\"]|" /etc/kibana/kibana.yml
    echo "elasticsearch.ssl.verificationMode: none" >> /etc/elasticsearch/elasticsearch.yml

run_command systemctl restart kibana.service  
echo -e "\e[32m Finished \e[0m" 
}

# Detect OS and run appropriate installer
OS_define() {
    # Check if /etc/os-release exists
    if [ -f /etc/os-release ]; then
        # Source the os-release file to access its variables

        . /etc/os-release

        # Determine the package manager based on the OS ID

        case "$ID" in 
            fedora)           
                install_requirements_for_fedora     
                install_elk_for_fedora
                ;;
            *)
                # Check if ID_LIKE contains 'debian'
                if [[ "$ID_LIKE" == *"debian"* ]]; then
                    install_requirements_for_deb
                    install_elk_for_deb
                    configuration_kibana
                else
                    echo -e "\e[31m Unsupported Linux distribution: $NAME \e[0m"
                    exit 1  # Exit with a non-zero status to indicate an error
                fi
                ;;
        esac 
    else 
        echo -e "\e[31m /etc/os-release file not found. Cannot determine OS. \e[0m"

        exit 1  # Exit with a non-zero status to indicate an error
    fi
}

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root."
fi

# Run the installation
OS_define
echo -e "\e[32mInstallation and configuration completed successfully.\e[0m"