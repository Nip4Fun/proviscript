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
#-    --aptitude           Use aptitude instead of apt-get as package manager
#-
#- EXAMPLES
#-
#-    $ ./nginx.sh -v stable
#-    $ ./nginx.sh --version=mainline
#-    $ ./nginx.sh
#+
#+ IMPLEMENTATION:
#+
#+    version    1.02
#+    copyright  https://github.com/Proviscript/
#+    license    GNU General Public License
#+    authors    Terry Lin (terrylinooo)
#+ 
#+ CHANGELOGS:
#+
#+    2018/05/19 terrylinooo First commit.
#+    2018/05/20 terrylinooo Add arguments, see nginx.sh -h
#+    2018/06/02 terrylinooo Redefine version value: latest, mainline, default
#+
#================================================================

#================================================================
# Part 1. Config
#================================================================

# Display package information, no need to change.
os_name="Ubuntu"
os_version="18.04"
package_name="Nginx"

# Debian/Ubuntu Only. Package manager: apt-get | aptitude
_APT="apt-get"

# Default, you can overwrite this setting by assigning -v or --version option.
package_version="latest"

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
            # aptitude
            "--aptitude")
                _APT="aptitude"
                shift 1
            ;;
            # apt-get
            "--apt-get")
                _APT="apt-get"
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
sudo ${_APT} update

if [ "${_APT}" == "aptitude" ]; then
    # Check if aptitude installed or not.
    is_aptitude=$(which aptitude |  grep "aptitude")

    if [ "${is_aptitude}" == "" ]; then
        func_proviscript_msg info "Package manager \"aptitude\" is not installed, installing..."
        sudo apt-get install aptitude
    fi
fi

# Check if Nginx has been installed or not.
func_proviscript_msg info "Checking if nginx is installed, if not, proceed to install it."

is_nginx_installed=$(dpkg-query -W --showformat='${Status}\n' nginx | grep "install ok installed")

if [ "${is_nginx_installed}" == "install ok installed" ]; then
    func_proviscript_msg warning "${package_name} is already installed, please remove it before executing this script."
    func_proviscript_msg info "Try \"sudo ${_APT} purge nginx\""
    exit 2
fi

# Add repository for Nginx.
if [ "${package_version}" == "latest" ]; then
    version_code="stable"
elif [ "${package_version}" == "mainline" ]; then
    version_code="mainline"
elif [ "${package_version}" == "default" ]; then
    version_code="default"
fi

if [ "${version_code}" != "default" ]; then
    # Check if software-properties-common installed or not.
    is_add_apt_repository=$(which add-apt-repository |  grep "add-apt-repository")

    # Check if add-apt-repository command is available to use or not.
    if [ "${is_add_apt_repository}" == "" ]; then
        func_proviscript_msg warning "Command \"add_apt_repository\" is not supprted, install \"software-properties-common\" to use it."
        func_proviscript_msg info "Proceeding to install \"software-properties-common\"."
        sudo ${_APT} install -y software-properties-common
    fi

    sudo add-apt-repository --yes ppa:nginx/${version_code}
    # Update repository for Nginx. 
    sudo ${_APT} update
fi

# Install Nginx
func_proviscript_msg info "Proceeding to install nginx server."
sudo ${_APT} install -y nginx

# To Enable Nginx server in boot.
func_proviscript_msg notice "Enable service nginx in boot."
sudo systemctl enable nginx

func_proviscript_msg info "Restart service nginx."
sudo service nginx restart

nginx_version="$(nginx -v 2>&1)"

if [[ "${nginx_version}" = *"nginx"* ]]; then
    func_proviscript_msg success "Installation process is completed."
    func_proviscript_msg success "$(nginx -v 2>&1)"
else
    func_proviscript_msg warning "Installation process is failed."
fi