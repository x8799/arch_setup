#!/bin/bash

# Source the configuration file
source configs/install_config.sh

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Enable NetworkManager
enable_network() {
    log "Enabling NetworkManager"
    sudo systemctl enable --now NetworkManager
}

# Configure audio
setup_audio() {
    log "Setting up audio"
    systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service
    systemctl --user start pipewire.service pipewire-pulse.service wireplumber.service
}

# Install and configure Xorg
setup_xorg() {
    log "Installing and configuring Xorg"
    sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-xrandr
    sudo mkdir -p /etc/X11/xorg.conf.d
    sudo cp configs/xorg/00-keyboard.conf /etc/X11/xorg.conf.d/
}

# Install system monitoring tools
install_monitoring_tools() {
    log "Installing system monitoring tools"
    sudo pacman -S --noconfirm powertop htop neofetch
}

# Setup power management
setup_power_management() {
    log "Setting up power management"
    sudo pacman -S --noconfirm tlp tlp-rdw
    sudo systemctl enable --now tlp.service
    sudo systemctl enable NetworkManager-dispatcher.service
    sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
    
    echo "START_CHARGE_THRESH_BAT0=75" | sudo tee -a /etc/tlp.conf
    echo "STOP_CHARGE_THRESH_BAT0=80" | sudo tee -a /etc/tlp.conf
}

# ThinkPad-specific setup
setup_thinkpad() {
    log "Setting up ThinkPad-specific tools"
    sudo pacman -S --noconfirm acpi_call
}

# Setup display and graphics
setup_graphics() {
    log "Setting up display and graphics"
    sudo pacman -S --noconfirm mesa vulkan-intel intel-media-driver
    
    echo 'Section "Device"
    Identifier "Intel Graphics"
    Driver "modesetting"
    Option "AccelMethod" "glamor"
    Option "DRI" "3"
    Option "TearFree" "true"
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf
    
    sudo pacman -S --noconfirm brightnessctl
    sudo usermod -aG video $USER
}

# Setup input devices
setup_input_devices() {
    log "Setting up input devices"
    sudo pacman -S --noconfirm xf86-input-libinput
    
    echo 'Section "InputClass"
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
EndSection' | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf
}

# Setup Bluetooth
setup_bluetooth() {
    log "Setting up Bluetooth"
    sudo pacman -S --noconfirm bluez bluez-utils
    sudo systemctl enable --now bluetooth.service
    sudo usermod -aG lp $USER
}

# Setup fingerprint reader
setup_fingerprint() {
    log "Setting up fingerprint reader"
    sudo pacman -S --noconfirm fprintd
    # Note: fprintd-enroll should be run manually by the user
}

# Setup webcam
setup_webcam() {
    log "Setting up webcam"
    sudo pacman -S --noconfirm v4l-utils
}

# Optimize SSD for btrfs
optimize_ssd() {
    log "Optimizing SSD for btrfs"
    sudo systemctl enable fstrim.timer
    
    # Note: This part requires manual editing of /etc/fstab
    log "Please manually add 'discard=async' to your btrfs mount options in /etc/fstab"
    log "You can get the PARTUUID by running: blkid /dev/sda2"
}

# Main function
main() {
    enable_network
    setup_audio
    setup_xorg
    install_monitoring_tools
    setup_power_management
    setup_thinkpad
    setup_graphics
    setup_input_devices
    setup_bluetooth
    setup_fingerprint
    setup_webcam
    optimize_ssd
    
    log "Post-installation setup complete. Please reboot your system."
    log "After reboot, remember to manually enroll your fingerprint with 'fprintd-enroll'"
    log "and edit /etc/fstab to add 'discard=async' to your btrfs mount options."
}

main
