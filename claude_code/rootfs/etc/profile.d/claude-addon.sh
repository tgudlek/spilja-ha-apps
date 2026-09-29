# Login shells: /etc/profile resets PATH; put back the add-on's tools
# (Claude Code in ~/.local/bin, the Home Assistant venv for pre-commit).
export PATH="/data/home/.local/bin:/data/venv/bin:$PATH"
