#!/bin/bash

# Base Claude directory
CLAUDE_BASE="${HOME}/.claude"

# Get repository name from current directory
get_repo_name() {
  # Try to get the repo name from git
  local repo_name=""

  # Check if we're in a git repository
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Get the repo name from the remote URL or the directory name
    repo_name=$(basename -s .git "$(git config --get remote.origin.url 2>/dev/null)" || basename "$(git rev-parse --show-toplevel)")

    # If repo name is empty or contains problematic characters, use directory name
    if [ -z "$repo_name" ] || [[ "$repo_name" =~ [^a-zA-Z0-9_-] ]]; then
      repo_name=$(basename "$(git rev-parse --show-toplevel)")
    fi
  else
    # Not a git repo, use current directory name
    repo_name=$(basename "$(pwd)")
  fi

  # Ensure repo name is valid for directory naming
  repo_name=$(echo "$repo_name" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')

  echo "$repo_name"
}

# Get the current repository name
REPO_NAME=$(get_repo_name)

# Set up the Claude directory with repository structure
REPOS_DIR="${CLAUDE_BASE}/repos"
REPO_DIR="${REPOS_DIR}/${REPO_NAME}"
CLAUDE_DIR="${REPO_DIR}/sessions"

# Create the directories if they don't exist
if [ ! -d "${CLAUDE_DIR}" ]; then
  mkdir -p "${CLAUDE_DIR}"
fi

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
    SESSION_DIR="${CLAUDE_DIR}/${SESSION_ID}"
    HANDOFF_DIR="${SESSION_DIR}/handoff"

    # Create directories
    mkdir -p "${HANDOFF_DIR}"

    # Set as current session
    echo "${SESSION_DIR}/handoff" > "${REPO_DIR}/current-session"
    echo "Created session: ${SESSION_ID} (Repository: ${REPO_NAME})"
    ;;

  "list" | "sessions")
    # List available sessions
    echo "Available sessions for repository: ${REPO_NAME}"

    # Find all session directories (those with handoff subdirectories)
    if [ -d "${CLAUDE_DIR}" ]; then
      SESSIONS=$(find "${CLAUDE_DIR}" -type d -name "handoff" -maxdepth 2 | sed "s|${CLAUDE_DIR}/||" | sed 's|/handoff||' | sort -r)

      if [ -z "$SESSIONS" ]; then
        echo "  No sessions found for this repository"
      else
        # Get current session if it exists
        CURRENT_SESSION_FILE="${REPO_DIR}/current-session"
        if [ -f "${CURRENT_SESSION_FILE}" ]; then
          CURRENT=$(cat "${CURRENT_SESSION_FILE}" 2>/dev/null | sed "s|${CLAUDE_DIR}/||" | sed 's|/handoff||')
        else
          CURRENT=""
        fi

        # Display sessions with current session marked
        echo "$SESSIONS" | while read session; do
          if [ "$session" = "$CURRENT" ]; then
            echo "* ${session} (active)"
          else
            echo "  ${session}"
          fi
        done
      fi
    else
      echo "  No sessions found (directory doesn't exist)"
    fi

    # Option to list all repository sessions
    if [ "$2" == "all" ] && [ -d "${REPOS_DIR}" ]; then
      echo ""
      echo "All repository sessions:"
      for repo_dir in "${REPOS_DIR}"/*/; do
        if [ -d "$repo_dir" ]; then
          repo=$(basename "$repo_dir")
          echo "Repository: ${repo}"

          repo_sessions=$(find "${repo_dir}/sessions" -type d -name "handoff" -maxdepth 2 2>/dev/null |
                          sed "s|${repo_dir}/sessions/||" | sed 's|/handoff||' | sort -r)

          if [ -z "$repo_sessions" ]; then
            echo "  No sessions"
          else
            echo "$repo_sessions" | while read s; do
              echo "  ${s}"
            done
          fi
          echo ""
        fi
      done
    fi
    ;;

  "current")
    # Show current session
    CURRENT_SESSION_FILE="${REPO_DIR}/current-session"

    if [ ! -f "${CURRENT_SESSION_FILE}" ]; then
      echo "No active session for repository: ${REPO_NAME}"
    else
      CURRENT=$(cat "${CURRENT_SESSION_FILE}" 2>/dev/null)
      if [ -z "$CURRENT" ]; then
        echo "No active session for repository: ${REPO_NAME}"
      else
        # Extract session ID from path
        SESSION_ID=$(echo "$CURRENT" | sed "s|${CLAUDE_DIR}/||" | sed 's|/handoff||')
        echo "Current session: ${SESSION_ID} (Repository: ${REPO_NAME})"
      fi
    fi
    ;;

  "switch")
    # Switch to another session
    if [ -z "$ARGUMENT" ]; then
      echo "Error: Missing session ID"
      echo "Usage: session.sh switch SESSION_ID"
      exit 1
    fi

    # Check if the argument contains repository information
    if [[ "$ARGUMENT" == *":"* ]]; then
      # Format is repo:session
      IFS=":" read -r switch_repo switch_session <<< "$ARGUMENT"

      if [ -n "$switch_repo" ] && [ -n "$switch_session" ]; then
        SWITCH_REPO_DIR="${REPOS_DIR}/${switch_repo}"
        SWITCH_SESSION_DIR="${SWITCH_REPO_DIR}/sessions/${switch_session}"
        SWITCH_HANDOFF_DIR="${SWITCH_SESSION_DIR}/handoff"

        if [ -d "${SWITCH_HANDOFF_DIR}" ]; then
          echo "${SWITCH_HANDOFF_DIR}" > "${SWITCH_REPO_DIR}/current-session"
          echo "Switched to: ${switch_session} (Repository: ${switch_repo})"

          # If we're switching repos, inform the user
          if [ "$switch_repo" != "$REPO_NAME" ]; then
            echo "Note: You've switched to a different repository's session."
            echo "This will be active when you run commands from the ${switch_repo} repository directory."
          fi
        else
          echo "Error: Session not found: ${switch_session} in repository ${switch_repo}"
          exit 1
        fi
      else
        echo "Error: Invalid format. Use 'repo:session' or just 'session'"
        exit 1
      fi
    else
      # Standard session switch within current repo
      SESSION_DIR="${CLAUDE_DIR}/${ARGUMENT}"
      HANDOFF_DIR="${SESSION_DIR}/handoff"

      if [ -d "${HANDOFF_DIR}" ]; then
        echo "${HANDOFF_DIR}" > "${REPO_DIR}/current-session"
        echo "Switched to: ${ARGUMENT} (Repository: ${REPO_NAME})"
      else
        echo "Error: Session not found: ${ARGUMENT} in repository ${REPO_NAME}"
        exit 1
      fi
    fi
    ;;

  *)
    echo "Repository-aware session manager for Claude orchestrator"
    echo ""
    echo "Usage: session.sh COMMAND [ARGUMENTS]"
    echo ""
    echo "Commands:"
    echo "  new FEATURE_NAME       Create a new session in the current repository"
    echo "  list | sessions        List sessions in the current repository"
    echo "  list all               List sessions across all repositories"
    echo "  current                Show current session for the current repository"
    echo "  switch SESSION_ID      Switch to another session in the current repository"
    echo "  switch REPO:SESSION    Switch to a session in a specific repository"
    echo ""
    echo "Current repository: ${REPO_NAME}"
    ;;
esac
