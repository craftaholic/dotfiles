#!/bin/bash

CLAUDE_DIR=".claude"

case "$1" in
  new)
    SLUG=$(echo "$2" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
    SESSION_ID="$(date +%Y%m%d-%H%M%S)-${SLUG}"
    mkdir -p "${CLAUDE_DIR}/${SESSION_ID}/handoff"
    echo "${SESSION_ID}" > "${CLAUDE_DIR}/current-session"
    echo "Created session: ${SESSION_ID}"
    ;;
  current)
    cat "${CLAUDE_DIR}/current-session" 2>/dev/null || echo "No active session"
    ;;
  list)
    ls -d ${CLAUDE_DIR}/*/handoff 2>/dev/null | sed 's|/.*/||;s|/handoff||'
    ;;
  switch)
    if [ -d "${CLAUDE_DIR}/$2/handoff" ]; then
      echo "$2" > "${CLAUDE_DIR}/current-session"
      echo "Switched to: $2"
    else
      echo "Session not found: $2"
    fi
    ;;
esac
```
