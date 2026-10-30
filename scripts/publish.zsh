#!/usr/bin/env zsh
set -euo pipefail

source "${0:A:h}/../dotfiles/zsh/gitfresh.zsh"

publish_remote="https://github.com/arifd/mac-config.git"

# Confirm before replacing local history and force-pushing to GitHub.
print -P "%F{yellow}Warning:%f This will delete the current Git history and force-push a new initial commit to GitHub, replacing the remote main branch."
read -q "?Continue? [y/N] " || { echo; exit 1; }
echo

# 0. Wipe history, and init new:
gitfresh --yes

# 1. Add the GitHub repository as your remote origin:
git remote add origin "$publish_remote"

# 2. Rename your local branch to main (if it isn't already):
git branch -M main

# 3. Push your initial commit and set upstream tracking (-u):
git push --force -u origin main
