# Tài liệu Bắt đầu

Dành cho cài đặt lần đầu và làm quen nhanh.

## Lộ trình bắt đầu

1. Tổng quan và khởi động nhanh: [../../README.vi.md](../../README.vi.md)
2. Cài đặt một lệnh và chế độ bootstrap kép: [../one-click-bootstrap.md](../one-click-bootstrap.md)
3. Tìm lệnh theo tác vụ: [../commands-reference.md](../commands-reference.md)

## Chọn hướng đi

| Tình huống | Lệnh |
|----------|---------|
| Có API key, muốn cài nhanh nhất | `freeclaw onboard --api-key sk-... --provider openrouter` |
| Muốn được hướng dẫn từng bước | `freeclaw onboard --interactive` |
| Đã có config, chỉ cần sửa kênh | `freeclaw onboard --channels-only` |
| Dùng xác thực subscription | Xem [Subscription Auth](../../README.vi.md#subscription-auth-openai-codex--claude-code) |

## Thiết lập và kiểm tra

- Thiết lập nhanh: `freeclaw onboard --api-key "sk-..." --provider openrouter`
- Thiết lập tương tác: `freeclaw onboard --interactive`
- Kiểm tra môi trường: `freeclaw status` + `freeclaw doctor`

## Tiếp theo

- Vận hành runtime: [../operations/README.md](../operations/README.md)
- Tra cứu tham khảo: [../reference/README.md](../reference/README.md)
