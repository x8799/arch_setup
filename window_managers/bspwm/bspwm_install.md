# Installation and Configuration

```textile
   ___  _______ _      ____  ___
  / _ )/ __/ _ \ | /| / /  |/  /
 / _  |\ \/ ___/ |/ |/ / /|_/ / 
/____/___/_/   |__/|__/_/  /_/  
                                
```

![BSPWM Setup](demo.png)

## Install necessary packages

```bash
sudo pacman -S bspwm sxhkd rofi picom feh alacritty polybar tmux xclip ttf-font-awesome
```

## Copy configuration files

```bash
cp -r arch_setup/window_managers/bspwm/.config ~/
cp -r arch_setup/window_managers/bspwm/.xinitrc ~/
```

## Configure udev rule for monitor hotplug

To automatically update wallpapers when connecting or disconnecting monitors, create a udev rule:

1. Create a new file `/etc/udev/rules.d/95-monitor-hotplug.rules`:

   ```bash
   sudo vim /etc/udev/rules.d/95-monitor-hotplug.rules
   ```

2. Add the following content to the file:

   ```bash
   echo 'ACTION=="change", SUBSYSTEM=="drm", RUN+="/bin/su $USER -c '/home/$USER/library/system/configs/arch_setup/scripts/wallpaper_randomizer.sh'"' | sudo tee /etc/udev/rules.d/95-monitor-hotplug.rules
   ```

3. Reload udev rules:

   ```bash
   sudo udevadm control --reload-rules
   ```
