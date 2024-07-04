# Introduction

## Specific configuration for Arch Linux

```textile
   __                            ________   _      __    ___          __
  / /  ___ ___  ___ _  _____    /_  __/ /  (_)__  / /__ / _ \___ ____/ /
 / /__/ -_) _ \/ _ \ |/ / _ \    / / / _ \/ / _ \/  '_// ___/ _ `/ _  / 
/____/\__/_//_/\___/___/\___/   /_/ /_//_/_/_//_/_/\_\/_/   \_,_/\_,_/  

   _  _____  _____         __               _____           ____
  | |/_<  / / ___/__ _____/ /  ___  ___    / ___/__ ___    /_  /
 _>  < / / / /__/ _ `/ __/ _ \/ _ \/ _ \  / (_ / -_) _ \    / / 
/_/|_|/_/  \___/\_,_/_/ /_.__/\___/_//_/  \___/\__/_//_/   /_/  
```

## Power Management

### Install and configure TLP

TLP is crucial for optimizing battery life.

```bash
sudo pacman -S tlp tlp-rdw
sudo systemctl enable --now tlp.service
sudo systemctl enable NetworkManager-dispatcher.service
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
```

Configure TLP:

```bash
sudo tee -a /etc/tlp.conf <<EOF
START_CHARGE_THRESH_BAT0=75
STOP_CHARGE_THRESH_BAT0=80
EOF
```

## ThinkPad-specific tools

```bash
sudo pacman -S acpi_call
```

- `acpi_call`: Enables low-level ACPI calls for battery management and other ThinkPad-specific features.

## Display and Graphics

```bash
sudo pacman -S mesa vulkan-intel intel-media-driver
```

Create an Xorg configuration file:

```bash
sudo tee /etc/X11/xorg.conf.d/20-intel.conf <<EOF
Section "Device"
    Identifier "Intel Graphics"
    Driver "modesetting"
    Option "AccelMethod" "glamor"
    Option "DRI" "3"
    Option "TearFree" "true"
EndSection
EOF
```

### Brightness control

```bash
sudo pacman -S brightnessctl
sudo usermod -aG video $USER
```

## Input Devices

```bash
sudo pacman -S xf86-input-libinput
```

Configure touchpad and TrackPoint:

```bash
sudo tee /etc/X11/xorg.conf.d/40-libinput.conf <<EOF
Section "InputClass"
    Identifier "libinput touchpad catchall"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
    Option "ClickMethod" "clickfinger"
EndSection

Section "InputClass"
    Identifier "libinput trackpoint catchall"
    MatchIsPointer "on"
    MatchProduct "TrackPoint"
    Driver "libinput"
    Option "AccelSpeed" "0.5"
EndSection
EOF
```

## Bluetooth

```bash
sudo pacman -S bluez bluez-utils
sudo systemctl enable --now bluetooth.service
sudo usermod -aG lp $USER
```

## Fingerprint Reader

```bash
sudo pacman -S fprintd
fprintd-enroll
```

## Webcam

```bash
sudo pacman -S v4l-utils
```

## SSD Optimization for btrfs

Enable TRIM for your SSD:

```bash
sudo systemctl enable fstrim.timer
```

Add `discard=async` to your btrfs mount options in `/etc/fstab`:

```bash
UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX / btrfs rw,noatime,compress=zstd:1,ssd,space_cache=v2,discard=async,subvol=@ 0 0
```

To get the PARTUUID, use:

```bash
blkid /dev/sda2 
```

## Conclusion

Congratulations! Your ThinkPad X1 Carbon Gen 7 is now optimized for Arch Linux. To complete your setup:

- For window manager configurations, refer to the [window_managers](../window_managers) directory.

- Currently, you'll find configurations for:
  
  - [bspwm](../window_managers/bspwm)

Feel free to customize these configurations further to suit your needs. Happy Arch-ing!
