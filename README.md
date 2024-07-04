# 🐧 Arch Setup: Because Normal OSes Are Too Mainstream

```ascii
   ___           __     ____    __          
  / _ | ________/ /    / __/__ / /___ _____ 
 / __ |/ __/ __/ _ \  _\ \/ -_) __/ // / _ \
/_/ |_/_/  \__/_//_/ /___/\__/\__/\_,_/ .__/
                                     /_/    
```

## 🚀 Four Easy Steps to Nerd Nirvana

1. [Prerequisites](#prerequisites)
2. [Base Install](#running-the-installer)
3. [Post-Install Magic](#post-installation-steps)
4. [Window Manager](#window-manager-setup)

## Prerequisites

1. Boot from an Arch Linux USB drive.

2. Ensure you've booted in UEFI mode:

    ```bash
    ls /sys/firmware/efi/efivars
    ```

    If the directory exists, you're in UEFI mode.

3. Connect to the internet:

    - For wired connections: Should work automatically.
    - For Wi-Fi:

    ```bash
    iwctl
    device list
    station [device] scan
    station [device] get-networks
    station [device] connect [SSID]
    exit
    ```

4. Clone this repository:

    ```bash
    pacman -Sy git
    git clone https://github.com/x8799/arch_setup.git
    cd arch-setup
    ```

5. Edit `configs/install_config.sh` to suit your needs.

## Running the Installer

After completing the prerequisites, run the installation script:

```bash
./install.sh
```

## Post-Installation Steps

1. Reboot the system:

    ```bash
    exit
    umount -R /mnt
    reboot
    ```

2. For Wi-Fi:

    ```bash
    nmcli device wifi list
    nmcli device wifi connect [SSID] password [password]
    ```

3. Run `./post_install.sh` (for my laptop Thinkpad X1 Carbon Gen 7)

## Window Manager Setup

Check out `docs/bspwm_install.md` for the next steps in your journey to desktop nirvana.

## 🧙‍♂️ Modules: The Building Blocks of Your Digital Fortress

- `utils.sh`: The Swiss Army knife of our scripts.
- `disk_setup.sh`: Because partitioning is an art form.
- `base_install.sh`: The foundation of your digital empire.
- `system_config.sh`: Making your system speak your language (literally).
- `user_setup.sh`: Creating your digital alter ego.
- `bootloader.sh`: Teaching your computer to tie its own shoelaces.

Now go forth and conquer the Linux realm! 🐧👑
