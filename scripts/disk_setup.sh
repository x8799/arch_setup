#!/bin/bash

setup_disk() {
    log "Setting up disk partitions"
    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB
    parted -s "$DISK" set 1 boot on
    parted -s "$DISK" mkpart primary btrfs 513MiB 100%

    log "Formatting partitions"
    mkfs.fat -F32 "$EFI_PARTITION"
    mkfs.btrfs "$ROOT_PARTITION"

    log "Setting up BTRFS subvolumes"
    mount "$ROOT_PARTITION" /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots
    umount /mnt

    log "Mounting partitions"
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@ "$ROOT_PARTITION" /mnt
    mkdir -p /mnt/{boot,home,.snapshots}
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@home "$ROOT_PARTITION" /mnt/home
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots "$ROOT_PARTITION" /mnt/.snapshots
    mount "$EFI_PARTITION" /mnt/boot
}
