#!/bin/bash

CLAUDE_DIR=".claude"
COMMAND="$1"
ARGUMENT="$2"

# Simple session management operations
case "$COMMAND" in
  "new")
    if [ -z "$ARGUMENT" ]; then
      echo "Error: Missing feature name"
      echo "Usage: session.sh new FEATURE_NAME"
      exit 1
    fi

    # Create new session
    SLUG=$(echo "$ARGUMENT" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
    SESSION_ID="$(date +%Y%m%d-%H%M%S)-${SLUG}"
    mkdir -p "${CLAUDE_DIR}/${SESSION_ID}/handoff"
    echo "${CLAUDE_DIR}/${SESSION_ID}/handoff" > "${CLAUDE_DIR}/current-session"
    echo "Created session: ${SESSION_ID}"
    ;;

  "list" | "sessions")
    # List available sessions
    echo "Available sessions:"
    SESSIONS=$(ls -d ${CLAUDE_DIR}/*/handoff 2>/dev/null | sed 's|/.*/||;s|/handoff||')

    if [ -z "$SESSIONS" ]; then
      echo "No sessions found"
    else
      CURRENT=$(cat "${CLAUDE_DIR}/current-session" 2>/dev/null | sed 's|.*/||;s|/handoff||')
      echo "$SESSIONS" | while read session; do
        if [ "$session" = "$CURRENT" ]; then
          echo "* $session (active)"
        else
          echo "  $session"
        fi
      done
    fi
    ;;

  "current")
    # Show current session
    CURRENT=$(cat "${CLAUDE_DIR}/current-session" 2>/dev/null)
    if [ -z "$CURRENT" ]; then
      echo "No active session"
    else
      echo "Current session: $(echo "$CURRENT" | sed 's|.*/||;s|/handoff||')"
    fi
    ;;

  "switch")
    # Switch to another session
    if [ -z "$ARGUMENT" ]; then
      echo "Error: Missing session ID"
      echo "Usage: session.sh switch SESSION_ID"
      exit 1
    fi

    if [ -d "${CLAUDE_DIR}/$ARGUMENT/handoff" ]; then
      echo "${CLAUDE_DIR}/$ARGUMENT/handoff" > "${CLAUDE_DIR}/current-session"
      echo "Switched to: $ARGUMENT"
    else
      echo "Error: Session not found: $ARGUMENT"
      exit 1
    fi
    ;;

  *)
    echo "Simple session manager for Claude orchestrator"
    echo ""
    echo "Usage: session.sh COMMAND [ARGUMENTS]"
    echo ""
    echo "Commands:"
    echo "  new FEATURE_NAME    Create a new session"
    echo "  list | sessions     List available sessions"
    echo "  current             Show current session"
    echo "  switch SESSION_ID   Switch to another session"
    ;;
esac
