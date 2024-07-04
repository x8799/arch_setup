#!/bin/bash

source scripts/utils.sh
source configs/install_config.sh

enable_network() {
    log "Enabling NetworkManager"
    run_command "sudo systemctl enable --now NetworkManager"
}

setup_audio() {
    log "Setting up audio"
    run_command "systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service"
    run_command "systemctl --user start pipewire.service pipewire-pulse.service wireplumber.service"
}

setup_xorg() {
    log "Installing and configuring Xorg"
    run_command "sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-xrandr"
    run_command "sudo mkdir -p /etc/X11/xorg.conf.d"
    run_command "sudo cp configs/xorg/00-keyboard.conf /etc/X11/xorg.conf.d/"
}

install_monitoring_tools() {
    log "Installing system monitoring tools"
    run_command "sudo pacman -S --noconfirm powertop htop neofetch"
}

setup_power_management() {
    log "Setting up power management"
    run_command "sudo pacman -S --noconfirm tlp tlp-rdw"
    run_command "sudo systemctl enable --now tlp.service"
    run_command "sudo systemctl enable NetworkManager-dispatcher.service"
    run_command "sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket"
    run_command "echo \"START_CHARGE_THRESH_BAT0=75\" | sudo tee -a /etc/tlp.conf"
    run_command "echo \"STOP_CHARGE_THRESH_BAT0=80\" | sudo tee -a /etc/tlp.conf"
}

setup_thinkpad() {
    log "Setting up ThinkPad-specific tools"
    run_command "sudo pacman -S --noconfirm acpi_call"
}

setup_graphics() {
    log "Setting up display and graphics"
    run_command "sudo pacman -S --noconfirm mesa vulkan-intel intel-media-driver"
    run_command "echo 'Section \"Device\"
    Identifier \"Intel Graphics\"
    Driver \"modesetting\"
    Option \"AccelMethod\" \"glamor\"
    Option \"DRI\" \"3\"
    Option \"TearFree\" \"true\"
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf"
    run_command "sudo pacman -S --noconfirm brightnessctl"
    run_command "sudo usermod -aG video $USER"
}

setup_input_devices() {
    log "Setting up input devices"
    run_command "sudo pacman -S --noconfirm xf86-input-libinput"
    run_command "echo 'Section \"InputClass\"
    Identifier \"libinput touchpad catchall\"
    MatchIsTouchpad \"on\"
    Driver \"libinput\"
    Option \"Tapping\" \"on\"
    Option \"NaturalScrolling\" \"true\"
    Option \"ClickMethod\" \"clickfinger\"
EndSection

Section \"InputClass\"
    Identifier \"libinput trackpoint catchall\"
    MatchIsPointer \"on\"
    MatchProduct \"TrackPoint\"
    Driver \"libinput\"
    Option \"AccelSpeed\" \"0.5\"
EndSection' | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf"
}

setup_bluetooth() {
    log "Setting up Bluetooth"
    run_command "sudo pacman -S --noconfirm bluez bluez-utils"
    run_command "sudo systemctl enable --now bluetooth.service"
    run_command "sudo usermod -aG lp $USER"
}

setup_fingerprint() {
    log "Setting up fingerprint reader"
    run_command "sudo pacman -S --noconfirm fprintd"
}

setup_webcam() {
    log "Setting up webcam"
    run_command "sudo pacman -S --noconfirm v4l-utils"
}

optimize_ssd() {
    log "Optimizing SSD for btrfs"
    run_command "sudo systemctl enable fstrim.timer"
    log "Please manually add 'discard=async' to your btrfs mount options in /etc/fstab"
    log "You can get the PARTUUID by running: blkid /dev/sda2"
}

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
