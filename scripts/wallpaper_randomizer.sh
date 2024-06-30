#/bin/bash

# Define constants for file paths
WALLPAPER_DIR="$HOME/library/media/images/wallpapers"
FILE_LIST="$HOME/.wallpaper_file_list"
CACHE_FILE="$HOME/.wallpaper_cache"

# Function to update the list of wallpapers
update_wallpaper_list() {
    # Find all jpg and png files in the wallpaper directory and save to FILE_LIST
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) > "$FILE_LIST"
    echo "Wallpaper list updated."
}

# Function to get a random wallpaper
get_random_wallpaper() {
    # If FILE_LIST doesn't exist, create it
    if [[ ! -f "$FILE_LIST" ]]; then
        update_wallpaper_list
    fi
    # Select a random line from FILE_LIST
    shuf -n 1 "$FILE_LIST"
}

main() {
    # Check if the script was called with the "update" argument
    if [[ "$1" == "update" ]]; then
        update_wallpaper_list
        exit 0
    fi

    # Get list of connected displays
    local displays=$(xrandr --query | grep " connected" | cut -d " " -f1)
    local current_displays=$(echo "$displays" | wc -l)

    # Check if cache exists and is still valid
    if [[  -f "$CACHE_FILE" ]]; then
        source "$CACHE_FILE"
        if [[ "$current_displays" -eq "$cached_displays" ]]; then
            # If number of displays hasn't changed, use cached wallpapers
            feh --no-fehbg --bg-fill ${WALLPAPERS[@]}
            exit 0
        fi
    fi

    # Select new wallpapers
    WALLPAPERS=()
    for display in $displays; do
        WALLPAPERS+=($(get_random_wallpaper))
    done

    # Set wallpapers
    feh --no-fehbg --bg-fill "${WALLPAPERS[@]}"

    # Save cache
    echo "cached_displays=$current_displays" > "$CACHE_FILE"
    echo "WALLPAPERS=(${WALLPAPERS[*]})" >> "$CACHE_FILE"
}

# Run the main function with all provided arguments
main "$@"
