#!/bin/bash

source scripts/utils.sh

setup_users() {
    log "Setting up users"
    log "Please set the root password:"
    run_command "arch-chroot /mnt passwd"
    
    log "Creating user $USERNAME"
    run_command "arch-chroot /mnt useradd -m -G wheel -s /bin/bash \"$USERNAME\""
    log "Please set the password for $USERNAME:"
    run_command "arch-chroot /mnt passwd \"$USERNAME\""
    
    run_command "echo \"%wheel ALL=(ALL:ALL) ALL\" >> /mnt/etc/sudoers"
    log "User setup complete"
}
