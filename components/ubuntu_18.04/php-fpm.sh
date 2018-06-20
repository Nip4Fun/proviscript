#!/usr/bin/env bash
#>                   +--------------+
#>                   |  php-fpm.sh  |   
#>                   +--------------+
#-
#- SYNOPSIS
#-
#-    php-fpm.sh [-h] [-i] [-l] [-v [version]] [-m [modules]]
#-
#- OPTIONS
#-
#-    -v ?, --version=?    Which version of PHP-FPM you want to install?
#-                         Accept vaule: 5.6, 7.0, 7,1, 7.2
#-    -m ?, --modules=?    Which modules of PHP-FPM you want to install?
#-                         Accept vaule: A comma-separated list of module names.
#-                         See "./php-fpm.sh --module-list"
#-    -h, --help           Print this help.
#-    -i, --info           Print script information.
#-    -l, --module-list    Print module list of PHP-FPM.
#-    --aptitude           Use aptitude instead of apt-get as package manager
#-
#- EXAMPLES
#-
#-    $ ./php-fpm.sh -v 7.2
#-    $ ./php-fpm.sh --version=7.2
#-    $ ./php-fpm.sh
#+
#+ IMPLEMENTATION:
#+
#+    version    1.01
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
os_version="18.04"
package_name="PHP-FPM"

# Debian/Ubuntu Only. Package manager: apt-get | aptitude
_PM="apt-get"

# Only allow 5.6, 7.0, 7,1, 7.2
package_version="7.2"

php_modules=(
    'bcmath'  'bz2'       'cgi'        'cli'       'common' 
    'curl'    'dba'       'dev'        'enchant'   'gd'       
    'gmp'     'imap'      'interbase'  'intl'      'json'
    'ldap'    'mbstring'  'mysql'      'odbc'      'opcache'  
    'pgsql'   'phpdbg'    'pspell'     'readline'  'recode'   
    'redis'   'snmp'      'soap'       'sqlite3'   'sybase' 
    'tidy'    'xml'       'xmlrpc'     'xsl'       'zip' 
)

# Default
install_modules="ALL"

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
                package_version="${1#*=}"
                shift 1
            ;;
            "-m") 
                install_modules="${2}"
                shift 2
            ;;
            "--modules="*) 
                install_modules="${1#*=}"
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
            # Info
            "-l"|"--module-list")
                for module_name in ${php_modules[@]}; do
                    echo ${module_name}
                done
                echo "ALL (default)"
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

#================================================================
# Part 3. Message (DO NOT MODIFY)
#================================================================

if [ "$(type -t INIT_PROVISCRIPT)" == function ]; then
    package_version=${PACKAGE_VERSION}
    php_modules=${PHP_MODULES}
    func_component_welcome "php-fpm" "${package_version}"
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
    echo -e "  ____    _   _   ____            _____   ____    __  __  ";
    echo -e " |  _ \  | | | | |  _ \          |  ___| |  _ \  |  \/  | ";
    echo -e " | |_) | | |_| | | |_) |  _____  | |_    | |_) | | |\/| | ";
    echo -e " |  __/  |  _  | |  __/  |_____| |  _|   |  __/  | |  | | ";
    echo -e " |_|     |_| |_| |_|             |_|     |_|     |_|  |_| ";
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

case  ${package_version} in
    "5.6") ;;           
    "7.0") ;;
    "7.1") ;;
    "7.2") ;;
    *)
        func_proviscript_msg warning "Invalid PHP version: ${package_version} is not supported."
        func_proviscript_msg info "Try \"5.6, 7.0, 7.1 or 7.2\" (recommended version: 7.2)."
        exit 1
        ;;
esac

if [ "${_PM}" == "aptitude" ]; then
    # Check if aptitude installed or not.
    is_aptitude=$(which aptitude |  grep "aptitude")

    if [ "${is_aptitude}" == "" ]; then
        func_proviscript_msg info "Package manager \"aptitude\" is not installed, installing..."
        sudo apt-get install aptitude
    fi
fi

# Check if PHP-FPM has been installed or not.
func_proviscript_msg info "Checking if php${package_version}-fpm is installed, if not, proceed to install it."

is_phpfpm_installed=$(dpkg-query -W --showformat='${Status}\n' php${package_version}-fpm | grep "install ok installed")

if [ "${is_phpfpm_installed}" == "install ok installed" ]; then
    func_proviscript_msg warning "php${package_version}-fpm is already installed, please remove it before executing this script."
    func_proviscript_msg info "Try \"sudo ${_PM} purge php${package_version}-fpm\""
    exit 2
fi

# Check if software-properties-common installed or not.
is_add_apt_repository=$(which add-apt-repository |  grep "add-apt-repository")

# Check if add-apt-repository command is available to use or not.
if [ "${is_add_apt_repository}" == "" ]; then
    func_proviscript_msg warning "Command \"add_apt_repository\" is not supprted, install \"software-properties-common\" to use it."
    func_proviscript_msg info "Proceeding to install \"software-properties-common\"."
    sudo ${_PM} install -y software-properties-common
fi

# Add repository for PHP.
sudo add-apt-repository --yes ppa:ondrej/php

# Update repository for PHP.
sudo ${_PM} update

# Comment out the package you don't want.
# Default: install them "ALL"
func_proviscript_msg info "Proceeding to install php${package_version}-fpm ..."
sudo ${_PM} install -y php${package_version}-fpm
sudo ${_PM} install -y php-pear

# Install PHP modules
if [ "${install_modules}" == "ALL" ]; then
    for module in ${php_modules[@]}; do
        func_proviscript_msg info "Proceeding to install PHP module \"${module}\" ..."
        sudo ${_PM} install -y php${package_version}-${module}
    done
else
    # Only install the modules what you want
    OLD_IFS=${IFS}
    IFS=',' read -r -a array_install_modules <<< "$install_modules"
    IFS=${OLD_IFS}

    for module in ${array_install_modules[@]}; do
        if [[ "${php_modules[@]}" =~ "${module}" ]]; then
            func_proviscript_msg info "Proceeding to install PHP module \"${module}\" ..."
            sudo ${_PM} install -y php${package_version}-${module}
        fi
    done
fi

# To enable PHP-FPM in boot.
func_proviscript_msg info "Enable service php${package_version}-fpm in boot."
sudo systemctl enable php${package_version}-fpm

# To restart PHP-FPM service.
func_proviscript_msg info "Restart service php${package_version}-fpm."
sudo service php${package_version}-fpm restart

php_version="$(php -v 2>&1)"

if [[ "${php_version}" = *"PHP"* && "${php_version}" != *"command not found"* ]]; then
    func_proviscript_msg success "Installation process is completed."
    func_proviscript_msg success "$(php -v 2>&1)"
else
    func_proviscript_msg warning "Installation process is failed."
fi