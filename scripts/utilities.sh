# No shebang as this file always meant to be sourced by other scripts.

color='\033[0;33m'
nc='\033[0m' # No color

function cecho {
    echo -e "${color}${@}${nc}"
}

function con {
    echo -n -e "${color}"
}

function coff {
    echo -n -e "${nc}"
}

function separator {
    cecho "-----------------------------------------------------------------------------------------------"
}

function message {
    separator
    cecho $1
    separator
}

function echeck {
    if [ $? -ne 0 ]; then
        separator
        cecho $1
        cecho "Exiting."
        separator
        exit 1
    fi
}

function proceed {
    con
    read -p "Do you want to proceed?$(if [ -n "$1" ]; then echo " $1 "; fi)(y/N)" confirm
    if [[ $confirm != "y" && $confirm != "Y" ]]; then
        cecho "Operation canceled."
        exit 1
    fi
    coff
    separator
}

