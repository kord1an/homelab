#!/bin/bash
set -euo pipefail

STACK_NAME="$1"

if [ -z "${STACK_NAME:-}" ]; then
  echo "Usage: $0 <stack-name>"
  exit 1
fi

if [ -f .env ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' .env | xargs)
fi

if [ ! -f "stacks/${STACK_NAME}.yml" ]; then
  echo "Stack file stacks/${STACK_NAME}.yml not found"
  exit 1
fi

docker stack deploy -c "stacks/${STACK_NAME}.yml" "${STACK_NAME}"
