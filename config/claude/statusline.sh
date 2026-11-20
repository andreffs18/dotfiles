#!/bin/sh
# Claude Code status line: git branch | model | context % used | session cost
input=$(cat)

if command -v jq >/dev/null 2>&1; then
  dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
  model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
  used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
  cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')
else
  # Fallback without jq: crude sed extraction
  dir=$(printf '%s' "$input" | sed -n 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
  model=$(printf '%s' "$input" | sed -n 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
  used=$(printf '%s' "$input" | sed -n 's/.*"used_percentage"[[:space:]]*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -n1)
  cost=$(printf '%s' "$input" | sed -n 's/.*"total_cost_usd"[[:space:]]*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -n1)
fi

[ -z "$dir" ] && dir=$(pwd)
out=""

branch=$(git --no-optional-locks -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null \
  || git --no-optional-locks -C "$dir" rev-parse --short HEAD 2>/dev/null)
add() { if [ -z "$out" ]; then out="$1"; else out="$out | $1"; fi; }
[ -n "$branch" ] && add "$branch"
[ -n "$model" ] && add "$model"
[ -n "$used" ] && add "ctx $(printf '%.0f' "$used")%"
[ -n "$cost" ] && add "$(printf '$%.2f' "$cost")"

printf '%s\n' "$out"
