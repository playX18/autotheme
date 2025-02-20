#!/bin/bash
while [[ $# -gt 0 ]]; do
    case $1 in
        --light)
            theme="light"
            shift
            ;;
        --dark)
            theme="dark"
            shift
            ;;
        --config-file)
            config_file="$2"
            shift 2
            ;;
        *)
            wallpaper=$1
            shift
            ;;
    esac
done

if [ -z "$config_file" ]; then
    config_file="wallust.toml"
fi

if [ -z "$wallpaper" ]; then
    if command -v gsettings &> /dev/null; then
        wallpaper=$(gsettings get org.gnome.desktop.background picture-uri | sed -e "s/^'//" -e "s/'$//")
    else
        echo "Error: gsettings command not found and no wallpaper URI provided."
        exit 1
    fi
fi

if [ -z "$theme" ]; then
    if command -v gsettings &> /dev/null; then
        theme=$(gsettings get org.gnome.desktop.interface color-scheme | grep -i prefer-dark > /dev/null && echo "dark" || echo "light")
        echo "setting theme to $theme"
    else
        echo "Error: gsettings command not found and no theme specified."
        exit 1
    fi
fi

convert_uri_to_path() {
    local uri=$1
    python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]).replace('file://', '').strip('\''))" "$uri"
}

file_path=$(convert_uri_to_path "$wallpaper")

if [[ "$file_path" == *.jxl ]]; then
    echo "Converting JXL background to PNG..."
    png_path="/tmp/$(basename "$file_path" .jxl).png"
    magick "$file_path" "$png_path"
    file_path="$png_path"
elif [[ "$file_path" == *.svg ]]; then
    echo "Converting SVG background to PNG..."
    png_path="/tmp/$(basename "$file_path" .svg).png"
    magick "$file_path" "$png_path"
    file_path="$png_path"
fi

echo $file_path

if [[ "$theme" == "dark" ]]; then
    palette="dark"
    #config_file="wallust.toml"
    color_space="lab"
    backend="full"
else
    backend="full"
    palette="light"
    color_space="lch"
    #config_file="wallust-light.toml"
fi


wallust run $file_path --backend $backend --palette $palette --colorspace $color_space --config-dir ~/.config/autotheme