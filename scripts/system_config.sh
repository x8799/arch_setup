#!/bin/bash

source scripts/utils.sh

configure_system() {
    log "Configuring system"
    run_command "arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime"
    run_command "arch-chroot /mnt hwclock --systohc"
    
    run_command "sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/etc/locale.gen"
    run_command "sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /mnt/etc/locale.gen"
    run_command "arch-chroot /mnt locale-gen"
    run_command "echo \"LANG=$LOCALE\" > /mnt/etc/locale.conf"
    
    run_command "echo \"$HOSTNAME\" > /mnt/etc/hostname"
    run_command "echo \"127.0.0.1 localhost\" >> /mnt/etc/hosts"
    run_command "echo \"::1       localhost\" >> /mnt/etc/hosts"
    run_command "echo \"127.0.1.1 $HOSTNAME.localdomain $HOSTNAME\" >> /mnt/etc/hosts"
}
