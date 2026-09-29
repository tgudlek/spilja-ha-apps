FROM ghcr.io/home-assistant/base:3.24-2026.08.0

ARG HA_CLI_VERSION=5.5.0
ARG HA_CLI_SHA256_aarch64=af390ab7f91a8135668ace7b1425d8e53800b6a1fc3b36fc588df701d2ab3db5
ARG HA_CLI_SHA256_amd64=fb2e2177bd7bc014f029b807cd1cc7d74484ecfed1e90d5f9b2a61d65ff5393d

# Claude Code's native build on musl needs libgcc, libstdc++ and the system
# ripgrep (USE_BUILTIN_RIPGREP=0). The rest is the toolbox the session uses.
RUN apk add --no-cache \
        bash coreutils diffutils file findutils flock grep less nano ncurses procps sed tar util-linux \
        git openssh-client rsync \
        tmux ttyd nginx \
        libgcc libstdc++ ripgrep \
        python3 py3-pip \
    && case "$(apk --print-arch)" in \
         aarch64) cli=aarch64; sum="$HA_CLI_SHA256_aarch64" ;; \
         x86_64) cli=amd64; sum="$HA_CLI_SHA256_amd64" ;; \
         *) echo "unsupported arch" >&2; exit 1 ;; \
       esac \
    && curl -fsSL -o /usr/bin/ha "https://github.com/home-assistant/cli/releases/download/${HA_CLI_VERSION}/ha_${cli}" \
    && echo "$sum  /usr/bin/ha" | sha256sum -c - \
    && chmod 755 /usr/bin/ha \
    # root's home is the persistent /data/home: ssh and git read the passwd
    # entry, not $HOME
    && sed -i -E 's#^root:([^:]*):0:0:([^:]*):[^:]*:[^:]*$#root:\1:0:0:\2:/data/home:/bin/bash#' /etc/passwd \
    && rm -f /etc/nginx/http.d/default.conf

ENV HOME=/data/home \
    PATH=/data/home/.local/bin:/data/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    USE_BUILTIN_RIPGREP=0 \
    TERM=xterm-256color \
    LANG=C.UTF-8 \
    PRE_COMMIT_HOME=/data/home/.cache/pre-commit \
    PIP_DISABLE_PIP_VERSION_CHECK=1

COPY rootfs /
