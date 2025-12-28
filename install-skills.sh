#!/bin/bash
# Claude Code Skills Installation Script
# Integrates awesome-claude-skills into Claude Code configuration
#
# This script sets up the skills from:
# https://github.com/ComposioHQ/awesome-claude-skills
#
# Skills are made available to Claude Code through:
# 1. ~/.claude/CLAUDE.md - User-level instructions with skill references
# 2. ~/.claude/skills/ - Symlinks to skill directories
# 3. ~/.claude/agents/ - Subagent configurations

set -e

SKILLS_REPO="/home/node/awesome-claude-skills"
CLAUDE_DIR="/home/node/.claude"
SKILLS_DIR="${CLAUDE_DIR}/skills"
AGENTS_DIR="${CLAUDE_DIR}/agents"

echo "================================================"
echo "Claude Code Skills Installation"
echo "================================================"
echo ""

# Ensure directories exist
mkdir -p "${SKILLS_DIR}" "${AGENTS_DIR}"

# Create symlinks for each skill category
echo "[+] Setting up skill symlinks..."

# List of skill directories from awesome-claude-skills
SKILL_DIRS=(
    "artifacts-builder"
    "brand-guidelines"
    "canvas-design"
    "changelog-generator"
    "competitive-ads-extractor"
    "content-research-writer"
    "developer-growth-analysis"
    "document-skills"
    "domain-name-brainstormer"
    "file-organizer"
    "image-enhancer"
    "internal-comms"
    "invoice-organizer"
    "lead-research-assistant"
    "meeting-insights-analyzer"
    "raffle-winner"
    "research-assistant"
    "slack-gif-creator"
    "spreadsheet-analyzer"
    "theme-factory"
    "video-downloader"
    "youtube-transcript"
)

# Create symlinks for available skills
for skill in "${SKILL_DIRS[@]}"; do
    if [ -d "${SKILLS_REPO}/${skill}" ]; then
        ln -sf "${SKILLS_REPO}/${skill}" "${SKILLS_DIR}/${skill}"
        echo "    Linked: ${skill}"
    fi
done

# Also link any other directories that might be skills
for dir in "${SKILLS_REPO}"/*/; do
    skill_name=$(basename "$dir")
    # Skip hidden directories and common non-skill dirs
    if [[ ! "$skill_name" =~ ^[._] ]] && \
       [[ "$skill_name" != "node_modules" ]] && \
       [[ "$skill_name" != ".git" ]] && \
       [[ ! -L "${SKILLS_DIR}/${skill_name}" ]]; then
        if [ -f "${dir}/SKILL.md" ] || [ -f "${dir}/README.md" ]; then
            ln -sf "$dir" "${SKILLS_DIR}/${skill_name}"
            echo "    Linked: ${skill_name}"
        fi
    fi
done

# Create ~/.claude/CLAUDE.md with skill references
echo ""
echo "[+] Creating user-level CLAUDE.md..."

cat > "${CLAUDE_DIR}/CLAUDE.md" << 'CLAUDEMD'
# Claude Code User Configuration

## Available Skills

This environment includes the [awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) collection.
Skills are installed at `~/.claude/skills/` and can be referenced when needed.

### Development & Code Skills
- **artifacts-builder** - Create complex Claude AI artifacts using modern frontend web technologies
- **changelog-generator** - Automatically generate changelogs from git commits
- **developer-growth-analysis** - Analyze developer growth metrics and patterns

### Business & Marketing Skills
- **brand-guidelines** - Apply brand colors and typography for consistent visual identity
- **competitive-ads-extractor** - Extract and analyze competitor ads from ad libraries
- **domain-name-brainstormer** - Generate creative domain name ideas and check availability
- **internal-comms** - Write internal communications in company-specific formats
- **lead-research-assistant** - Identify and qualify high-quality leads

### Communication & Writing Skills
- **content-research-writer** - Write high-quality content with research and citations
- **meeting-insights-analyzer** - Analyze meeting transcripts for behavioral patterns

### Creative & Media Skills
- **canvas-design** - Create visual art in PNG and PDF documents
- **image-enhancer** - Improve image quality for professional presentations
- **slack-gif-creator** - Create animated GIFs optimized for Slack
- **theme-factory** - Apply professional font and color themes to artifacts
- **video-downloader** - Download videos from various platforms
- **youtube-transcript** - Fetch transcripts from YouTube videos

### Productivity & Organization Skills
- **file-organizer** - Intelligently organize files and folders
- **invoice-organizer** - Organize invoices for tax preparation
- **raffle-winner** - Randomly select winners with secure randomness
- **spreadsheet-analyzer** - Analyze CSV files and generate insights

### Research Skills
- **research-assistant** - Conduct research and compile findings
- **document-skills** - Process and analyze documents

## Using Skills

To use a skill, reference its purpose in your request. For example:
- "Help me organize my invoice files" → triggers invoice-organizer skill
- "Create a changelog from recent commits" → triggers changelog-generator skill
- "Analyze this meeting transcript" → triggers meeting-insights-analyzer skill

Skills are located at: `/home/node/.claude/skills/`
Skill repository: `/home/node/awesome-claude-skills/`

## Container Environment

This is a secure development container with:
- Claude Code v2.0.64
- Non-root user execution
- Persistent configuration volumes

Your workspace is mounted at `/workspace`.
CLAUDEMD

echo "    Created: ${CLAUDE_DIR}/CLAUDE.md"

# Create initial settings.json if it doesn't exist
if [ ! -f "${CLAUDE_DIR}/settings.json" ]; then
    echo ""
    echo "[+] Creating initial settings.json..."
    cat > "${CLAUDE_DIR}/settings.json" << 'SETTINGSJSON'
{
  "permissions": {
    "allow": [
      "Read(~/.claude/skills/**)",
      "Read(~/awesome-claude-skills/**)"
    ]
  },
  "env": {
    "SKILLS_DIR": "/home/node/.claude/skills",
    "AWESOME_SKILLS_REPO": "/home/node/awesome-claude-skills"
  }
}
SETTINGSJSON
    echo "    Created: ${CLAUDE_DIR}/settings.json"
fi

# Count installed skills
SKILL_COUNT=$(find "${SKILLS_DIR}" -maxdepth 1 -type l | wc -l)

echo ""
echo "================================================"
echo "Skills Installation Complete!"
echo "================================================"
echo ""
echo "Installed skills: ${SKILL_COUNT}"
echo "Skills directory: ${SKILLS_DIR}"
echo "Skills source:    ${SKILLS_REPO}"
echo ""
echo "To browse available skills:"
echo "  ls ~/.claude/skills/"
echo ""
echo "To read a skill's documentation:"
echo "  cat ~/.claude/skills/<skill-name>/SKILL.md"
echo "  # or"
echo "  cat ~/.claude/skills/<skill-name>/README.md"
echo ""

