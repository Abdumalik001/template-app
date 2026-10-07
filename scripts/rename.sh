#!/usr/bin/env bash
set -e

# Rename Flutter Project wrapper script (Bash / Shell)
# Usage:
#   ./scripts/rename.sh
#   ./scripts/rename.sh new_name com.company.app "My App"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(dirname "$DIR")"

NEW_NAME="$1"
NEW_ORG="$2"
NEW_TITLE="$3"

if [ -z "$NEW_NAME" ]; then
  python3 "$DIR/rename_project.py"
else
  python3 "$DIR/rename_project.py" --name "$NEW_NAME" --org "$NEW_ORG" --title "$NEW_TITLE"
fi
