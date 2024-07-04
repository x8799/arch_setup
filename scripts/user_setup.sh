#!/bin/bash

setup_users() {
    log "Setting up users"
    arch-chroot /mnt passwd
    
    arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$USERNAME"
    arch-chroot /mnt passwd "$USERNAME"
    
    echo "%wheel ALL=(ALL:ALL) ALL" >> /mnt/etc/sudoers
}
