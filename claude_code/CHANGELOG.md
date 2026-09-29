# Changelog

## 0.1.1

- Follow the `latest` Claude Code channel by default: `stable` (2.1.277) doesn't
  know Opus 5.5, so `opus` meant Opus 5 there.
- Update Claude Code to the channel's current release on every start, before
  the session starts.

## 0.1.0

- First version: always-on Claude Code session with Remote Control, sidebar
  panel (ttyd + tmux behind an ingress-only nginx), deploy-key clones,
  `ha-deploy`, a Home Assistant venv for pre-commit, and a watchdog that
  restarts Claude Code when Remote Control gives up.
