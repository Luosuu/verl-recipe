#!/bin/bash
# Generic VeRL-backed Tinker server entrypoint.
#
# Required env vars:
#   TINKER_SERVER_CONFIG                Path to the Tinker server YAML config.
# Optional env vars:
#   TINKER_SERVER_MODEL                 Model path override for the config.
#   TINKER_SERVER_MODEL_NAME            Client-visible model name override.
#   TINKER_SERVER_NNODES                Number of Ray worker nodes in the server config.
#   TINKER_SERVER_N_GPUS_PER_NODE       Number of GPUs per Ray worker node in the server config.
#   RAY_ADDRESS                         Ray address. Defaults to local.

set -euo pipefail

SERVE_PORT="${TINKER_SERVER_PORT:-8000}"
MODEL_PATH="${TINKER_SERVER_MODEL:-}"
RAY_ADDRESS="${RAY_ADDRESS:-local}"
SERVER_CONFIG="${TINKER_SERVER_CONFIG:?TINKER_SERVER_CONFIG must point to a Tinker server YAML config}"

echo "=================================================="
echo "verl-recipes Tinker server"
echo "  Serve port: ${SERVE_PORT}"
echo "  Config:     ${SERVER_CONFIG}"
echo "  Model:      ${MODEL_PATH:-<config default>}"
echo "  Model name: ${TINKER_SERVER_MODEL_NAME:-<config default>}"
echo "  Ray:        ${RAY_ADDRESS}"
echo "=================================================="

export PYTHONPATH="verl_tinker/src${PYTHONPATH:+:${PYTHONPATH}}"
echo "  Python:     python"

SERVER_ENV=(
    TINKER_SERVER_PORT="${SERVE_PORT}"
    RAY_ADDRESS="${RAY_ADDRESS}"
    PYTHONUNBUFFERED=1
    RAY_DEDUP_LOGS="${RAY_DEDUP_LOGS:-1}"
)
if [ -n "${MODEL_PATH}" ]; then
    SERVER_ENV+=(TINKER_SERVER_MODEL="${MODEL_PATH}")
fi
if [ -n "${TINKER_SERVER_MODEL_NAME:-}" ]; then
    SERVER_ENV+=(TINKER_SERVER_MODEL_NAME="${TINKER_SERVER_MODEL_NAME}")
fi

env "${SERVER_ENV[@]}" python -m verl_tinker.start \
    --config "${SERVER_CONFIG}" &

SERVER_PID=$!
trap 'kill "${SERVER_PID}" 2>/dev/null || true' EXIT

wait "${SERVER_PID}"
