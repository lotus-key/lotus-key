# VnIme

Bộ gõ tiếng Việt cho macOS, được viết lại hoàn toàn bằng Swift từ [OpenKey](https://github.com/tuyenvm/OpenKey).

## Tính năng

- **Kiểu gõ**: Telex, Simple Telex
- **Quick Telex**: cc=ch, gg=gi, kk=kh, nn=ng, qq=qu, pp=ph, tt=th
- **Kiểm tra chính tả**: Xác thực các tổ hợp từ tiếng Việt
- **Smart Switch**: Nhớ ngôn ngữ theo từng ứng dụng
- **Tự động viết hoa**: Tự động viết hoa chữ cái đầu câu

## Yêu cầu hệ thống

- macOS 13.0 (Ventura) trở lên
- Quyền truy cập Accessibility (System Settings → Privacy & Security → Accessibility)

## Cài đặt

### Từ source

```bash
# Clone repository
git clone https://github.com/trancong12102/vn-ime.git
cd vn-ime

# Build
swift build -c release

# Chạy ứng dụng
.build/release/VnIme
```

### Từ Release

Tải xuống file `.dmg` từ [Releases](https://github.com/trancong12102/vn-ime/releases) và kéo VnIme vào thư mục Applications.

## Sử dụng

1. Khởi động VnIme
2. Cấp quyền Accessibility khi được yêu cầu
3. Icon VnIme sẽ xuất hiện trên menu bar
4. Click vào icon để chuyển đổi giữa tiếng Việt và tiếng Anh

### Phím tắt

- `Ctrl + Space`: Chuyển đổi ngôn ngữ (mặc định)

### Kiểu gõ Telex

| Phím | Kết quả |
|------|---------|
| aa | â |
| ee | ê |
| oo | ô |
| aw | ă |
| ow | ơ |
| uw | ư |
| dd | đ |
| s | dấu sắc |
| f | dấu huyền |
| r | dấu hỏi |
| x | dấu ngã |
| j | dấu nặng |
| z | xóa dấu |

## Phát triển

### Yêu cầu

- Xcode 15+ hoặc Swift 5.9+
- macOS 13.0+

### Build

```bash
# Build debug
swift build

# Build release
swift build -c release

# Chạy tests
swift test
```

### Cấu trúc dự án

```text
Sources/VnIme/
├── App/                    # Entry point, AppDelegate
├── Core/                   # Vietnamese input engine
│   ├── Engine/             # Main processing logic
│   ├── InputMethods/       # Telex, Simple Telex handlers
│   ├── CharacterTables/    # Unicode encoding
│   └── Spelling/           # Spell checking rules
├── EventHandling/          # CGEventTap, keyboard hook
├── Features/               # Smart Switch, Quick Telex
├── UI/                     # SwiftUI views, Menu bar
├── Storage/                # UserDefaults, settings
└── Utilities/              # Extensions, helpers
```

## Đóng góp

Mọi đóng góp đều được hoan nghênh! Vui lòng:

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Tạo Pull Request

## Giấy phép

Dự án này được phân phối theo giấy phép [GNU General Public License v3.0](LICENSE).

## Lời cảm ơn

- [OpenKey](https://github.com/tuyenvm/OpenKey) - Dự án gốc
- Cộng đồng người dùng tiếng Việt trên macOS
