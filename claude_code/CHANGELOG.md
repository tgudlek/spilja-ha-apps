# Changelog

## 0.1.3

- Keep only the Claude Code version in use (old ones piled up at ~250 MB each)
  and clear the uv/pip caches at every start; pip installs without a cache.

## 0.1.2

- Start Claude with `--model` from the options, so a continued conversation
  switches to it too (a resumed conversation kept the model it began with).
- rc-watchdog reads Claude Code's own session record (`bridgeSessionId`) to
  tell whether Remote Control is connected, instead of screen text that the
  conversation could quote.

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
