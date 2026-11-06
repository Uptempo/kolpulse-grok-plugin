#!/usr/bin/env bash
# KOL Pulse Discovery key setup. The key is never printed, never written to a file in this plugin, and never passed
# on a command line (where other processes could see it). It lives in your OS keychain and reaches Grok only as the
# environment variable KOLPULSE_DISCOVERY_KEY, which .mcp.json references as ${KOLPULSE_DISCOVERY_KEY}.
#
#   kolpulse-key.sh store      save the key in the keychain (you type or paste it at a hidden prompt)
#   kolpulse-key.sh check      confirm a key is stored and that the Discovery server accepts it (prints no key)
#   kolpulse-key.sh run [...]  start grok with the key in its environment only:  kolpulse-key.sh run
#   kolpulse-key.sh profile    print the line to add to your shell profile instead (contains no key)
#   kolpulse-key.sh remove     delete the stored key
#
# macOS uses Keychain (security). Linux uses the Secret Service (secret-tool, from libsecret-tools).
set -euo pipefail
SERVICE="kolpulse-discovery"
URL="https://rujebmedz7.execute-api.us-east-1.amazonaws.com/prod/mcp"

os() { case "$(uname -s)" in Darwin) echo mac ;; Linux) echo linux ;; *) echo other ;; esac; }
need_linux_tool() { command -v secret-tool >/dev/null || { echo "secret-tool not found (install libsecret-tools)." >&2; exit 1; }; }

read_key() {  # prints the key to stdout for capture by $(...) only; never call this unredirected
  case "$(os)" in
    mac)   security find-generic-password -s "$SERVICE" -a "$USER" -w 2>/dev/null ;;
    linux) need_linux_tool; secret-tool lookup service "$SERVICE" user "$USER" 2>/dev/null ;;
    *)     echo "Unsupported OS: set KOLPULSE_DISCOVERY_KEY yourself, from a secret store you trust." >&2; return 1 ;;
  esac
}

case "${1:-}" in
  store)
    case "$(os)" in
      mac)   echo "Paste the KOL Pulse Discovery key at the hidden prompt (it is not shown)."
             security add-generic-password -U -s "$SERVICE" -a "$USER" -l "KOL Pulse Discovery key" -w ;;
      linux) need_linux_tool; echo "Paste the KOL Pulse Discovery key at the hidden prompt (it is not shown)."
             secret-tool store --label="KOL Pulse Discovery key" service "$SERVICE" user "$USER" ;;
      *)     echo "Unsupported OS: set KOLPULSE_DISCOVERY_KEY yourself, from a secret store you trust." >&2; exit 1 ;;
    esac
    echo "Stored. Next: $0 check" ;;
  check)
    K="$(read_key)" || true
    if [ -z "${K:-}" ]; then echo "No key stored. Run: $0 store"; exit 1; fi
    case "$K" in *[[:space:]]*) echo "The stored key contains whitespace; store it again."; unset K; exit 1 ;; esac
    echo "Key found (${#K} characters)."
    # The header comes from stdin (-H @-), so the key never appears in curl's command line.
    code=$(printf 'x-api-key: %s\n' "$K" | curl -s -o /dev/null -w '%{http_code}' -X POST "$URL" \
             -H 'content-type: application/json' -H @- \
             --data '{"jsonrpc":"2.0","id":1,"method":"tools/list"}')
    unset K
    if [ "$code" = 200 ]; then echo "Discovery server accepted the key (HTTP 200)."; else echo "Discovery server returned HTTP $code."; exit 1; fi ;;
  run)
    shift
    K="$(read_key)" || true
    if [ -z "${K:-}" ]; then echo "No key stored. Run: $0 store"; exit 1; fi
    KOLPULSE_DISCOVERY_KEY="$K" exec grok "$@" ;;
  profile)
    case "$(os)" in
      mac)   echo "export KOLPULSE_DISCOVERY_KEY=\"\$(security find-generic-password -s $SERVICE -a \"\$USER\" -w 2>/dev/null)\"" ;;
      linux) echo "export KOLPULSE_DISCOVERY_KEY=\"\$(secret-tool lookup service $SERVICE user \"\$USER\" 2>/dev/null)\"" ;;
      *)     echo "Unsupported OS." >&2; exit 1 ;;
    esac ;;
  remove)
    case "$(os)" in
      mac)   security delete-generic-password -s "$SERVICE" -a "$USER" >/dev/null && echo "Removed." ;;
      linux) need_linux_tool; secret-tool clear service "$SERVICE" user "$USER" && echo "Removed." ;;
      *)     echo "Unsupported OS." >&2; exit 1 ;;
    esac ;;
  *) sed -n '2,11p' "$0"; exit 1 ;;
esac
