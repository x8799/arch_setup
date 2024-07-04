#!/bin/bash

install_base_system() {
    log "Installing base system"
    pacstrap /mnt base base-devel linux linux-firmware btrfs-progs
}

generate_fstab() {
    log "Generating fstab"
    genfstab -U /mnt >> /mnt/etc/fstab
}

install_additional_packages() {
    log "Installing additional packages"
    arch-chroot /mnt pacman -S --noconfirm efibootmgr vim sudo networkmanager ntfs-3g \
    ttf-dejavu noto-fonts-emoji ttf-jetbrains-mono \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
    
    if [[ $CPU_TYPE == "intel" ]]; then
        arch-chroot /mnt pacman -S --noconfirm intel-ucode
    elif [[ $CPU_TYPE == "amd" ]]; then
        arch-chroot /mnt pacman -S --noconfirm amd-ucode
    fi
}
