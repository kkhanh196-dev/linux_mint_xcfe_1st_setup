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
echo "2. Chấp nhận bản quyền Font Microsoft..."
echo "=========================================="
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

echo "=========================================="
echo "3. Cài phần mềm cơ bản, Codecs & Công cụ biên dịch..."
echo "=========================================="
apt install -y build-essential git curl wget vlc htop fastfetch software-properties-common geany \
               p7zip-full p7zip-rar unzip ttf-mscorefonts-installer mint-meta-codecs \
               flatpak gparted zram-tools ubuntu-drivers-common

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
    echo -e "\n# Cau hinh Bo go Tieng Viet IBus-Bamboo" >> "$BASHRC_FILE"
    echo "export GTK_IM_MODULE=ibus" >> "$BASHRC_FILE"
    echo "export QT_IM_MODULE=ibus" >> "$BASHRC_FILE"
    echo "export XMODIFIERS=@im=ibus" >> "$BASHRC_FILE"
    chown "$SUDO_USER_NAME:$SUDO_USER_NAME" "$BASHRC_FILE"
fi

# Autostart IBus trong XFCE
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
echo "5. Cài đặt Trình duyệt Brave..."
echo "=========================================="
sudo apt install curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
sudo apt update
sudo apt install brave-browser

echo "=========================================="
echo "6. Cài đặt Tailscale, Flathub & Trayscale..."
echo "=========================================="
sudo apt install git
curl -fsSL https://tailscale.com/install.sh | sh

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub dev.deedles.Trayscale -y

echo "=========================================="
echo "7. Biên dịch Driver Vân tay (synaTudor)..."
echo "=========================================="
apt install -y meson ninja-build cmake pkg-config libcrypto++-dev libusb-1.0-0-dev libcap-dev \
               libseccomp-dev libglib2.0-dev libdbus-1-dev libfprint-2-dev libfprint-2-tod-dev \
               libjson-glib-dev innoextract libssl-dev fprintd libpam-fprintd

WORK_DIR=$(mktemp -d)
cd "$WORK_DIR"
git clone https://github.com/Popax21/synaTudor.git
cd synaTudor
meson setup build
ninja -C build
ninja -C build install
systemctl restart fprintd
cd /tmp
rm -rf "$WORK_DIR"

echo "=========================================="
echo "8. Cài đặt & Kích hoạt TLP (Tiết kiệm pin)..."
echo "=========================================="
apt install -y tlp tlp-rdw
tlp start

echo "=========================================="
echo "9. Dọn dẹp hệ thống..."
echo "=========================================="
apt autoremove -y && apt clean

echo "=========================================="
echo " CÀI ĐẶT HOÀN TẤT!"
echo "=========================================="
echo "Các bước cần làm thủ công sau khi khởi động lại:"
echo " 1. Kết nối Tailscale:  sudo tailscale up"
echo " 2. Đăng ký vân tay:    fprintd-enroll"
echo " 3. Kích hoạt PAM:      sudo pam-auth-update (Tích chọn 'Fingerprint authentication')"
echo "=========================================="
