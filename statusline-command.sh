#!/usr/bin/env bash
# Claude Code status line script
# Receives JSON on stdin and prints a formatted status line
# Zero external dependencies — no jq, no bc

input=$(cat)

# --- JSON helpers (no jq) ---
# Extract a simple string/number value by key path
json_val() {
  echo "$input" | sed 's|\\\\|/|g' | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//'
}
json_num() {
  echo "$input" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*[0-9.]*" | head -1 | sed 's/.*:[[:space:]]*//'
}

# Extract field from a specific JSON block (to handle duplicate keys)
json_block_num() {
  local block="$1" field="$2"
  echo "$input" | grep -o "\"$block\"[^}]*}" | head -1 | grep -o "\"$field\"[[:space:]]*:[[:space:]]*[0-9.]*" | head -1 | sed 's/.*:[[:space:]]*//'
}

# --- Model ---
model=$(json_val "display_name")
[ -z "$model" ] && model="Unknown Model"

# --- Project path (last 2 components) ---
project_dir=$(json_val "project_dir")
[ -z "$project_dir" ] && project_dir=$(json_val "cwd")
short_path=$(echo "$project_dir" | sed 's|\\\\|/|g; s|\\|/|g' | awk -F'/' '{
  n=NF
  if (n >= 2) print $(n-1)"/"$n
  else print $n
}')

# --- Git branch ---
branch=""
if [ -n "$project_dir" ]; then
  norm_dir=$(echo "$project_dir" | sed 's|\\\\|/|g; s|\\|/|g')
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$norm_dir" symbolic-ref --short HEAD 2>/dev/null)
fi

# --- Context window usage bar (10 blocks, dynamic color) ---
ctx_block=$(echo "$input" | sed -n 's/.*"context_window"[[:space:]]*:[[:space:]]*{//p' | grep -o '"used_percentage"[[:space:]]*:[[:space:]]*[0-9.]*' | head -1 | sed 's/.*:[[:space:]]*//')
if [ -n "$ctx_block" ]; then
  pct_int=$(printf "%.0f" "$ctx_block" 2>/dev/null || echo 0)
  filled=$(( pct_int * 10 / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  empty_b=$(( 10 - filled ))
  bar=""
  i=0; while [ $i -lt "$filled" ]; do bar="${bar}█"; i=$((i+1)); done
  i=0; while [ $i -lt "$empty_b" ]; do bar="${bar}░"; i=$((i+1)); done
  # Dynamic color: green ≤60, yellow ≤80, red >80
  if [ "$pct_int" -gt 80 ]; then
    ctx_color="31"  # red
  elif [ "$pct_int" -gt 60 ]; then
    ctx_color="33"  # yellow
  else
    ctx_color="32"  # green
  fi
  ctx_display=$(printf "\033[${ctx_color}m%s %d%%\033[0m" "$bar" "$pct_int")
else
  ctx_color="32"
  ctx_display="░░░░░░░░░░ --"
fi

# --- Time remaining helper ---
time_remaining() {
  local resets_at=$1
  local now=$(date +%s)
  local diff=$(( resets_at - now ))
  [ "$diff" -le 0 ] && echo "agora" && return
  local days=$(( diff / 86400 ))
  local hours=$(( (diff % 86400) / 3600 ))
  local mins=$(( (diff % 3600) / 60 ))
  local result=""
  [ "$days" -gt 0 ] && result="${days}d"
  [ "$hours" -gt 0 ] && result="${result}${hours}h"
  [ "$mins" -gt 0 ] && [ "$days" -eq 0 ] && result="${result}${mins}m"
  echo "${result:-agora}"
}

# --- Rate limit bar builder ---
rate_bar() {
  local pct_int=$1
  local filled=$(( pct_int * 10 / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  local empty_b=$(( 10 - filled ))
  local bar="" i=0
  while [ $i -lt "$filled" ]; do bar="${bar}█"; i=$((i+1)); done
  i=0
  while [ $i -lt "$empty_b" ]; do bar="${bar}░"; i=$((i+1)); done
  local color dot
  if [ "$pct_int" -gt 80 ]; then color="31"
  elif [ "$pct_int" -gt 60 ]; then color="33"
  else color="32"
  fi
  printf "\033[${color}m${bar} ${pct_int}%%\033[0m"
}

# --- Rate limits ---
five_pct=$(json_block_num "five_hour" "used_percentage")
five_resets=$(json_block_num "five_hour" "resets_at")
week_pct=$(json_block_num "seven_day" "used_percentage")
week_resets=$(json_block_num "seven_day" "resets_at")

# --- Assemble segments ---
parts=""

# Session (5h) rate limit
if [ -n "$five_pct" ]; then
  five_int=$(printf "%.0f" "$five_pct" 2>/dev/null || echo 0)
  five_time=""
  [ -n "$five_resets" ] && five_time=" - $(time_remaining "$five_resets")"
  five_color=32; [ "$five_int" -gt 60 ] && five_color=33; [ "$five_int" -gt 80 ] && five_color=31
  parts="${parts}⏱️ $(rate_bar "$five_int")\033[${five_color}m${five_time}\033[0m"
fi

# Weekly (7d) rate limit
if [ -n "$week_pct" ]; then
  week_int=$(printf "%.0f" "$week_pct" 2>/dev/null || echo 0)
  week_time=""
  [ -n "$week_resets" ] && week_time=" - $(time_remaining "$week_resets")"
  week_color=32; [ "$week_int" -gt 60 ] && week_color=33; [ "$week_int" -gt 80 ] && week_color=31
  [ -n "$parts" ] && parts="${parts} \033[90m|\033[0m "
  parts="${parts}📅 $(rate_bar "$week_int")\033[${week_color}m${week_time}\033[0m"
fi

# Context bar (next to weekly)
[ -n "$parts" ] && parts="${parts} \033[90m|\033[0m "
parts="${parts}🧠 ${ctx_display}"

# Separator before model
parts="${parts} \033[90m|\033[0m "

# Model
parts="${parts}\033[1;36m🐙 ${model}\033[0m"

# Path
if [ -n "$short_path" ]; then
  parts="${parts} \033[90m|\033[0m \033[33m📁 ${short_path}\033[0m"
fi

# Git branch
if [ -n "$branch" ]; then
  parts="${parts} \033[90m|\033[0m \033[35m🌿 ${branch}\033[0m"
fi

printf "%b\n" "$parts"
