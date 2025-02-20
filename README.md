# gnome-autotheme

Automatically generate theme for GNOME based on current wallpaper and preferred color theme. 

# Requirements

- Rust/Cargo installed
- ImageMagick (if you want to convert SVG or JXL wallpapers automatically)
- [adw-gtk3](https://github.com/lassekongo83/adw-gtk3)(Optional) - install if you want to change GTK3 style as well
- Done

# Installation

Just 3 simpel commands: 
```
git clone https://github.com/playx18/gnome-autotheme
cd gnome-autotheme
./install.sh
```

Now try changing wallpaper or change GNOME appearance from Dark style to Default.

# How

We use Wallust to extract color theme from wallpaper and generate [`adw-colors`](https://github.com/lassekongo83/adw-colors/) compatible `gtk.css`. Regular wal cache is also generated which allows using pywal for VSCode/Vim/Firefox/whatever as well. 

We get notified of wallpaper change or style change using dbus, you can check Rust source code for the simple program. This
program is then served as a user service in systemd. 

# Adding templates

Simply add your template to `templates/` directory, update `wallust.toml`, `wallust-light.toml` and execute `./install.sh` again. 

# TODOs

- KDE support: figure out kreadconfig/kwriteconfig and all the available options, dbus on kde? 
- Cinnamon/XFCE support: the same, figure out how dbus works there and also add DE detection.