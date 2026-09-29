# Claude Code

An always-on [Claude Code](https://code.claude.com) session on your Home
Assistant machine. The same session shows in the **Claude** sidebar panel and in
the Claude app (claude.ai, iOS, Android) through **Remote Control**, so you can
work on your configuration from your phone without a laptop.

## How it works

- At start the add-on opens a tmux session with two windows: `claude` (the
  session) and `shell`. The sidebar panel attaches to it. Closing the panel
  only detaches; the session keeps running.
- The session starts with Remote Control on, and continues its last
  conversation after every restart, update or reboot, so the Claude app finds it
  again without anyone opening the panel. If Claude Code exits it is started
  again; if Remote Control gives up after an outage (for example "Previous
  session is unavailable"), a watchdog restarts it.
- Claude Code is installed with Anthropic's native installer into `/data` and
  updates itself; the new version is used after the next add-on restart.
- Git repositories you list are cloned into `/data/work`, each with its own
  deploy key. The session works there, and `ha-deploy` fast-forwards the live
  `/config` to what you pushed. Nothing edits `/config` directly.
- If the working repository is a Home Assistant configuration, a Python venv
  with the exact Home Assistant version you run is installed, so pre-commit's
  `check_config` works on the box.

## First start

1. Set the options (below): at least `panel_users` (your Home Assistant
   username), `repositories` and `git_name`/`git_email`. Start the add-on.
   The **Log** tab prints the public keys:
   - one deploy key per repository: add each on GitHub (repository →
     Settings → Deploy keys) with **write access** if the session should push;
   - one key for `ssh_hosts`: add it to `~/.ssh/authorized_keys` on each host.
   Repositories are cloned automatically within 5 minutes of the key working.
2. Turn on **Show in sidebar** on the Info tab and open **Claude**, from a
   computer (the panel's terminal is hard to type in on a phone). Until the
   first repository is cloned the window says it is waiting for it:
   - pick a theme, then log in with your claude.ai account (`/login`). Remote
     Control needs a full claude.ai login; API keys and `claude setup-token`
     tokens can't start Remote Control sessions.
   - trust the folder when asked.
3. In the Claude app, open **Code**: the session shows under the name set in
   `session_name`. Permission prompts and "Claude needs you" notifications
   arrive there.
4. Turn on **Start on boot** and **Watchdog** on the add-on's Info tab.

## Options

| Option | Default | What it does |
|---|---|---|
| `session_name` | Home Assistant | Name of the session in the Claude app |
| `panel_users` | none | Home Assistant usernames allowed into the sidebar panel. Empty = nobody. (The add-on's `panel_admin` only hides the entry; this is the check.) |
| `model` | `opus` | Default model (`opus`, `sonnet`, or a model ID) |
| `effort` | `xhigh` | Effort level the session starts with (`--effort`, so it applies to every model) |
| `ultracode` | `true` | Start sessions with ultracode (Claude plans a multi-agent workflow for each substantive task; uses much more of your plan's usage) |
| `permission_mode` | `auto` | Starting permission mode: `auto` (a classifier approves routine actions and asks you about risky ones), `default` (asks before edits and commands), `acceptEdits`, `plan` |
| `update_channel` | `stable` | Claude Code release channel |
| `repositories` | none | `git@github.com:owner/repo.git` entries to clone into `/data/work` |
| `working_directory` | first repository | Where the session starts |
| `memory_directory` | Claude's default | Where Claude keeps its auto memory, for example a folder inside a clone so it's versioned and shared with other machines |
| `ssh_hosts` | none | `name=user@host` entries; the session can `ssh name` |
| `git_name`, `git_email` | none | Identity for commits made on the box |

The add-on writes these into Claude Code's user settings
(`/data/home/.claude/settings.json`) at every start. Anything else you add
there, such as allow rules, is kept. Rules the session must not lose (deny
reading secrets, never edit `/config` directly, ask before irreversible
Supervisor commands, and a description of this production environment for
auto mode's classifier) are in `/etc/claude-code/managed-settings.json`, which
comes with the add-on and can't be changed from inside the session.

## Commands in the shell window

- `ha-deploy`: `git fetch` + fast-forward-only merge of `/config` to its
  upstream branch. Never stashes or resets.
- `ha-venv-sync [version]`: install the Home Assistant version production runs
  into `/data/venv` (for `check_config`).
- `ha ...`: the Supervisor CLI.
- `Ctrl-b n` switches between the `claude` and `shell` windows.

## Security

Read this before installing. Whoever controls the session controls your home:

- The add-on can write the live configuration. Code placed there (a custom
  integration) runs inside Home Assistant Core, which has full access to the
  host. Treat the session as root on the machine.
- With the `manager` role it can also restart and reconfigure add-ons, read
  their options (which can hold tokens and passwords) and manage backups.
- Anyone who can use your claude.ai account can drive the session through
  Remote Control. Use a strong password with two-factor authentication, and
  consider **Require trusted devices** in your claude.ai account settings.
- Only the users in `panel_users` can open the panel. Home Assistant's
  `panel_admin` flag only hides the sidebar entry from non-admins.
- The Claude login, SSH keys and conversation transcripts are stored in
  `/data` and are included in Home Assistant backups (encrypt them).
- Permission rules (`permission_mode`, allow/deny rules) are guard rails, not a
  sandbox. `auto` mode's classifier can be fooled by instructions hidden in
  logs, device names or web pages; `default` asks you about every command.

## Limitations

- Only `/data` survives a restart. Packages installed with `apk` are gone after
  the next restart.
- The clones in `/data/work` are not in backups (they can be cloned again).
  Push your work: commits that exist only on the box are lost on a restore.
- A running session keeps using the Claude Code version it started with;
  updates apply after the add-on restarts.
- No browser in the container, so no Playwright or screenshot checks.
- The terminal is usable in desktop browsers. On phones, use the Claude app.
