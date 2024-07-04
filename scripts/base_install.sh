#!/bin/bash

source scripts/utils.sh

install_base_system() {
    log "Installing base system"
    run_command "pacstrap /mnt base base-devel linux linux-firmware btrfs-progs"
}

generate_fstab() {
    log "Generating fstab"
    run_command "genfstab -U /mnt >> /mnt/etc/fstab"
}

install_additional_packages() {
    log "Installing additional packages"
    run_command "arch-chroot /mnt pacman -S --noconfirm efibootmgr vim sudo networkmanager ntfs-3g ttf-dejavu noto-fonts-emoji ttf-jetbrains-mono pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber"

    if [[ $CPU_TYPE == "intel" ]]; then
        run_command "arch-chroot /mnt pacman -S --noconfirm intel-ucode"
    elif [[ $CPU_TYPE == "amd" ]]; then
        run_command "arch-chroot /mnt pacman -S --noconfirm amd-ucode"
    fi
}
