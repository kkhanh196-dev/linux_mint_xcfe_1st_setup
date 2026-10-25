#!/bin/bash
set -e

echo "=== 1. Cập nhật hệ thống và cài đặt công cụ cần thiết ==="
sudo apt update
sudo apt install -y git curl wget unzip plank xfce4-goodies software-properties-common picom xfwm4 sassc

echo "=== 2. Cài đặt Ulauncher ==="
sudo add-apt-repository ppa:agornostal/ulauncher -y
sudo apt update
sudo apt install -y ulauncher

echo "=== 3. Tạo thư mục cấu hình theme, icons và autostart ==="
mkdir -p ~/.themes ~/.icons ~/.config/autostart ~/.config/picom

echo "=== 4. Tải và cài đặt WhiteSur Icon Theme (macOS Style) ==="
cd /tmp
rm -rf WhiteSur-icon-theme
git clone --depth 1 https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-icon-theme
./install.sh -d ~/.icons

echo "=== 5. Tải và cài đặt Fluent GTK Theme (Giao diện Tối) ==="
cd /tmp
rm -rf Fluent-gtk-theme
git clone --depth 1 https://github.com/vinceliuice/Fluent-gtk-theme.git
cd Fluent-gtk-theme
./install.sh --color dark --size compact

echo "=== 6. Tải và cài đặt Font chữ Inter ==="
cd /tmp
wget -q https://github.com/rsms/inter/releases/download/v3.19/Inter-3.19.zip -O inter.zip
unzip -q -o inter.zip -d inter_font
mkdir -p ~/.local/share/fonts
cp inter_font/Inter\ Desktop/*.otf ~/.local/share/fonts/ 2>/dev/null || cp inter_font/*.otf ~/.local/share/fonts/ 2>/dev/null || true
fc-cache -f -v

echo "=== 7. Áp dụng Giao diện & Biểu tượng mới ==="
xfconf-query -c xsettings -p /Net/ThemeName -s "Fluent-Dark-Compact" --create -t string 2>/dev/null || xfconf-query -c xsettings -p /Net/ThemeName -s "Fluent-Dark-Compact"
xfconf-query -c xsettings -p /Net/IconThemeName -s "WhiteSur-dark" --create -t string 2>/dev/null || xfconf-query -c xsettings -p /Net/IconThemeName -s "WhiteSur-dark"
xfconf-query -c xfwm4 -p /general/theme -s "Fluent-Dark-Compact" --create -t string 2>/dev/null || xfconf-query -c xfwm4 -p /general/theme -s "Fluent-Dark-Compact"
xfconf-query -c xsettings -p /Gtk/FontName -s "Inter Regular 10" --create -t string 2>/dev/null || xfconf-query -c xsettings -p /Gtk/FontName -s "Inter Regular 10"

#echo "=== 8. Cấu hình hiệu ứng thu phóng cửa sổ (Picom Compositor) ==="
#xfconf-query -c xfwm4 -p /general/use_compositing -s false --create -t bool 2>/dev/null || xfconf-query -c xfwm4 -p /general/use_compositing -s false

#cat << 'PICOM_CONF' > ~/.config/picom/picom.conf
# Backend đệm đồ họa mượt mà
#backend = "glx";
#vsync = true;

# Hiệu ứng làm mờ/thu phóng khi đóng mở & ẩn hiện cửa sổ
#fading = true;
#fade-in-step = 0.04;
#fade-out-step = 0.04;
#fade-delta = 5;

# Hiệu ứng bóng đổ cửa sổ (macOS style)
#shadow = true;
#shadow-radius = 12;
#shadow-opacity = 0.4;
#shadow-offset-x = -10;
#shadow-offset-y = -10;

# Bo tròn góc cửa sổ
#corner-radius = 8;
#rounded-corners-exclude = [
#  "window_type = 'dock'",
#  "window_type = 'desktop'"
#];
#PICOM_CONF

echo "=== 9. Cấu hình tự động chạy Plank, Ulauncher & Picom khi khởi động ==="
cat << 'AUTOSTART_PLANK' > ~/.config/autostart/plank.desktop
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
Comment=Stupidly simple dock
AUTOSTART_PLANK

cat << 'AUTOSTART_ULAUNCHER' > ~/.config/autostart/ulauncher.desktop
[Desktop Entry]
Type=Application
Exec=ulauncher --hide-window
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Ulauncher
Comment=Application launcher
AUTOSTART_ULAUNCHER

#cat << 'AUTOSTART_PICOM' > ~/.config/autostart/picom.desktop
#[Desktop Entry]
#Type=Application
#Exec=picom -b
#Hidden=false
#NoDisplay=false
#X-GNOME-Autostart-enabled=true
#Name=Picom
#Comment=Compositor with window animations
#AUTOSTART_PICOM

echo "=== Hoàn thành! Hãy đăng xuất và đăng nhập lại để trải nghiệm giao diện mới ==="
