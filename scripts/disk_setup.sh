#!/bin/bash

source scripts/utils.sh

setup_disk() {
    log "Setting up disk partitions"
    run_command "parted -s \"$DISK\" mklabel gpt"
    run_command "parted -s \"$DISK\" mkpart ESP fat32 1MiB 513MiB"
    run_command "parted -s \"$DISK\" set 1 boot on"
    run_command "parted -s \"$DISK\" mkpart primary btrfs 513MiB 100%"

    log "Formatting partitions"
    run_command "mkfs.fat -F32 \"$EFI_PARTITION\""
    run_command "mkfs.btrfs -f \"$ROOT_PARTITION\""

    log "Setting up BTRFS subvolumes"
    run_command "mount \"$ROOT_PARTITION\" /mnt"
    run_command "btrfs subvolume create /mnt/@"
    run_command "btrfs subvolume create /mnt/@home"
    run_command "btrfs subvolume create /mnt/@snapshots"
    run_command "umount /mnt"

    log "Mounting partitions"
    run_command "mount -o noatime,compress=zstd,space_cache=v2,subvol=@ \"$ROOT_PARTITION\" /mnt"
    run_command "mkdir -p /mnt/{boot,home,.snapshots}"
    run_command "mount -o noatime,compress=zstd,space_cache=v2,subvol=@home \"$ROOT_PARTITION\" /mnt/home"
    run_command "mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots \"$ROOT_PARTITION\" /mnt/.snapshots"
    run_command "mount \"$EFI_PARTITION\" /mnt/boot"
}
