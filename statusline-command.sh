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
case "$(echo "$model" | tr 'A-Z' 'a-z')" in
  *opus*)   model_emoji="🐙" ;;
  *sonnet*) model_emoji="🎵" ;;
  *haiku*)  model_emoji="🌸" ;;
  *)        model_emoji="🤖" ;;
esac

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

# --- Percentage color: green -> yellow -> orange -> red ---
pct_color() {
  local p=$1 c
  if   [ "$p" -gt 90 ]; then c="1;31"      # ESTOURANDO
  elif [ "$p" -gt 75 ]; then c="38;5;208"  # laranja
  elif [ "$p" -gt 50 ]; then c="33"        # amarelo
  else                       c="32"        # verde
  fi
  printf "\033[${c}m%d%%\033[0m" "$p"
}

# --- Context window usage ---
ctx_block=$(echo "$input" | sed -n 's/.*"context_window"[[:space:]]*:[[:space:]]*{//p' | grep -o '"used_percentage"[[:space:]]*:[[:space:]]*[0-9.]*' | head -1 | sed 's/.*:[[:space:]]*//')
if [ -n "$ctx_block" ]; then
  pct_int=$(printf "%.0f" "$ctx_block" 2>/dev/null || echo 0)
  ctx_display=$(pct_color "$pct_int")
else
  ctx_display="--"
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

# --- Burn rate: fire = gastando mais rapido que o relogio, gelo = folgado ---
pace_flag() {
  local pct=$1 resets=$2 window=$3
  [ -z "$resets" ] && return
  local remaining=$(( resets - $(date +%s) ))
  if [ "$remaining" -le 0 ] || [ "$remaining" -gt "$window" ]; then return; fi
  local elapsed_pct=$(( (window - remaining) * 100 / window ))
  if [ "$pct" -gt "$elapsed_pct" ]; then printf " 🔥"; else printf " 🧊"; fi
}

# --- Rate limits ---
five_pct=$(json_block_num "five_hour" "used_percentage")
five_resets=$(json_block_num "five_hour" "resets_at")
week_pct=$(json_block_num "seven_day" "used_percentage")
week_resets=$(json_block_num "seven_day" "resets_at")

# --- Assemble segments ---
sep="\033[90m │ \033[0m"

# --- Linha 1: limites + contexto + modelo ---
l1=""
if [ -n "$five_pct" ]; then
  five_int=$(printf "%.0f" "$five_pct" 2>/dev/null || echo 0)
  five_time=""
  [ -n "$five_resets" ] && five_time=" - $(time_remaining "$five_resets")"
  l1="⏳ $(pct_color "$five_int")$(pace_flag "$five_int" "$five_resets" 18000)\033[90m${five_time}\033[0m"
fi
if [ -n "$week_pct" ]; then
  week_int=$(printf "%.0f" "$week_pct" 2>/dev/null || echo 0)
  week_time=""
  [ -n "$week_resets" ] && week_time=" - $(time_remaining "$week_resets")"
  [ -n "$l1" ] && l1="${l1}${sep}"
  l1="${l1}📅 $(pct_color "$week_int")$(pace_flag "$week_int" "$week_resets" 604800)\033[90m${week_time}\033[0m"
fi
[ -n "$l1" ] && l1="${l1}${sep}"
l1="${l1}🧠 ${ctx_display}${sep}\033[1;36m${model_emoji} ${model}\033[0m"

# --- Linha 2: diff da sessao + branch ---
lines_add=$(json_block_num "cost" "total_lines_added")
lines_del=$(json_block_num "cost" "total_lines_removed")
: "${lines_add:=0}" "${lines_del:=0}"
l2=""
if [ "$lines_add" -gt 0 ] || [ "$lines_del" -gt 0 ]; then
  l2="📝 \033[32m+${lines_add}\033[0m\033[90m/\033[0m\033[31m-${lines_del}\033[0m"
fi
if [ -n "$branch" ]; then
  [ -n "$l2" ] && l2="${l2}${sep}"
  l2="${l2}\033[35m🌿 ${branch}\033[0m"
fi

# --- Linha 3: pasta ---
l3="\033[33m📁 ${short_path}\033[0m"

# --- Saida em arvore ---
out="$l1"
[ -n "$l2" ] && out="${out}
\033[90m├─\033[0m ${l2}"
out="${out}
\033[90m└─\033[0m ${l3}"
# espaco antes da linha de modo do Claude Code (trailing vazio e aparado)
printf "%b
⠀
" "$out"
