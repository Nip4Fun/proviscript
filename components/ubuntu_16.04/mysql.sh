#!/usr/bin/env bash
#>                   +--------------+
#>                   |  mysql.sh  |   
#>                   +--------------+
#-
#- SYNOPSIS
#-
#-    mysql.sh [-h] [-p [password]] [-s [y|n]] [...]
#-
#- OPTIONS
#-
#-    -w ?, --password=?            Set mysql root password.
#-    -s ?, --secure=?              Enable mysql secure configuration.
#-                                  Accept vaule: y, n
#-    -r ?, --remote=?              Enable access mysql remotely.
#-                                  Accept vaule: y, n
#-    -u ?, --remote-user=?         Remote user.
#-    -p ?, --remote-password=?     Remote user's password.
#-    -v ?, --version=?             Which version of MySQL you want to install?
#-                                  Accept vaule: latest, system
#-    -h, --help                    Print this help.
#-    -i, --info                    Print script information.
#-    --aptitude                    Use aptitude instead of apt-get as package manager
#-
#- EXAMPLES
#-
#-    $ ./mysql.sh -v latest -s y -r y -u test_user -p 12345678
#-    $ ./mysql.sh --version=system --secure=y --remote==y --remote-user=test_user --remote-password=12345678
#+
#+ IMPLEMENTATION:
#+
#+    version    1.00
#+    copyright  https://github.com/Proviscript/
#+    license    GNU General Public License
#+    authors    Terry Lin (terrylinooo)
#+ 
#================================================================

#================================================================
# Part 1. Config
#================================================================

# Display package information, no need to change.
os_name="Ubuntu"
os_version="16.04"
package_name="MySQL"

# Default, you can overwrite this setting by assigning -v or --version option.
package_version="latest"

# Debian/Ubuntu Only. Package manager: apt-get | aptitude
_PM="apt-get"

#================================================================
# Part 2. Option (DO NOT MODIFY)
#================================================================

# Print script help
show_script_help() {
    echo 
    head -50 ${0} | grep -e "^#[-|>]" | sed -e "s/^#[-|>]*/ /g"
    echo 
}

# Print script info
show_script_information() {
    echo 
    head -50 ${0} | grep -e "^#[+|>]" | sed -e "s/^#[+|>]*/ /g"
    echo 
}

# Receive arguments in slient mode.
if [ "$#" -gt 0 ]; then
    while [ "$#" -gt 0 ]; do
        case "$1" in
            # mysql root password (required in slient mode)
            "-w") 
                mysql_root_password="${2}";
                shift 2
            ;;
            "--password="*) 
                mysql_root_password="${1#*=}"
                shift 1
            ;;
            # Enable mysql secure configuration (not required)
            # As known as mysql_secure_installation.sh by Twitter
            # Accept vaule: y, Y, n, N
            "-s") 
                mysql_secure="${2}"
                shift 2
            ;;
            "--secure="*) 
                mysql_secure="${1#*=}"; 
                shift 1
            ;;
            # Enable access mysql remotely (not required)
            # Accept: y, Y, n, N
            "-r") 
                mysql_remote="${2}"
                shift 2
            ;;
            "--remote="*) 
                mysql_remote="${1#*=}"; 
                shift 1
            ;;
            # Remote user (required if $mysql_remote = y)
            "-u") 
                mysql_remote_user="${2}"
                shift 2
            ;;
            "--remote-user="*) 
                mysql_remote_user="${1#*=}"; 
                shift 1
            ;;
            # Remote user's password (required if $mysql_remote = y)
            "-p") 
                mysql_remote_password="${2}"
                shift 2
            ;;
            "--remote-password="*) 
                mysql_remote_password="${1#*=}"; 
                shift 1
            ;;
            # Which version of MySQL you want to install?
            "-v") 
                package_version="${2}"
                shift 2
            ;;
            "--version="*) 
                package_version="${1#*=}"; 
                shift 1
            ;;
            # Help
            "-h"|"--help")
                show_script_help
                exit 1
            ;;
            # Info
            "-i"|"--information")
                show_script_information
                exit 1
            ;;
            "--password"|"--secure"|"--remote"|"remote-user"|"remote-password")
                echo "${1} requires an argument"
                exit 1
            ;;
            # aptitude
            "--aptitude")
                _PM="aptitude"
                shift 1
            ;;
            # apt-get
            "--apt-get")
                _PM="apt-get"
                shift 1
            ;;
            "-"*)
                echo "Unknown option: ${1}"
                exit 1
            ;;
            *)
                echo "Unknown option: ${1}"
                exit 1
            ;;
        esac
    done
fi

# Not loaded by proviscript.sh, and mysql_root_password not set.
if [ -z "${mysql_root_password+x}" ]; then
    mysql_root_password="proviscript"
fi

if [ -z "${mysql_secure+x}" ]; then
    mysql_secure="n"
fi

if [ -z "${mysql_remote+x}" ]; then
    mysql_remote="n"
fi

# The following variables are not needed when mysql_remote="n"
if [ -z "${mysql_remote_user+x}" ]; then
    mysql_remote_user="proviscript"
fi

if [ -z "${mysql_remote_password+x}" ]; then
    mysql_remote_password="proviscript"
fi

#================================================================
# Part 3. Message (DO NOT MODIFY)
#================================================================

if [ "$(type -t INIT_PROVISCRIPT)" == function ]; then
    package_version=${PACKAGE_VERSION}
    mysql_root_password=${MYSQL_ROOT_PASSWORD}
    mysql_secure=${MYSQL_SECURE}
    mysql_remote=${MYSQL_REMOTE}
    mysql_remote_user=${MYSQL_REMOTE_USER}
    mysql_remote_password=${MYSQL_REMOTE_PASSWORD}
    func_component_welcome "mysql" "${package_version}"
else
    # Bash color set
    COLOR_EOF="\e[0m"
    COLOR_BLUE="\e[34m"
    COLOR_RED="\e[91m"
    COLOR_GREEN="\e[92m"
    COLOR_WHITE="\e[97m"
    COLOR_DARK="\e[90m"
    COLOR_BG_BLUE="\e[44m"
    COLOR_BG_GREEN="\e[42m"
    COLOR_BG_DARK="\e[100m"

    func_proviscript_msg() {
        case "$1" in
            "info")
                echo -e "[${COLOR_BLUE}O.o${COLOR_EOF}] ${COLOR_BLUE}${2}${COLOR_EOF}"
            ;;
            "warning")
                echo -e "[${COLOR_RED}O.o${COLOR_EOF}] ${COLOR_RED}${2}${COLOR_EOF}"
            ;;
            "success")
                echo -e "[${COLOR_GREEN}O.o${COLOR_EOF}] ${COLOR_GREEN}${2}${COLOR_EOF}"
            ;;
        esac
    }

    echo -e ${COLOR_WHITE}
    echo -e "  __  __           ____     ___    _      ";
    echo -e " |  \/  |  _   _  / ___|   / _ \  | |     ";
    echo -e " | |\/| | | | | | \___ \  | | | | | |     ";
    echo -e " | |  | | | |_| |  ___) | | |_| | | |___  ";
    echo -e " |_|  |_|  \__, | |____/   \__\_\ |_____| ";
    echo -e "           |___/                          ";
    echo -e ${COLOR_EOF}
    echo -e " Automatic installation by ${COLOR_GREEN}Provi${COLOR_BLUE}script";
    echo -e " ${COLOR_BG_GREEN}  ${COLOR_BG_BLUE}  ${COLOR_BG_DARK}${COLOR_WHITE} https://github.com/Proviscript/ ${COLOR_EOF}"
    echo -e ${COLOR_EOF}
fi

echo
echo "----------------------------------------------------------------------------------";
echo " @os: ${os_name} ${os_version}                                                    ";
echo " @package: ${package_name}                                                        ";
echo " @version: ${package_version}                                                     ";
echo "----------------------------------------------------------------------------------";
echo

#================================================================
# Part 4. Core
#================================================================

sudo ${_PM} update

if [ "${_PM}" == "aptitude" ]; then
    # Check if aptitude installed or not.
    is_aptitude=$(which aptitude |  grep "aptitude")

    if [ "${is_aptitude}" == "" ]; then
        func_proviscript_msg info "Package manager \"aptitude\" is not installed, installing..."
        sudo apt-get install aptitude
    fi
fi
# Check if MySQL has been installed or not.
func_proviscript_msg info "Checking if mysql-server is installed, if not, proceed to install it."

is_mysql_installed=$(dpkg-query -W --showformat='${Status}\n' mysql-server | grep "install ok installed")

if [ "${is_mysql_installed}" == "install ok installed" ]; then
    func_proviscript_msg warning "${package_name} is already installed, please remove it before executing this script."
    func_proviscript_msg info "Try \"sudo apt-get purge mysql-server\""
    exit 2
fi

# Install debconf-utils for silent installation.
sudo ${_PM} install -y debconf-utils
export DEBIAN_FRONTEND="noninteractive"

# Add repository for MySQL
if [ "${package_version}" == "latest" ]; then
    sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/repo-codename select xenial"
    sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/repo-distro select ubuntu"
    sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/repo-url string http://repo.mysql.com/apt"
    sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-preview select Disabled"
    sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-product select Ok"
    sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-server select mysql-8.0"
    sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-tools select Enabled"
    sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/unsupported-platform select abort"
    sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/tools-component string mysql-tools"
    sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/dmr-warning note"
    sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/preview-component string"
    wget https://dev.mysql.com/get/mysql-apt-config_0.8.9-1_all.deb
    sudo -E dpkg -i mysql-apt-config_0.8.9-1_all.deb
    rm mysql-apt-config_0.8.9-1_all.deb

    # Update repository for MySQL. 
    sudo ${_PM} update
fi

sudo debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password ${mysql_root_password}"
sudo debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password ${mysql_root_password}"
sudo debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass-mismatch error"
sudo debconf-set-selections <<< "mysql-community-server mysql-community-server/remove-data-dir boolean false"
sudo debconf-set-selections <<< "mysql-community-server mysql-community-server/data-dir note"
sudo debconf-set-selections <<< "mysql-community-server mysql-server/default-auth-override select Use Strong Password Encryption (RECOMMENDED)"

# Install MariaDB server
func_proviscript_msg info "Proceeding to install mysql-server..."
sudo -E ${_PM} install -y mysql-server

# Remove debconf-utils because we don't need it anymore.
sudo ${_PM} purge -y debconf-utils
unset DEBIAN_FRONTEND

# To Enable MariaDB server in boot.
func_proviscript_msg info "Proceeding to enable service mysql-server in boot."
sudo systemctl enable mysql

# As same as secure_mysql_installation.
# --------------------------------------
# 1) Change the root password.
# 2) Disallow root login remotely.
# 3) Remove anonymous users.
# 4) Remove test database and access to it.
if [ "${mysql_secure}" == "y" ]; then
    func_proviscript_msg info "Proceeding to secure mysql installation..."
    sudo mysql -uroot -p${mysql_root_password} 2>/dev/null << EOF
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
        FLUSH PRIVILEGES;
EOF
fi

# This is an option,If you need remote access the MySQL server
# Allow remote access.
if [ "${mysql_remote}" == "y" ]; then
    func_proviscript_msg info "Proceeding to modify /etc/mysql/my.cnf => bind-address = 0.0.0.0"
    sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    func_proviscript_msg info "Proceeding to create a remote user \"${mysql_remote_user}\" with password \"${mysql_remote_password}\"."
    # Setup an user account and access a MySQL server remotely.
    sudo mysql -uroot -p${mysql_root_password} 2>/dev/null << EOF
        CREATE USER '${mysql_remote_user}'@'%' IDENTIFIED BY '${mysql_remote_password}';
        GRANT ALL PRIVILEGES ON *.* TO '${mysql_remote_user}'@'%';
        FLUSH PRIVILEGES;
EOF
fi

# Start mysql service in boot.
func_proviscript_msg info "Proceeding to enable service mysql-server in boot."
sudo systemctl enable mysql

# To restart mysql service.
func_proviscript_msg info "Restart service mysql-server."
sudo service mysql restart

mysql_version="$(mysql -V 2>&1)"

if [[ "${mysql_version}" = *"MySQL"* && "${mysql_version}" != *"command not found"* ]]; then
    func_proviscript_msg success "Installation process is completed."
    func_proviscript_msg success "$(mysql -V 2>&1)"
else
    func_proviscript_msg warning "Installation process is failed."
fi

