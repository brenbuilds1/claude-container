# Claude Code Development Container
# Version: 2.0.64
# 
# A secure development container for Claude Code with:
# - Non-root user execution (no root access to host)
# - Browser OAuth authentication support
# - awesome-claude-skills pre-installed
#
# Security: Container runs as unprivileged 'node' user (UID 1000)
# The container CANNOT gain root access to the host system.

FROM node:20-bookworm

# Build arguments
ARG TZ=UTC
ARG CLAUDE_CODE_VERSION=2.0.64

# Set timezone
ENV TZ="$TZ"

# Install essential development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    less \
    git \
    procps \
    sudo \
    fzf \
    zsh \
    man-db \
    unzip \
    gnupg2 \
    gh \
    jq \
    nano \
    vim \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ensure node user has access to npm global directory
RUN mkdir -p /usr/local/share/npm-global && \
    chown -R node:node /usr/local/share/npm-global

# Set up command history persistence
ARG USERNAME=node
RUN mkdir -p /commandhistory && \
    touch /commandhistory/.bash_history && \
    chown -R $USERNAME /commandhistory

# Create workspace and config directories with proper permissions
RUN mkdir -p /workspace \
    /home/node/.claude \
    /home/node/.claude/agents \
    /home/node/.claude/skills \
    /home/node/awesome-claude-skills && \
    chown -R node:node /workspace /home/node/.claude /home/node/awesome-claude-skills

WORKDIR /workspace

# Set environment variables
ENV DEVCONTAINER=true
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin
ENV SHELL=/bin/zsh
ENV EDITOR=nano
ENV VISUAL=nano
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV CLAUDE_CONFIG_DIR=/home/node/.claude

# Copy skills installation script
COPY install-skills.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/install-skills.sh

# ============================================================
# SECURITY: Switch to non-root user
# The container runs as 'node' (UID 1000) - NOT root
# This prevents any possibility of root access to the host
# ============================================================
USER node

# Clone awesome-claude-skills repository
RUN git clone --depth 1 https://github.com/ComposioHQ/awesome-claude-skills.git /home/node/awesome-claude-skills

# Install Claude Code globally (specific version)
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Set up skills
RUN /usr/local/bin/install-skills.sh

# Verify installation
RUN claude --version

# Default command
CMD ["zsh"]
