#!/bin/bash

# Comprehensive Claude Code Status Line
# Reads JSON input from stdin and displays comprehensive system information

# Read JSON input
input=$(cat)

# Extract values from JSON
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
model_id=$(echo "$input" | jq -r '.model.id // ""')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // ""')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')
version=$(echo "$input" | jq -r '.version // ""')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')

# Determine model icon based on model name/id
model_icon="🤖"  # Default AI icon
if echo "$model_name" | grep -qi "sonnet"; then
    model_icon="🎵"  # Music note for Sonnet
elif echo "$model_name" | grep -qi "haiku"; then
    model_icon="🌸"  # Cherry blossom for Haiku
elif echo "$model_name" | grep -qi "opus"; then
    model_icon="🎭"  # Theater masks for Opus
elif echo "$model_name" | grep -qi "claude"; then
    model_icon="🧠"  # Brain for Claude models
fi

# Get current timestamp
timestamp=$(date "+%H:%M:%S")
date_str=$(date "+%a %b %d")

# Get Git user info
git_username=$(git config user.name 2>/dev/null || echo "未配置Git用户")

# Get current working directory info and determine project icon
if [ -n "$current_dir" ]; then
    cwd="$current_dir"
    project_name=$(basename "$project_dir" 2>/dev/null || basename "$current_dir")
else
    cwd=$(pwd)
    project_name=$(basename "$cwd")
fi

# Determine project icon based on files present
project_icon="📁"  # Default folder icon
if [ -f "$cwd/package.json" ]; then
    project_icon="📦"  # Node.js project
elif [ -f "$cwd/Cargo.toml" ]; then
    project_icon="🦀"  # Rust project
elif [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/requirements.txt" ] || [ -f "$cwd/setup.py" ]; then
    project_icon="🐍"  # Python project
elif [ -f "$cwd/go.mod" ]; then
    project_icon="🐹"  # Go project
elif [ -f "$cwd/Dockerfile" ]; then
    project_icon="🐳"  # Docker project
elif [ -f "$cwd/.git/config" ] || git rev-parse --git-dir >/dev/null 2>&1; then
    project_icon="📂"  # Git repository
fi

# Get git information if in a git repo
git_info=""
git_icon=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    # Get current branch
    branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || "detached")

    # Get git status with appropriate icons
    if git diff-index --quiet HEAD -- 2>/dev/null; then
        if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
            status="✅"  # Clean - green checkmark
            git_icon="🌿"  # Branch icon for clean repo
        else
            status="❓"  # Untracked files - question mark
            git_icon="🌱"  # New growth for untracked
        fi
    else
        status="⚠️"   # Modified files - warning
        git_icon="🔧"  # Tools for modified repo
    fi

    git_info=" git:$branch$status"
fi

# Build the status line with colors, icons and comprehensive information
printf "\033[2m[\033[0m"
printf "👤 \033[36m%s\033[0m" "$git_username"
printf "\033[2m:\033[0m"
printf "%s \033[33m%s\033[0m" "$project_icon" "$project_name"
if [ -n "$git_info" ]; then
    printf " %s\033[2m%s\033[0m" "$git_icon" "$git_info"
fi
printf "\033[2m | \033[0m"
printf "%s \033[35m%s\033[0m" "$model_icon" "$model_name"
if [ "$output_style" != "default" ]; then
    printf " 🎨\033[2m(%s)\033[0m" "$output_style"
fi
printf "\033[2m | \033[0m"
printf "⏰ \033[32m%s\033[0m" "$timestamp"
printf "\033[2m | \033[0m"
printf "🔢 \033[34mv%s\033[0m" "$version"
printf "\033[2m]\033[0m"