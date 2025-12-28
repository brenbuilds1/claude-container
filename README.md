# Claude Code Development Container

A secure Docker container for running [Claude Code](https://www.npmjs.com/package/@anthropic-ai/claude-code) (Anthropic's agentic coding tool) in isolation, with [awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) pre-installed.

## Features

- **Claude Code v2.0.64** - Specific version pinned for stability
- **Browser OAuth** - Click the URL to log in with your Claude.ai account
- **Non-root execution** - Runs as unprivileged `node` user (UID 1000)
- **Host isolation** - Container cannot gain root access to your host system
- **awesome-claude-skills** - 24+ pre-installed skills from [ComposioHQ](https://github.com/ComposioHQ/awesome-claude-skills)
- **Persistent config** - Authentication and settings survive container restarts
- **Dev tools included** - git, gh CLI, fzf, zsh, Python 3, and more

## Prerequisites

- Docker 20.10+
- Make
- A Claude.ai account (or Anthropic API key)

## Quick Start

```bash
# 1. Build the container
make build

# 2. Run Claude Code
make run

# 3. Click the authentication URL that appears
# 4. Log in with your Claude.ai account
# 5. Start coding!
```

### With API Key

```bash
ANTHROPIC_API_KEY=sk-ant-xxx make run-api
```

## Commands

| Command | Description |
|---------|-------------|
| `make build` | Build the Docker image |
| `make run` | Run Claude Code (browser authentication) |
| `make run-api` | Run with `ANTHROPIC_API_KEY` environment variable |
| `make shell` | Start a zsh shell in the container |
| `make skills` | List available Claude Code skills |
| `make update-skills` | Update skills from GitHub |
| `make version` | Show installed Claude Code version |
| `make clean` | Remove the Docker image |
| `make purge` | Remove image and all data volumes |
| `make help` | Show help message |

## Security Model

This container provides isolation through Docker's security features:

| Protection | How |
|------------|-----|
| **No root on host** | Runs as `node` user (UID 1000), not root |
| **Privilege escalation blocked** | `--security-opt=no-new-privileges` flag |
| **Filesystem isolation** | Only mounted workspace is accessible |
| **Persistent auth** | Credentials stored in Docker volume, not on host |

### What the container CAN access:
- Your mounted workspace directory (current directory when you run `make`)
- The internet (for Claude API, GitHub, npm, etc.)

### What the container CANNOT do:
- Gain root access to your host system
- Access files outside the mounted workspace
- Escalate privileges

## Included Skills

This container includes 24+ skills from [awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills):

**Development:** artifacts-builder, changelog-generator, developer-growth-analysis

**Business:** brand-guidelines, competitive-ads-extractor, domain-name-brainstormer, internal-comms, lead-research-assistant

**Writing:** content-research-writer, meeting-insights-analyzer

**Creative:** canvas-design, image-enhancer, slack-gif-creator, theme-factory, video-downloader, youtube-transcript

**Productivity:** file-organizer, invoice-organizer, raffle-winner-picker, spreadsheet-analyzer

To use a skill, just describe what you want:
```
"Help me organize my invoice files"
"Create a changelog from recent commits"
"Analyze this meeting transcript"
```

## Workspace

The **current directory** (where you run `make`) is mounted at `/workspace` inside the container.

```bash
# Run from your project directory
cd /path/to/your/project
make -f /path/to/claude-container/Makefile run

# Or copy Makefile to your project
cp /path/to/claude-container/Makefile .
make run
```

## Data Persistence

These Docker volumes persist across container restarts:

| Volume | Contents |
|--------|----------|
| `claude-code-config` | Authentication, settings, Claude config |
| `claude-code-history` | Command history |

To completely reset:
```bash
make purge
```

## Customization

### Different Claude Code Version

```bash
# In Makefile, change:
CLAUDE_VERSION := 2.0.64

# Or build directly:
docker build --build-arg CLAUDE_CODE_VERSION=2.0.70 -t claude-code-dev .
```

### Timezone

```bash
docker build --build-arg TZ=America/New_York -t claude-code-dev .
```

## Troubleshooting

### Authentication fails
- Make sure you're clicking the full URL (including any tokens)
- Try `make purge` to reset cached credentials

### Permission denied
- The container runs as non-root, which is intentional
- Check that your workspace directory is writable

### Skills not showing
```bash
make shell
ls ~/.claude/skills/
```

## References

- [Claude Code npm package](https://www.npmjs.com/package/@anthropic-ai/claude-code) (v2.0.64)
- [Claude Code Documentation](https://code.claude.com/docs/en/overview)
- [awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills)
- [Anthropic](https://www.anthropic.com)

## License

MIT License - see [LICENSE](LICENSE) file.

Claude Code itself is subject to [Anthropic's terms of service](https://www.anthropic.com/legal/commercial-terms).
