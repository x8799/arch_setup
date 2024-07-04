# Introduction

```textile
   ___           __     ____    __          
  / _ | ________/ /    / __/__ / /___ _____ 
 / __ |/ __/ __/ _ \  _\ \/ -_) __/ // / _ \
/_/ |_/_/  \__/_//_/ /___/\__/\__/\_,_/ .__/
                                     /_/    
```

UEFI, Wi-Fi, and btrfs.

## Preparation

### Verify the boot mode

```bash
ls /sys/firmware/efi
```

If the directory exists, you have booted in UEFI mode.

### Connect to the internet

#### For Ethernet:

Wired connections usually work automatically. To verify:

```bash
ping archlinux.org
```

#### For Wi-Fi:

1. List network interfaces:

   ```bash
   ip link
   ```

2. Connect to Wi-Fi:

   ```bash
   iwctl
   device list
   station DEVICE scan
   station DEVICE get-networks
   station DEVICE connect SSID
   exit
   ```

   Replace DEVICE with your wireless interface (e.g., wlan0) and SSID with your network name.

3. Verify connection:

   ```bash
   ping archlinux.org
   ```

### Update the mirrorlist

1. Install reflector:

   ```bash
   pacman -Sy reflector
   ```

2. Backup the current mirrorlist:

   ```bash
   cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
   ```

3. Update and sort the mirrorlist:

   ```bash
   reflector --country "Your country" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
   ```

   For example: `Your country` replaces `"United States" Germany Japan`

4. Sync the package databases:

   ```bash
   pacman -Syy
   ```

### Update the system clock

```bash
timedatectl set-ntp true
```

## Installation

### Partition the disks

```bash
lsblk
```

```bash
cfdisk /dev/sdX
```

Replace 'X' with the apporopriate letter or number  for your disk

Create the following partitions:

1. EFI System Partition (ESP) - 512MB, type EFI System

2. Root partition - Remaining space, type Linux filesystem

### Format the partitions

```bash
mkfs.fat -F32 /dev/sda1
mkfs.btrfs /dev/sda2
```

### Mount and create btrfs subvolumes

```bash
mount /dev/sda2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt

mount -o noatime,compress=zstd,space_cache=v2,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{boot,home,.snapshots}
mount -o noatime,compress=zstd,space_cache=v2,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots /dev/sda2 /mnt/.snapshots
mount /dev/sda1 /mnt/boot
```

### Install the base system

```bash
pacstrap /mnt base base-devel linux linux-firmware btrfs-progs
```

## Configuration

### Generate fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### Chroot into the new system

```bash
arch-chroot /mnt
```

### Install additional packages

```bash
pacman -S efibootmgr vim sudo networkmanager ntfs-3g
```

Install microcode updates. Choose the appropriate package for your CPU:

For Intel processors:

```bash
pacman -S intel-ucode
```

For AMD processors:

```bash
pacman -S amd-ucode
```

### Install fonts and emoji support

Install DejaVu fonts (good for European languages), emoji support, and JetBrains Mono for coding

```bash
pacman -S ttf-dejavu noto-fonts-emoji ttf-jetbrains-mono
```

### Install audio packages

```bash
pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
```

### Set the time zone

```bash
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
```

### Localize the system

1. Edit the locale configuration file:

   ```bash
   vim /etc/locale.gen
   ```

2. Uncomment your desired locale(s) in the file. For example:

   - For English (US): Uncomment `en_US.UTF-8 UTF-8`
   - For Russian: Uncomment `ru_RU.UTF-8 UTF-8`

   Tip: In vim, use `/` to search for your locale, then use `x` to remove the `#` at the start of the line.

3. Save and exit vim (press `Esc`, then type `:wq` and press Enter).

4. Generate the locales:

   ```bash
   locale-gen
   ```

5. Set the system language:

   ```bash
   echo LANG=en_US.UTF-8 > /etc/locale.conf
   ```

   Note: Replace `en_US.UTF-8` with your preferred locale if different.

### Set the hostname and update hosts file

```bash
echo "myhostname" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 myhostname.localdomain myhostname" >> /etc/hosts
```

### Set the root password

```bash
passwd
```

### Create a user account

```bash
useradd -m -g users -G wheel -s /bin/bash username
passwd username
EDITOR=vim visudo
```

Uncomment `%wheel ALL=(ALL:ALL) ALL` to allow users in the wheel group to use sudo

### Install and configure the bootloader (systemd-boot)

```bash
bootctl install
```

Create a loader configuration:

```bash
vim /boot/loader/loader.conf
```

Add the following content:

```bash
default arch
timeout 3
editor 0
```

Create an entry for Arch Linux:

```bash
vim /boot/loader/entries/arch.conf
```

Add the following content (replace PARTUUID with the actual PARTUUID of your root partition):

```bash
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
```

To get the UUID and add to arch.conf:

```bash
ROOT_UUID=$(blkid -s UUID -o value /dev/sda2)
echo "options root=UUID=$ROOT_UUID rootflags=subvol=@ rw" >> /boot/loader/entries/arch.conf
```

## Finalization

### Exit chroot and reboot

```bash
exit
umount -R /mnt
reboot
```

## Post-Installation

### Enable NetworkManager

```bash
systemctl enable --now NetworkManager
```

#### For Wi-Fi:

```bash
nmcli device wifi list
nmcli device wifi connect <SSID> password <password>
```

#### For Ethernet:

```bash
nmcli device status
nmcli device connect eth0 # Replace eth0 with your Ethernet interface name
```

## Install Git and clone the configuration repository

```bash
sudo pacman -S git
cd ~
git clone https://github.com/x8799/arch_setup.git
```

### Configure audio

```bash
systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service
systemctl --user start pipewire.service pipewire-pulse.service wireplumber.service
```

## Install and configure Xorg

Install Xorg:

```bash
sudo pacman -S xorg-server xorg-xinit xorg-xrandr
```

Configure keyboard layout for Xorg:

1. Ensure you have cloned or downloaded the repository to your Arch system.

2. Copy the keyboard configuration file:

   ```bash
   sudo mkdir -p /etc/X11/xorg.conf.d
   sudo cp arch_setup/configs/xorg/00-keyboard.conf /etc/X11/xorg.conf.d/
   ```

   This configuration sets up US and Russian layouts with `Alt + Shift` as the default switch combination.

## Install System Monitoring and Analysis Tools

```bash
sudo pacman -S powertop htop neofetch
```

## Next Steps

For further configuration specific to your device type, please refer to:

- For laptops: [laptop_specific.md](laptop_specific.md)

- For desktop PCs: [pc_specific.md](pc_specific.md)

Choose the appropriate guide based on your hardware to complete the setup of your Arch Linux system.

Happy Arch-ing!
