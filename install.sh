#!/bin/bash

set -e

source configs/install_config.sh
source scripts/utils.sh
source scripts/disk_setup.sh
source scripts/base_install.sh
source scripts/system_config.sh
source scripts/user_setup.sh
source scripts/bootloader.sh

log "Starting Arch Linux installation"

setup_disk
install_base_system
configure_system
setup_users
install_bootloader

log "Installation complete. You can now reboot into your new Arch Linux system."
