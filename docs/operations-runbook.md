# FreeClaw Operations Runbook

This runbook is for operators who maintain availability, security posture, and incident response.

Last verified: **February 18, 2026**.

## Scope

Use this document for day-2 operations:

- starting and supervising runtime
- health checks and diagnostics
- safe rollout and rollback
- incident triage and recovery

For first-time installation, start from [one-click-bootstrap.md](one-click-bootstrap.md).

## Runtime Modes

| Mode | Command | When to use |
|---|---|---|
| Foreground runtime | `freeclaw daemon` | local debugging, short-lived sessions |
| Foreground gateway only | `freeclaw gateway` | webhook endpoint testing |
| User service | `freeclaw service install && freeclaw service start` | persistent operator-managed runtime |

## Baseline Operator Checklist

1. Validate configuration:

```bash
freeclaw status
```

2. Verify diagnostics:

```bash
freeclaw doctor
freeclaw channel doctor
```

3. Start runtime:

```bash
freeclaw daemon
```

4. For persistent user session service:

```bash
freeclaw service install
freeclaw service start
freeclaw service status
```

## Health and State Signals

| Signal | Command / File | Expected |
|---|---|---|
| Config validity | `freeclaw doctor` | no critical errors |
| Channel connectivity | `freeclaw channel doctor` | configured channels healthy |
| Runtime summary | `freeclaw status` | expected provider/model/channels |
| Daemon heartbeat/state | `~/.freeclaw/daemon_state.json` | file updates periodically |

## Logs and Diagnostics

### macOS / Windows (service wrapper logs)

- `~/.freeclaw/logs/daemon.stdout.log`
- `~/.freeclaw/logs/daemon.stderr.log`

### Linux (systemd user service)

```bash
journalctl --user -u freeclaw.service -f
```

## Incident Triage Flow (Fast Path)

1. Snapshot system state:

```bash
freeclaw status
freeclaw doctor
freeclaw channel doctor
```

2. Check service state:

```bash
freeclaw service status
```

3. If service is unhealthy, restart cleanly:

```bash
freeclaw service stop
freeclaw service start
```

4. If channels still fail, verify allowlists and credentials in `~/.freeclaw/config.toml`.

5. If gateway is involved, verify bind/auth settings (`[gateway]`) and local reachability.

## Safe Change Procedure

Before applying config changes:

1. backup `~/.freeclaw/config.toml`
2. apply one logical change at a time
3. run `freeclaw doctor`
4. restart daemon/service
5. verify with `status` + `channel doctor`

## Rollback Procedure

If a rollout regresses behavior:

1. restore previous `config.toml`
2. restart runtime (`daemon` or `service`)
3. confirm recovery via `doctor` and channel health checks
4. document incident root cause and mitigation

## Related Docs

- [one-click-bootstrap.md](one-click-bootstrap.md)
- [troubleshooting.md](troubleshooting.md)
- [config-reference.md](config-reference.md)
- [commands-reference.md](commands-reference.md)
