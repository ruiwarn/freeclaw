# FreeClaw Commands Reference

This reference is derived from the current CLI surface (`freeclaw --help`).

Last verified: **February 28, 2026**.

## Top-Level Commands

| Command | Purpose |
|---|---|
| `onboard` | Initialize workspace/config quickly or interactively |
| `agent` | Run interactive chat or single-message mode |
| `gateway` | Start webhook and WhatsApp HTTP gateway |
| `daemon` | Start supervised runtime (gateway + channels + optional heartbeat/scheduler) |
| `service` | Manage user-level OS service lifecycle |
| `doctor` | Run diagnostics and freshness checks |
| `status` | Print current configuration and system summary |
| `estop` | Engage/resume emergency stop levels and inspect estop state |
| `cron` | Manage scheduled tasks |
| `models` | Refresh provider model catalogs |
| `providers` | List provider IDs, aliases, and active provider |
| `channel` | Manage channels and channel health checks |
| `integrations` | Inspect integration details |
| `skills` | List/install/remove skills |
| `migrate` | Import from external runtimes (currently OpenClaw) |
| `config` | Export machine-readable config schema |
| `completions` | Generate shell completion scripts to stdout |
| `hardware` | Discover and introspect USB hardware |
| `peripheral` | Configure and flash peripherals |

## Command Groups

### `onboard`

- `freeclaw onboard`
- `freeclaw onboard --interactive`
- `freeclaw onboard --channels-only`
- `freeclaw onboard --force`
- `freeclaw onboard --api-key <KEY> --provider <ID> --memory <sqlite|lucid|markdown|none>`
- `freeclaw onboard --api-key <KEY> --provider <ID> --model <MODEL_ID> --memory <sqlite|lucid|markdown|none>`
- `freeclaw onboard --api-key <KEY> --provider <ID> --model <MODEL_ID> --memory <sqlite|lucid|markdown|none> --force`

`onboard` safety behavior:

- If `config.toml` already exists and you run `--interactive`, onboarding now offers two modes:
  - Full onboarding (overwrite `config.toml`)
  - Provider-only update (update provider/model/API key while preserving existing channels, tunnel, memory, hooks, and other settings)
- In non-interactive environments, existing `config.toml` causes a safe refusal unless `--force` is passed.
- Use `freeclaw onboard --channels-only` when you only need to rotate channel tokens/allowlists.

### `agent`

- `freeclaw agent`
- `freeclaw agent -m "Hello"`
- `freeclaw agent --provider <ID> --model <MODEL> --temperature <0.0-2.0>`
- `freeclaw agent --peripheral <board:path>`

Tip:

- In interactive chat, you can ask for route changes in natural language (for example “conversation uses kimi, coding uses gpt-5.3-codex”); the assistant can persist this via tool `model_routing_config`.

### `gateway` / `daemon`

- `freeclaw gateway [--host <HOST>] [--port <PORT>]`
- `freeclaw daemon [--host <HOST>] [--port <PORT>]`

### `estop`

- `freeclaw estop` (engage `kill-all`)
- `freeclaw estop --level network-kill`
- `freeclaw estop --level domain-block --domain "*.chase.com" [--domain "*.paypal.com"]`
- `freeclaw estop --level tool-freeze --tool shell [--tool browser]`
- `freeclaw estop status`
- `freeclaw estop resume`
- `freeclaw estop resume --network`
- `freeclaw estop resume --domain "*.chase.com"`
- `freeclaw estop resume --tool shell`
- `freeclaw estop resume --otp <123456>`

Notes:

- `estop` commands require `[security.estop].enabled = true`.
- When `[security.estop].require_otp_to_resume = true`, `resume` requires OTP validation.
- OTP prompt appears automatically if `--otp` is omitted.

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

Notes:

- Mutating schedule/cron actions require `cron.enabled = true`.
- Shell command payloads for schedule creation (`create` / `add` / `once`) are validated by security command policy before job persistence.

### `models`

- `freeclaw models refresh`
- `freeclaw models refresh --provider <ID>`
- `freeclaw models refresh --force`
- `freeclaw models list [--provider <ID>]`
- `freeclaw models set <MODEL_REF_OR_MODEL_ID>`
- `freeclaw models status`

Notes:

- `models set` accepts either `provider/model` or a raw model id.
- `models status` shows resolved provider/model plus `models.default.primary` and fallbacks when configured.

`models refresh` currently supports live catalog refresh for provider IDs: `openrouter`, `openai`, `anthropic`, `groq`, `mistral`, `deepseek`, `xai`, `together-ai`, `gemini`, `ollama`, `llamacpp`, `sglang`, `vllm`, `astrai`, `venice`, `fireworks`, `cohere`, `moonshot`, `glm`, `zai`, `qwen`, and `nvidia`.

### `doctor`

- `freeclaw doctor`
- `freeclaw doctor models [--provider <ID>] [--use-cache]`
- `freeclaw doctor traces [--limit <N>] [--event <TYPE>] [--contains <TEXT>]`
- `freeclaw doctor traces --id <TRACE_ID>`

`doctor traces` reads runtime tool/model diagnostics from `observability.runtime_trace_path`.

### `channel`

- `freeclaw channel list`
- `freeclaw channel start`
- `freeclaw channel doctor`
- `freeclaw channel bind-telegram <IDENTITY>`
- `freeclaw channel add <type> <json>`
- `freeclaw channel remove <name>`

Runtime in-chat commands (Telegram/Discord while channel server is running):

- `/models` or `/models list` (show provider list)
- `/models status` (show current provider/model)
- `/models <provider>` (switch provider for current sender session)
- `/model` or `/model list` (show current model and cached model list)
- `/model status` (show current provider/model)
- `/model <number>` (switch by cached model index)
- `/model <model-id>` (switch by model ID)
- `/status` (show full sender-scoped runtime status)
- `/memory clean` (preview sender-scoped autosaved conversation memories)
- `/memory clean current` (explicit alias of `/memory clean`)
- `/memory clean confirm` (delete the previewed sender-scoped conversation memories)
- `/memory clean current confirm` (explicit alias of `/memory clean confirm`)
- `/memory clean all` (preview all memory entries across categories/sessions)
- `/memory clean all confirm` (delete all previewed memory entries)
- `/new` (archive current sender session log, then start a new session)
- `/reset` (start a new session without archiving log)

Channel runtime also watches `config.toml` and hot-applies updates to:
- `models.default.*`
- `models.routes.*`
- `default_provider`
- `default_model`
- `default_temperature`
- `api_key` / `api_url` (for the default provider)
- `reliability.*` provider retry settings

`add/remove` currently route you back to managed setup/manual config paths (not full declarative mutators yet).

### `integrations`

- `freeclaw integrations info <name>`

### `skills`

- `freeclaw skills list`
- `freeclaw skills audit <source_or_name>`
- `freeclaw skills install <source>`
- `freeclaw skills remove <name>`

`<source>` accepts git remotes (`https://...`, `http://...`, `ssh://...`, and `git@host:owner/repo.git`) or a local filesystem path.

`skills install` always runs a built-in static security audit before the skill is accepted. The audit blocks:
- symlinks inside the skill package
- script-like files (`.sh`, `.bash`, `.zsh`, `.ps1`, `.bat`, `.cmd`)
- high-risk command snippets (for example pipe-to-shell payloads)
- markdown links that escape the skill root, point to remote markdown, or target script files

Use `skills audit` to manually validate a candidate skill directory (or an installed skill by name) before sharing it.

Skill manifests (`SKILL.toml`) support `prompts` and `[[tools]]`; both are injected into the agent system prompt at runtime, so the model can follow skill instructions without manually reading skill files.

### `migrate`

- `freeclaw migrate openclaw [--source <path>] [--dry-run]`

### `config`

- `freeclaw config schema`

`config schema` prints a JSON Schema (draft 2020-12) for the full `config.toml` contract to stdout.

### `completions`

- `freeclaw completions bash`
- `freeclaw completions fish`
- `freeclaw completions zsh`
- `freeclaw completions powershell`
- `freeclaw completions elvish`

`completions` is stdout-only by design so scripts can be sourced directly without log/warning contamination.

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

## Validation Tip

To verify docs against your current binary quickly:

```bash
freeclaw --help
freeclaw <command> --help
```
