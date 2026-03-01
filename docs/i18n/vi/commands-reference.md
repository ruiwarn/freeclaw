# Tham khảo lệnh FreeClaw

Dựa trên CLI hiện tại (`freeclaw --help`).

Xác minh lần cuối: **2026-02-28**.

## Lệnh cấp cao nhất

| Lệnh | Mục đích |
|---|---|
| `onboard` | Khởi tạo workspace/config nhanh hoặc tương tác |
| `agent` | Chạy chat tương tác hoặc chế độ gửi tin nhắn đơn |
| `gateway` | Khởi động gateway webhook và HTTP WhatsApp |
| `daemon` | Khởi động runtime có giám sát (gateway + channels + heartbeat/scheduler tùy chọn) |
| `service` | Quản lý vòng đời dịch vụ cấp hệ điều hành |
| `doctor` | Chạy chẩn đoán và kiểm tra trạng thái |
| `status` | Hiển thị cấu hình và tóm tắt hệ thống |
| `cron` | Quản lý tác vụ định kỳ |
| `models` | Làm mới danh mục model của provider |
| `providers` | Liệt kê ID provider, bí danh và provider đang dùng |
| `channel` | Quản lý kênh và kiểm tra sức khỏe kênh |
| `integrations` | Kiểm tra chi tiết tích hợp |
| `skills` | Liệt kê/cài đặt/gỡ bỏ skills |
| `migrate` | Nhập dữ liệu từ runtime khác (hiện hỗ trợ OpenClaw) |
| `config` | Xuất schema cấu hình dạng máy đọc được |
| `completions` | Tạo script tự hoàn thành cho shell ra stdout |
| `hardware` | Phát hiện và kiểm tra phần cứng USB |
| `peripheral` | Cấu hình và nạp firmware thiết bị ngoại vi |

## Nhóm lệnh

### `onboard`

- `freeclaw onboard`
- `freeclaw onboard --interactive`
- `freeclaw onboard --channels-only`
- `freeclaw onboard --api-key <KEY> --provider <ID> --memory <sqlite|lucid|markdown|none>`
- `freeclaw onboard --api-key <KEY> --provider <ID> --model <MODEL_ID> --memory <sqlite|lucid|markdown|none>`

### `agent`

- `freeclaw agent`
- `freeclaw agent -m "Hello"`
- `freeclaw agent --provider <ID> --model <MODEL> --temperature <0.0-2.0>`
- `freeclaw agent --peripheral <board:path>`

### `gateway` / `daemon`

- `freeclaw gateway [--host <HOST>] [--port <PORT>]`
- `freeclaw daemon [--host <HOST>] [--port <PORT>]`

### `service`

- `freeclaw service install`
- `freeclaw service start`
- `freeclaw service stop`
- `freeclaw service restart`
- `freeclaw service status`
- `freeclaw service uninstall`

### `cron`

- `freeclaw cron list`
- `freeclaw cron add <expr> [--tz <IANA_TZ>] <command>`
- `freeclaw cron add-at <rfc3339_timestamp> <command>`
- `freeclaw cron add-every <every_ms> <command>`
- `freeclaw cron once <delay> <command>`
- `freeclaw cron remove <id>`
- `freeclaw cron pause <id>`
- `freeclaw cron resume <id>`

### `models`

- `freeclaw models refresh`
- `freeclaw models refresh --provider <ID>`
- `freeclaw models refresh --force`
- `freeclaw models list [--provider <ID>]`
- `freeclaw models set <MODEL_REF_HOẶC_MODEL_ID>`
- `freeclaw models status`

Lưu ý:

- `models set` chấp nhận `provider/model` hoặc model id thuần.
- `models status` hiển thị provider/model đã resolve, cùng `models.default.primary` và fallbacks khi có cấu hình.

`models refresh` hiện hỗ trợ làm mới danh mục trực tiếp cho các provider: `openrouter`, `openai`, `anthropic`, `groq`, `mistral`, `deepseek`, `xai`, `together-ai`, `gemini`, `ollama`, `astrai`, `venice`, `fireworks`, `cohere`, `moonshot`, `glm`, `zai`, `qwen` và `nvidia`.

### `channel`

- `freeclaw channel list`
- `freeclaw channel start`
- `freeclaw channel doctor`
- `freeclaw channel bind-telegram <IDENTITY>`
- `freeclaw channel add <type> <json>`
- `freeclaw channel remove <name>`

Lệnh trong chat khi runtime đang chạy (Telegram/Discord):

- `/models` hoặc `/models list` (hiển thị danh sách provider)
- `/models status` (hiển thị provider/model hiện tại)
- `/models <provider>` (chuyển provider cho phiên người gửi hiện tại)
- `/model` hoặc `/model list` (hiển thị model hiện tại và danh sách model đã cache)
- `/model status` (hiển thị provider/model hiện tại)
- `/model <number>` (chuyển model theo số thứ tự trong danh sách cache)
- `/model <model-id>` (chuyển model theo ID)
- `/status` (hiển thị trạng thái runtime đầy đủ theo phiên người gửi)
- `/memory clean` (xem trước các bản ghi hội thoại tự lưu theo phạm vi người gửi để dọn nhiễu)
- `/memory clean current` (bí danh tường minh của `/memory clean`)
- `/memory clean confirm` (xóa các bản ghi đã xem trước ở bước `/memory clean`)
- `/memory clean current confirm` (bí danh tường minh của `/memory clean confirm`)
- `/memory clean all` (xem trước toàn bộ bản ghi memory ở mọi category/session)
- `/memory clean all confirm` (xóa toàn bộ bản ghi đã xem trước)
- `/new` (lưu log hội thoại hiện tại rồi bắt đầu phiên mới)
- `/reset` (bắt đầu phiên mới mà không lưu log)

Channel runtime cũng theo dõi `config.toml` và tự động áp dụng thay đổi cho:
- `models.default.*`
- `models.routes.*`
- `default_provider`
- `default_model`
- `default_temperature`
- `api_key` / `api_url` (cho provider mặc định)
- `reliability.*` cài đặt retry của provider

`add/remove` hiện chuyển hướng về thiết lập có hướng dẫn / cấu hình thủ công (chưa hỗ trợ đầy đủ mutator khai báo).

### `integrations`

- `freeclaw integrations info <name>`

### `skills`

- `freeclaw skills list`
- `freeclaw skills install <source>`
- `freeclaw skills remove <name>`

`<source>` chấp nhận git remote (`https://...`, `http://...`, `ssh://...` và `git@host:owner/repo.git`) hoặc đường dẫn cục bộ.

Skill manifest (`SKILL.toml`) hỗ trợ `prompts` và `[[tools]]`; cả hai được đưa vào system prompt của agent khi chạy, giúp model có thể tuân theo hướng dẫn skill mà không cần đọc thủ công.

### `migrate`

- `freeclaw migrate openclaw [--source <path>] [--dry-run]`

### `config`

- `freeclaw config schema`

`config schema` xuất JSON Schema (draft 2020-12) cho toàn bộ hợp đồng `config.toml` ra stdout.

### `completions`

- `freeclaw completions bash`
- `freeclaw completions fish`
- `freeclaw completions zsh`
- `freeclaw completions powershell`
- `freeclaw completions elvish`

`completions` chỉ xuất ra stdout để script có thể được source trực tiếp mà không bị lẫn log/cảnh báo.

### `hardware`

- `freeclaw hardware discover`
- `freeclaw hardware introspect <path>`
- `freeclaw hardware info [--chip <chip_name>]`

### `peripheral`

- `freeclaw peripheral list`
- `freeclaw peripheral add <board> <path>`
- `freeclaw peripheral flash [--port <serial_port>]`
- `freeclaw peripheral setup-uno-q [--host <ip_or_host>]`
- `freeclaw peripheral flash-nucleo`

## Kiểm tra nhanh

Để xác minh nhanh tài liệu với binary hiện tại:

```bash
freeclaw --help
freeclaw <command> --help
```
