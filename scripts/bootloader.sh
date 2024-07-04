#!/bin/bash

source configs/install_config.sh

install_bootloader() {
    log "Installing bootloader"
    arch-chroot /mnt bootctl install
    
    echo "default arch" > /mnt/boot/loader/loader.conf
    echo "timeout 3" >> /mnt/boot/loader/loader.conf
    echo "editor 0" >> /mnt/boot/loader/loader.conf
    
    echo "title Arch Linux" > /mnt/boot/loader/entries/arch.conf
    echo "linux /vmlinuz-linux" >> /mnt/boot/loader/entries/arch.conf
    echo "initrd /initramfs-linux.img" >> /mnt/boot/loader/entries/arch.conf
    
    root_uuid=$(blkid -s UUID -o value "$ROOT_PARTITION")
    echo "options root=UUID=$root_uuid rootflags=subvol=@ rw" >> /mnt/boot/loader/entries/arch.conf
}
