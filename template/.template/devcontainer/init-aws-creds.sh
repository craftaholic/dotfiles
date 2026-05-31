#!/usr/bin/env bash
# .devcontainer/init-aws-creds.sh

set -euo pipefail

PROFILES_FILE=".devcontainer/aws-profiles"
OUT_DIR=".devcontainer/aws-generated"
OUT_CREDS="${OUT_DIR}/credentials"

for cmd in aws; do
  command -v "$cmd" &>/dev/null || { echo "❌ Required: $cmd"; exit 1; }
done

[[ -f "$PROFILES_FILE" ]] || {
  echo "❌ Missing $PROFILES_FILE — one SSO profile name per line"
  exit 1
}

mkdir -p "$OUT_DIR"
> "$OUT_CREDS"

echo "📄 Reading profiles from $PROFILES_FILE"
echo ""

SUCCESS=0
FAILED=0

while IFS= read -r PROFILE || [[ -n "$PROFILE" ]]; do
  [[ -z "$PROFILE" || "$PROFILE" =~ ^# ]] && continue

  echo "🔐 $PROFILE"

  CREDS=$(aws configure export-credentials \
    --profile "$PROFILE" \
    --format env 2>&1) || {
    echo "   ❌ Failed — try: aws sso login --profile $PROFILE"
    FAILED=$((FAILED + 1))
    continue
  }

  # Output format: export KEY=VALUE — strip the "export " prefix before parsing
  ACCESS_KEY=$(echo "$CREDS"    | grep AWS_ACCESS_KEY_ID=     | sed 's/export //' | cut -d= -f2)
  SECRET_KEY=$(echo "$CREDS"    | grep AWS_SECRET_ACCESS_KEY= | sed 's/export //' | cut -d= -f2)
  SESSION_TOKEN=$(echo "$CREDS" | grep AWS_SESSION_TOKEN=     | sed 's/export //' | cut -d= -f2)
  REGION=$(aws configure get region --profile "$PROFILE" 2>/dev/null || echo "ap-southeast-1")

  cat >> "$OUT_CREDS" << EOF
[$PROFILE]
aws_access_key_id     = $ACCESS_KEY
aws_secret_access_key = $SECRET_KEY
aws_session_token     = $SESSION_TOKEN
region                = $REGION

EOF

  echo "   ✅ region: $REGION"
  SUCCESS=$((SUCCESS + 1))

done < "$PROFILES_FILE"

chmod 600 "$OUT_CREDS"

echo ""
echo "────────────────────────────────────────────"
echo "✅ $SUCCESS profile(s) written to $OUT_CREDS"
[[ $FAILED -gt 0 ]] && echo "⚠️  $FAILED profile(s) failed — run sso login for those"
# .devcontainer/init-aws-creds.sh

set -euo pipefail

PROFILES_FILE=".devcontainer/aws-profiles"
OUT_DIR=".devcontainer/aws-generated"
OUT_CREDS="${OUT_DIR}/credentials"

for cmd in aws; do
  command -v "$cmd" &>/dev/null || { echo "❌ Required: $cmd"; exit 1; }
done

[[ -f "$PROFILES_FILE" ]] || {
  echo "❌ Missing $PROFILES_FILE — one SSO profile name per line"
  exit 1
}

mkdir -p "$OUT_DIR"
> "$OUT_CREDS"

echo "📄 Reading profiles from $PROFILES_FILE"
echo ""

SUCCESS=0
FAILED=0

while IFS= read -r PROFILE || [[ -n "$PROFILE" ]]; do
  [[ -z "$PROFILE" || "$PROFILE" =~ ^# ]] && continue

  echo "🔐 $PROFILE"

  CREDS=$(aws configure export-credentials \
    --profile "$PROFILE" \
    --format env 2>&1) || {
    echo "   ❌ Failed — try: aws sso login --profile $PROFILE"
    FAILED=$((FAILED + 1))
    continue
  }

  # Output format: export KEY=VALUE — strip the "export " prefix before parsing
  ACCESS_KEY=$(echo "$CREDS"    | grep AWS_ACCESS_KEY_ID=     | sed 's/export //' | cut -d= -f2)
  SECRET_KEY=$(echo "$CREDS"    | grep AWS_SECRET_ACCESS_KEY= | sed 's/export //' | cut -d= -f2)
  SESSION_TOKEN=$(echo "$CREDS" | grep AWS_SESSION_TOKEN=     | sed 's/export //' | cut -d= -f2)
  REGION=$(aws configure get region --profile "$PROFILE" 2>/dev/null || echo "ap-southeast-1")

  cat >> "$OUT_CREDS" << EOF
[$PROFILE]
aws_access_key_id     = $ACCESS_KEY
aws_secret_access_key = $SECRET_KEY
aws_session_token     = $SESSION_TOKEN
region                = $REGION

EOF

  echo "   ✅ region: $REGION"
  SUCCESS=$((SUCCESS + 1))

done < "$PROFILES_FILE"

chmod 600 "$OUT_CREDS"

echo ""
echo "────────────────────────────────────────────"
echo "✅ $SUCCESS profile(s) written to $OUT_CREDS"
[[ $FAILED -gt 0 ]] && echo "⚠️  $FAILED profile(s) failed — run sso login for those"
