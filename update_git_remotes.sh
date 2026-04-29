#!/usr/bin/env bash
set -euo pipefail

# Ensure we are in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: This is not a git repository." >&2
  exit 1
fi

# Get all remote names
remotes=$(git remote)

if [ -z "$remotes" ]; then
  echo "No remotes found."
  exit 0
fi

for remote in $remotes; do
  # Get current URL for this remote
  url=$(git remote get-url "$remote")

  # Replace 'SiemaApplications' (case-insensitive) with 'vossloh-digital'
  new_url=$(printf '%s' "$url" | sed 's/SiemaApplications/vossloh-digital/Ig')

  # If URL changed, update the remote
  if [ "$url" != "$new_url" ]; then
    echo "Updating remote '$remote':"
    echo "  $url"
    echo "  -> $new_url"
    git remote set-url "$remote" "$new_url"
  else
    echo "Remote '$remote' unchanged."
  fi
done
