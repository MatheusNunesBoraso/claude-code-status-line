#!/usr/bin/env bash
# Claude Code status line script
# Receives JSON on stdin and prints a formatted status line

input=$(cat)

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')

# --- Project path (last 2 path components for brevity) ---
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .cwd // ""')
short_path=$(echo "$project_dir" | sed 's|\\\\|/|g; s|\\|/|g' | awk -F'/' '{
  n=NF
  if (n >= 2) print $(n-1)"/"$n
  else print $n
}')

# --- Git branch (--no-optional-locks avoids blocking on lock files) ---
branch=""
if [ -n "$project_dir" ]; then
  branch=$(git -C "$project_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
fi

# --- Context window usage bar (10 blocks) ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  filled=$(printf "%.0f" "$(echo "$used_pct * 10 / 100" | bc -l 2>/dev/null || echo 0)")
  [ "$filled" -gt 10 ] && filled=10
  empty_blocks=$((10 - filled))
  bar=""
  for i in $(seq 1 "$filled" 2>/dev/null); do bar="${bar}#"; done
  for i in $(seq 1 "$empty_blocks" 2>/dev/null); do bar="${bar}-"; done
  ctx_display=$(printf "ctx [%s] %.0f%%" "$bar" "$used_pct")
else
  ctx_display="ctx [----------] --"
fi

# --- Rate limits (Claude.ai subscription only, absent otherwise) ---
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rate_display=""
if [ -n "$five_pct" ]; then
  rate_display=$(printf "5h:%.0f%%" "$five_pct")
fi
if [ -n "$week_pct" ]; then
  week_str=$(printf "7d:%.0f%%" "$week_pct")
  rate_display="${rate_display:+$rate_display }$week_str"
fi

# --- Assemble the status line ---
# Model (cyan bold)
line=$(printf "\033[1;36m%s\033[0m" "$model")

# Project path (yellow)
if [ -n "$short_path" ]; then
  line=$(printf "%s  \033[33m%s\033[0m" "$line" "$short_path")
fi

# Git branch (magenta)
if [ -n "$branch" ]; then
  line=$(printf "%s \033[35m(%s)\033[0m" "$line" "$branch")
fi

# Context bar (green)
line=$(printf "%s  \033[32m%s\033[0m" "$line" "$ctx_display")

# Rate limits (red, only when present)
if [ -n "$rate_display" ]; then
  line=$(printf "%s  \033[31m%s\033[0m" "$line" "$rate_display")
fi

printf "%s\n" "$line"
