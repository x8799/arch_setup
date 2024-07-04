#!/bin/bash

source scripts/utils.sh

install_bootloader() {
    log "Installing bootloader"
    run_command "arch-chroot /mnt bootctl install"
    
    run_command "echo \"default arch\" > /mnt/boot/loader/loader.conf"
    run_command "echo \"timeout 3\" >> /mnt/boot/loader/loader.conf"
    run_command "echo \"editor 0\" >> /mnt/boot/loader/loader.conf"
    
    run_command "echo \"title Arch Linux\" > /mnt/boot/loader/entries/arch.conf"
    run_command "echo \"linux /vmlinuz-linux\" >> /mnt/boot/loader/entries/arch.conf"
    run_command "echo \"initrd /initramfs-linux.img\" >> /mnt/boot/loader/entries/arch.conf"
    
    root_uuid=$(blkid -s UUID -o value "$ROOT_PARTITION")
    run_command "echo \"options root=UUID=$root_uuid rootflags=subvol=@ rw\" >> /mnt/boot/loader/entries/arch.conf"
}
