#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "$PROJECT_DIR/.." && pwd)"
SRC="$REPO_DIR/data/jenkins_home"
DEST="$PROJECT_DIR/backups"
KEEP_DAYS=7
STAMP=$(date +%F_%H-%M)

mkdir -p "$DEST"

tar --exclude='./workspace' --exclude='./caches' \
    --exclude='./war' --exclude='./logs' \
    -czf "$DEST/jenkins_home_$STAMP.tar.gz" -C "$SRC" .

find "$DEST" -name 'jenkins_home_*.tar.gz' -mtime +"$KEEP_DAYS" -delete

echo "$(date '+%F %T') backup OK: jenkins_home_$STAMP.tar.gz"
