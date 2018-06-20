#!/usr/bin/env bash
#>                   +------------+
#>                   |  nginx.sh  |   
#>                   +------------+
#-
#- SYNOPSIS
#-
#-    nginx.sh [-h] [-i] [-v [version]]
#-
#- OPTIONS
#-
#-    -v ?, --version=?    Which version of Nginx you want to install?
#-                         Accept vaule: latest, mainline, default
#-    -h, --help           Print this help.
#-    -i, --info           Print script information.
#-
#- EXAMPLES
#-
#-    $ ./nginx.sh -v stable
#-    $ ./nginx.sh --version=mainline
#-    $ ./nginx.sh
#+
#+ IMPLEMENTATION:
#+
#+    version    1.0
#+    copyright  https://github.com/Proviscript/
#+    license    GNU General Public License
#+    authors    Terry Lin (terrylinooo)
#+ 
#================================================================

#================================================================
# Part 1. Config
#================================================================

# Display package information, no need to change.
os_name="Fedora"
os_version="28"
package_name="Nginx"

# Default, you can overwrite this setting by assigning -v or --version option.
package_version="latest"

# Package manager
_PM="dnf"

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
            # Which version of MariaDB you want to install?
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

#================================================================
# Part 3. Message (DO NOT MODIFY)
#================================================================

if [ "$(type -t INIT_PROVISCRIPT)" == function ]; then 
    package_version=${PACKAGE_VERSION}
    func_component_welcome "nginx" "${package_version}"
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
    echo -e "  _   _           _                       ";
    echo -e " | \ | |   __ _  (_)  _ __   __  __       ";
    echo -e " |  \| |  / _ \  | | | |  \  \ \/ /      ";
    echo -e " | |\  | | (_| | | | | | | |  >  <        ";
    echo -e " |_| \_|  \__, | |_| |_| |_| /_/\_\       ";
    echo -e "          |___/                           ";
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

# Check if Nginx has been installed or not.
func_proviscript_msg info "Checking if nginx is installed, if not, proceed to install it."

if [ "${package_version}" == "default" ]; then
    _PM="dnf"
fi

if [[ "${package_version}" == "latest" && "${package_version}" == "mainline" ]]; then
    # Package manager DNF does not have repository to install the latest Nginx.
    # Therefore forward to YUM.
    _PM="yum"
fi

is_nginx_installed=$(${_PM} list installed nginx 2>&1 | grep -o "nginx")

if [ "${is_nginx_installed}" == "nginx" ]; then
    func_proviscript_msg warning "${package_name} is already installed, please remove it before executing this script."
    func_proviscript_msg info "Try \"sudo ${_PM} remove nginx\""
    exit 2
fi

# Add repository for Nginx.
if [ "${package_version}" == "latest" ]; then
    sudo rm -rf /etc/yum.repos.d/nginx.repo
    sudo bash -c "echo '[nginx]' >> /etc/yum.repos.d/nginx.repo"
    sudo bash -c "echo 'name=nginx repo' >> /etc/yum.repos.d/nginx.repo"
    sudo bash -c "echo 'baseurl=http://nginx.org/packages/centos/7/\$basearch/' >> /etc/yum.repos.d/nginx.repo"
    sudo bash -c "echo 'gpgcheck=0' >> /etc/yum.repos.d/nginx.repo"
    sudo bash -c "echo 'enabled=1' >> /etc/yum.repos.d/nginx.repo"
fi
if [ "${package_version}" == "mainline" ]; then
    sudo rm -rf /etc/yum.repos.d/nginx.repo
    sudo bash -c "echo '[nginx]' >> /etc/yum.repos.d/nginx.repo"
    sudo bash -c "echo 'name=nginx repo' >> /etc/yum.repos.d/nginx.repo"
    sudo bash -c "echo 'baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/' >> /etc/yum.repos.d/nginx.repo"
    sudo bash -c "echo 'gpgcheck=0' >> /etc/yum.repos.d/nginx.repo"
    sudo bash -c "echo 'enabled=1' >> /etc/yum.repos.d/nginx.repo"
EOF
fi

func_proviscript_msg info "Proceeding to install nginx server."
sudo ${_PM} install -y nginx

# To enable Nginx server in boot.
func_proviscript_msg info "Enable service nginx in boot."
sudo systemctl enable nginx.service

# To restart Nginx service.
func_proviscript_msg info "Restart service nginx."
sudo service nginx restart

nginx_version="$(nginx -v 2>&1)"

if [[ "${nginx_version}" = *"nginx"* && "${nginx_version}" != *"command not found"* ]]; then
    func_proviscript_msg success "Installation process is completed."
    func_proviscript_msg success "$(nginx -v 2>&1)"
else
    func_proviscript_msg warning "Installation process is failed."
fi