#!/bin/bash

# 1. Lấy thông tin user thực sự đang đăng nhập
SUDO_USER_NAME=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$SUDO_USER_NAME" | cut -d: -f6)

# 2. Tự động chuyển sang quyền sudo nếu chưa có
if [ "$EUID" -ne 0 ]; then
    echo "Chưa có quyền root, đang chuyển sang sudo..."
    exec sudo "$0" "$@"
fi

echo "=========================================="
echo "1. Cập nhật hệ thống..."
echo "=========================================="
apt update && apt upgrade -y

echo "=========================================="
echo "2. Tự động chấp nhận bản quyền Font Microsoft..."
echo "=========================================="
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

echo "=========================================="
echo "3. Cài đặt phần mềm cơ bản & Tiện ích giải nén..."
echo "=========================================="
apt install -y git curl wget vlc htop fastfetch software-properties-common geany \
               p7zip-full p7zip-rar unzip ttf-mscorefonts-installer ubuntu-restricted-extras

echo "=========================================="
echo "4. Cài đặt IBus-Bamboo cho XFCE..."
echo "=========================================="
add-apt-repository ppa:bamboo-engine/ibus-bamboo -y
apt update
apt install -y ibus ibus-bamboo im-config

# Đặt IBus làm bộ gõ mặc định
im-config -n ibus

# Cấu hình biến môi trường vào .bashrc
BASHRC_FILE="$USER_HOME/.bashrc"
if ! grep -q "GTK_IM_MODULE=ibus" "$BASHRC_FILE"; then
    echo -e "\n# Cau hinh Bo go Tieng Viet IBus-Bamboo (XFCE)" >> "$BASHRC_FILE"
    echo "export GTK_IM_MODULE=ibus" >> "$BASHRC_FILE"
    echo "export QT_IM_MODULE=ibus" >> "$BASHRC_FILE"
    echo "export XMODIFIERS=@im=ibus" >> "$BASHRC_FILE"
    chown "$SUDO_USER_NAME:$SUDO_USER_NAME" "$BASHRC_FILE"
fi

# Thiết lập IBus khởi động cùng XFCE
AUTOSTART_DIR="$USER_HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
cat << 'EOF' > "$AUTOSTART_DIR/ibus-autostart.desktop"
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Name=IBus Daemon
Comment=Start IBus Daemon for Vietnamese Input
Exec=ibus-daemon -drx
OnlyShowIn=XFCE;
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
EOF
chown -R "$SUDO_USER_NAME:$SUDO_USER_NAME" "$AUTOSTART_DIR"

# Nạp engine Bamboo mặc định
su - "$SUDO_USER_NAME" -c "dconf write /desktop/ibus/general/preload-engines \"['xkb:us::eng', 'bamboo']\"" 2>/dev/null || true

echo "=========================================="
echo "5. Cài đặt Google Chrome..."
echo "=========================================="
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
apt install -y /tmp/chrome.deb
rm /tmp/chrome.deb

echo "=========================================="
echo "6. Cài đặt Tailscale & Flathub..."
echo "=========================================="
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# Bật Flathub và cài Trayscale làm GUI cho Tailscale
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub dev.deedles.Trayscale -y

echo "=========================================="
echo "7.Thiết lập vân tay ..."
echo "=========================================="
#Thiết lập vân tay
sudo apt install meson cmake pkg-config libcrypto++-dev libusb-1.0-0-dev libcap-dev libseccomp-dev libglib2.0-dev libdbus-1-dev libfprint-2-dev libfprint-2-tod-dev libjson-glib-dev innoextract libssl-dev fprintd libpam-fprintd
git clone https://github.com/Popax21/synaTudor.git
cd synaTudor
meson setup build
ninja -C build
sudo ninja -C build install
sudo systemctl restart fprintd
#Sau khi cài đặt xong, bạn tiến hành đăng ký vân tay bằng lệnh:
fprintd-enroll
#Kích hoạt xác thực hệ thống
sudo pam-auth-update

echo "=========================================="
echo "8. Dọn dẹp hệ thống..."
echo "=========================================="
apt autoremove -y && apt clean

echo "=========================================="
echo "CÀI ĐẶT HOÀN TẤT!"
echo "Hãy KHỞI ĐỘNG LẠI MÁY để hoàn tất cấu hình."
echo "=========================================="

