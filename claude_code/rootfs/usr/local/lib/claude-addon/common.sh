# Shared helpers for the add-on's scripts. Source it; don't run it.

OPTIONS=/data/options.json
WORK=/data/work
TMUX_SESSION=claude
FRESH_FLAG=/data/home/.claude-addon-fresh   # next start without --continue

# opt <key>: an add-on option as plain text ("" when unset)
opt() { jq -r --arg k "$1" '.[$k] // "" | if type == "array" then .[] else . end' "$OPTIONS"; }

# repo_slug <GitHub URL in any form> -> owner/name
repo_slug() { sed -E 's#^(ssh://)?git@github\.com[:/]##; s#^https://github\.com/##; s#\.git$##' <<< "$1"; }

# repo_name <url> -> name
repo_name() { basename "$(repo_slug "$1")"; }

# repo_key <url> -> path of the deploy key for that repository
repo_key() { local slug; slug="$(repo_slug "$1")"; echo "$HOME/.ssh/id_github_${slug//\//_}"; }

# git_ssh <url> -> an ssh command that uses only that repository's key
git_ssh() { echo "ssh -i $(repo_key "$1") -o IdentitiesOnly=yes"; }

# target_dir: where the session should start (may not exist yet)
target_dir() {
    local dir first
    dir="$(opt working_directory)"
    if [ -z "$dir" ]; then
        first="$(opt repositories | head -n1)"
        [ -n "$first" ] && dir="$WORK/$(repo_name "$first")"
    fi
    echo "${dir:-$WORK}"
}

log() { echo "[claude-addon] $*"; }
