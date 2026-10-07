# SSH Basic Examples

Executable examples for
[OKW Remote SSH](https://github.com/Hrabovszki1023/robotframework-okw-remote-ssh) —
remote command execution and file operations via SSH.

## Prerequisites

- Python 3.10+
- `pip install robotframework-okw-remote-ssh`
- An SSH target server (see below)

## SSH Target Setup

The tests expect a host configured as `testhost` in OKW's config files:

**`~/.okw/configs/testhost.yaml`:**

```yaml
host: "192.168.x.z"
port: 22
username: "okwtest"
auth:
  type: password
  secret_id: "testhost/okwtest"
timeout: 10
encoding: "utf-8"
```

**`~/.okw/secrets.yaml`:**

```yaml
secrets:
  testhost/okwtest:
    password: "your-password"
```

For the CI/CD integration test infrastructure, the target is a dedicated
Proxmox LXC container (`okw-ssh-target`). See `docs/ci-cd-pipeline.md`.

## Run

```bash
cd ssh/basic
robot tests/SSH_Basic.robot
```

## What It Demonstrates

| Test | What it shows |
|---|---|
| Kommando Ausfuehren Und Ausgabe Pruefen | Execute command, verify stdout |
| Exit Code Bei Fehler Pruefen | Non-zero exit codes |
| Wildcard Und Regex Matching | WCM and REGX match modes on output |
| Datei Erstellen Und Loeschen | File existence check, remote file removal |

## Links

- [OKW Remote SSH](https://github.com/Hrabovszki1023/robotframework-okw-remote-ssh)
- [OKW4Robot Core](https://github.com/Hrabovszki1023/robotframework-okw4robot)
