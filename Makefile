# Claude Code Development Container
# A secure container for running Claude Code without host root access
#
# Usage:
#   make build         - Build the Docker image
#   make run           - Run Claude Code (authenticate via browser)
#   make shell         - Start a shell in the container
#   make skills        - List available skills
#   make update-skills - Update skills from GitHub
#   make clean         - Remove the Docker image

# Configuration
IMAGE_NAME := claude-code-dev
CONTAINER_NAME := claude-code
CLAUDE_VERSION := 2.0.64
WORKSPACE := $(PWD)

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
CYAN := \033[0;36m
NC := \033[0m

.PHONY: all build run shell skills update-skills clean purge version help

# Default target
all: help

# Check Docker
check-docker:
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)Error: Docker is not installed$(NC)"; exit 1; }

# Build the Docker image
build: check-docker
	@echo "$(BLUE)Building Claude Code container (v$(CLAUDE_VERSION))...$(NC)"
	docker build \
		--build-arg CLAUDE_CODE_VERSION=$(CLAUDE_VERSION) \
		--build-arg TZ=$$(cat /etc/timezone 2>/dev/null || echo "UTC") \
		-t $(IMAGE_NAME):$(CLAUDE_VERSION) \
		-t $(IMAGE_NAME):latest \
		.
	@echo "$(GREEN)Build complete!$(NC)"

# Run Claude Code interactively
run: check-docker
	@echo "$(BLUE)Starting Claude Code...$(NC)"
	@echo "$(GREEN)On first run, click the authentication URL to log in$(NC)"
	docker run --rm -it \
		--name $(CONTAINER_NAME) \
		--hostname claude-dev \
		--security-opt=no-new-privileges \
		-v $(WORKSPACE):/workspace:delegated \
		-v claude-code-config:/home/node/.claude \
		-v claude-code-history:/commandhistory \
		-e TERM=xterm-256color \
		$(IMAGE_NAME):latest \
		claude

# Run with API key
run-api: check-docker
	@if [ -z "$$ANTHROPIC_API_KEY" ]; then \
		echo "$(RED)Error: ANTHROPIC_API_KEY not set$(NC)"; \
		echo "Usage: ANTHROPIC_API_KEY=sk-xxx make run-api"; \
		exit 1; \
	fi
	docker run --rm -it \
		--name $(CONTAINER_NAME) \
		--hostname claude-dev \
		--security-opt=no-new-privileges \
		-v $(WORKSPACE):/workspace:delegated \
		-v claude-code-config:/home/node/.claude \
		-v claude-code-history:/commandhistory \
		-e TERM=xterm-256color \
		-e ANTHROPIC_API_KEY \
		$(IMAGE_NAME):latest \
		claude

# Start a shell
shell: check-docker
	@echo "$(BLUE)Starting shell...$(NC)"
	docker run --rm -it \
		--name $(CONTAINER_NAME)-shell \
		--hostname claude-dev \
		--security-opt=no-new-privileges \
		-v $(WORKSPACE):/workspace:delegated \
		-v claude-code-config:/home/node/.claude \
		-v claude-code-history:/commandhistory \
		-e TERM=xterm-256color \
		$(IMAGE_NAME):latest \
		zsh

# List available skills
skills: check-docker
	@echo "$(CYAN)Available Claude Code Skills$(NC)"
	@echo "$(CYAN)=============================$(NC)"
	@docker run --rm $(IMAGE_NAME):latest bash -c 'ls -1 /home/node/.claude/skills/ 2>/dev/null | head -30'
	@echo ""
	@echo "Skills from: github.com/ComposioHQ/awesome-claude-skills"

# Update skills from GitHub (pulls latest)
update-skills: check-docker
	@echo "$(BLUE)Updating skills from GitHub...$(NC)"
	docker run --rm -it \
		-v claude-code-config:/home/node/.claude \
		$(IMAGE_NAME):latest \
		bash -c 'cd /home/node/awesome-claude-skills && git pull && /usr/local/bin/install-skills.sh'
	@echo "$(GREEN)Skills updated!$(NC)"

# Show version
version: check-docker
	@docker run --rm $(IMAGE_NAME):latest claude --version

# Clean up
clean: check-docker
	@echo "$(BLUE)Removing Docker image...$(NC)"
	-docker rmi $(IMAGE_NAME):$(CLAUDE_VERSION) $(IMAGE_NAME):latest 2>/dev/null || true
	@echo "$(GREEN)Done$(NC)"

# Remove everything including volumes
purge: stop clean
	@echo "$(RED)Removing all data volumes...$(NC)"
	docker volume rm claude-code-config claude-code-history 2>/dev/null || echo "$(YELLOW)Volumes already removed or in use$(NC)"
	@echo "$(GREEN)Done$(NC)"
	@echo "$(YELLOW)Note: Run 'make run' to re-authenticate$(NC)"

# Stop running container
stop:
	@echo "$(BLUE)Stopping containers...$(NC)"
	-docker stop $(CONTAINER_NAME) $(CONTAINER_NAME)-shell 2>/dev/null || true
	-docker rm $(CONTAINER_NAME) $(CONTAINER_NAME)-shell 2>/dev/null || true

# Help
help:
	@echo ""
	@echo "$(BLUE)╔══════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║   Claude Code Development Container (v$(CLAUDE_VERSION))    ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Commands:$(NC)"
	@echo "  $(YELLOW)make build$(NC)      Build the Docker image"
	@echo "  $(YELLOW)make run$(NC)        Run Claude Code (browser auth)"
	@echo "  $(YELLOW)make run-api$(NC)    Run with API key"
	@echo "  $(YELLOW)make shell$(NC)      Start a shell"
	@echo "  $(YELLOW)make skills$(NC)     List available skills"
	@echo "  $(YELLOW)make update-skills$(NC) Update skills from GitHub"
	@echo "  $(YELLOW)make version$(NC)    Show Claude Code version"
	@echo "  $(YELLOW)make clean$(NC)      Remove Docker image"
	@echo "  $(YELLOW)make purge$(NC)      Remove image + all data"
	@echo ""
	@echo "$(GREEN)Quick start:$(NC)"
	@echo "  make build"
	@echo "  make run"
	@echo "  # Click the auth URL to log in with your Claude.ai account"
	@echo ""
	@echo "$(GREEN)With API key:$(NC)"
	@echo "  ANTHROPIC_API_KEY=sk-xxx make run-api"
	@echo ""
	@echo "$(GREEN)Security:$(NC)"
	@echo "  • Runs as non-root user (node)"
	@echo "  • Cannot gain root access to host"
	@echo "  • Workspace mounted at: $(WORKSPACE)"
	@echo ""
