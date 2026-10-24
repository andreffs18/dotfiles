#!/usr/bin/env bash

# Symlink own Claude Code skills and settings from the dotfiles into ~/.claude,
# then install third-party skills listed in skills.txt
# Existing real files/dirs are moved to <name>.bak so nothing is lost.
CLAUDE_SRC=$DIRECTORY/config/claude
mkdir -p ~/.claude/skills

link() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak"
  fi
  ln -sfn "$src" "$dest"
}

for skill in "$CLAUDE_SRC"/skills/*/; do
  link "${skill%/}" ~/.claude/skills/"$(basename "$skill")"
done

link "$CLAUDE_SRC/settings.json" ~/.claude/settings.json

# Third-party skills: installed from upstream so they can be updated, not copied into the repo
if command -v npx >/dev/null 2>&1; then
  while read -r source skill; do
    [[ -z "$source" || "$source" == \#* ]] && continue
    npx --yes skills add "$source" -s "$skill" -g -a claude-code -y </dev/null
  done < "$CLAUDE_SRC/skills.txt"
else
  log.fail "npx not found, skipping third-party skills (install node and re-run)"
fi

log.success "Claude Code skills and settings linked!"
