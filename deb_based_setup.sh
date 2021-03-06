#!/bin/bash
#
# Setups a debian based system such as:
# * Ubuntu (And flavour)
# * Elementary
# 

# Current path
# ref: https://stackoverflow.com/a/4774063/3211029
HERE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BKP_DIR="${HERE}/backup"
BKP_CNF_DIR="${BKP_DIR}/config"

# Ensures existence of config backup directory
function verify_cnf_bkp_dir {
    echo "Verifying backup directory"

    if [ ! -d "${BKP_CNF_DIR}" ]; then
        mkdir -p "${BKP_CNF_DIR}"

        # Abort if directory can not be created
        if [ ! -d "${BKP_CNF_DIR}" ]; then
            echo ""
            echo " ERR: Backup dir can not be created"
            exit 1
        fi
    fi
}

# Install apps I always use on deb systems
function install_and_setup_apps {
    sudo apt-get update
    sudo apt-get upgrade -y

    echo ""
    echo "Installing basic programs"
    sudo apt-get install -y \
        build-essential \
        git \
        vim \
        openssh-server \

    setup_ssh
    setup_vim
}

function setup_ssh {
    echo ""
    echo "Setting up ssh programs"

    UFW_STATUS="$(systemctl is-active ufw)"
    if [ "${UFW_STATUS}" == "active" ]; then
        echo " Allowing ssh in ufw"
        sudo ufw allow ssh
    else
        echo " WARN: ufw not found, firewall setup for ssh may be required"
    fi
}

function setup_vim {
    echo ""
    echo "Setting up vim and Vundle"

    VIMRC_PATH="${HOME}/.vimrc"

    if [ -L "${VIMRC_PATH}" ]; then
        echo " WARN: ${VIMRC_PATH} is already a symlink"
        echo "       $(readlink -f ${VIMRC_PATH})"
    fi

    # Install Vundle
    echo " Installing Vundle"
    git clone \
        https://github.com/VundleVim/Vundle.vim.git \
        ~/.vim/bundle/Vundle.vim

    # Backup before symlink
    if [ -f "${VIMRC_PATH}" ]; then
        echo " Backing up original .vimrc"

        backup="${BKP_DIR}/vimrc"
        cp $VIMRC_PATH $backup
        rm $VIMRC_PATH
    fi

    echo " Symlinking .vimrc"
    ln -s "${HERE}/config/vimrc" "${VIMRC_PATH}"

    # Install all vim plugins
    echo " Installing plugins"
    vim +PluginInstall +qall
}


# Execute:
verify_cnf_bkp_dir
install_and_setup_apps
