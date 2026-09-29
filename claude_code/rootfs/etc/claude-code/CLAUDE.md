# Environment: Claude Code add-on on Home Assistant OS

You are running inside the "Claude Code" add-on on the Home Assistant machine
itself (a Docker container managed by the Supervisor). This file describes the
container; the project's own CLAUDE.md files describe the project.

- **Session**: tmux session `claude`. Window `claude` runs this conversation
  (always on, restarted by `claude-loop` if it exits, reachable from the
  Claude app through Remote Control); window `shell` is a plain shell. The HA
  sidebar panel "Claude" shows the same tmux session.
- **Persistent**: only `/data` survives a restart. `HOME=/data/home` (Claude
  login, settings, transcripts, SSH keys). Git clones live in `/data/work`
  and are NOT in Home Assistant backups: push your work, don't leave commits
  only on the box. Everything else is recreated on every add-on start:
  packages installed with `apk` disappear.
- **`/config` is the live Home Assistant configuration** (read-write). Treat it
  as production: never edit files there. Work in the clone in `/data/work`,
  commit, push, then run `ha-deploy` (fetch + fast-forward-only merge into
  `/config`; it never stashes or resets). HA rewrites tracked `.storage` files
  in `/config` constantly; that is expected.
- **Home Assistant API**: `$SUPERVISOR_TOKEN` authenticates
  `http://supervisor/core/api/...` (REST) and `ws://supervisor/core/websocket`.
  The `ha` CLI talks to the Supervisor (`ha core info`, `ha core check`,
  `ha core logs`, `ha apps logs <slug>`, `ha host logs`). Calls that change
  anything (service calls, restarts, registry edits) are live production
  changes.
- **pre-commit**: `/data/venv` holds the Home Assistant version production runs
  (`ha-venv-sync` updates it hourly and at start; run it if `check_config`
  complains about a version). `secrets.yaml` in the clone is a symlink to
  `/config/secrets.yaml`: never print secrets (`hass --script check_config -s`
  and reads of `secrets.yaml` and `.storage/auth*` are denied).
- **SSH**: hosts from the add-on's `ssh_hosts` option are in `~/.ssh/config`
  (`ssh <name>`). GitHub clones use per-repository deploy keys (set in each
  clone's `core.sshCommand`).
- **No browser**: there is no Playwright/Chromium/WebKit here. Visual checks of
  dashboards have to happen elsewhere.
- **Resources**: this is a small ARM board shared with Home Assistant. Avoid
  heavy parallel builds; keep disk use modest (check `df -h /data`).
