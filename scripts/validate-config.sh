#!/usr/bin/env bash
# Validate a Fluent Bit configuration file against the Fluent Bit binary via Docker.
# Usage: ./scripts/validate-config.sh <config-file> [classic|yaml]
#
# Exit codes:
#   0 = valid configuration
#   1 = invalid configuration or error

set -euo pipefail

CONFIG_FILE="${1:?Usage: $0 <config-file> [classic|yaml]}"
FORMAT="${2:-classic}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

ABSOLUTE_PATH="$(cd "$(dirname "$CONFIG_FILE")" && pwd)/$(basename "$CONFIG_FILE")"

case "$FORMAT" in
  classic)
    MOUNT_PATH="/fluent-bit/etc/fluent-bit.conf"
    ;;
  yaml)
    MOUNT_PATH="/fluent-bit/etc/fluent-bit.yaml"
    ;;
  *)
    echo "ERROR: Unknown format '$FORMAT'. Use 'classic' or 'yaml'." >&2
    exit 1
    ;;
esac

echo "Validating ${FORMAT} config: ${CONFIG_FILE}"
docker run --rm \
  -v "${ABSOLUTE_PATH}:${MOUNT_PATH}:ro" \
  fluent/fluent-bit:latest \
  /fluent-bit/bin/fluent-bit -c "${MOUNT_PATH}" --dry-run

RESULT=$?
if [[ $RESULT -eq 0 ]]; then
  echo "PASS: Configuration is valid."
else
  echo "FAIL: Configuration is invalid." >&2
fi
exit $RESULT
