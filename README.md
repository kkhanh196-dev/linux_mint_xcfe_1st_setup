file .sh cài đặt Linux mint khi khởi động lần đầu, bao gồm một số cơ bản ứng dụng và bộ gõ tiếng Việt.
1. link tải:
curl -fsSL https://raw.githubusercontent.com/kkhanh196-dev/linux_mint_xcfe_1st_setup/main/set_up_linux_mint_xcfe_1.sh -o setup_mint.sh

2. Hướng dẫn sử dụng dấu vân tay
# thêm dấu vân tay:
fprintd-enroll
# xóa dấu vân tay:
fprintd-delete
# Kích hoạt xác thực hệ thống:
sudo pam-auth-update
-> Dùng phím mũi tên chuyển đến Fingerprint authentication.
-> Nhấn phím Space (Khoảng trắng) để chọn [*].
-> Nhấn Tab để chọn OK và bấm Enter.
