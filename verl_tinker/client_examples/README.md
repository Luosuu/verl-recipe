# Tinker Server Client Examples

This directory contains client-side smoke recipes for the VeRL-backed Tinker
server implemented in `verl_tinker`. The client code runs in a small, separate
`uv` environment so it behaves like a normal Tinker user: it connects to an
already-running server through `TINKER_BASE_URL`, waits for `/api/v1/healthz`,
runs one cookbook workload, and calls `/api/v1/shutdown` when the test exits.

## Setup

From this directory:

```bash
uv sync
```

The environment installs `tinker`, `tinker-cookbook`, and the small client-side
utilities used by the examples. It does not install the server package or core
`verl`.

## Run

Start a server first, for example from the repository root:

```bash
python -m verl_tinker.start \
  --config verl_tinker/configs/quick_start/actor_rollout.yaml
```

Then run a client example:

```bash
cd verl_tinker/client_examples
TINKER_BASE_URL=http://127.0.0.1:8000/ uv run tasks/run_single_test.py
```

The helper script performs the same environment setup:

```bash
bash verl_tinker/client_examples/tasks/run_single_test.sh
```

## Available Tests

`tasks/run_single_test.py` selects the workload from `TEST_NAME`. Supported
values are:

- `sft_tulu3`
- `sft_norobot`
- `sft_norobot_no_rollout`
- `sdft_single_task`
- `rl_gsm8k`
- `sft_rl_gsm8k`

If `TEST_NAME` is not set, the runner defaults to `sft_tulu3`.

Useful environment variables:

- `TINKER_BASE_URL`: server URL. Defaults to `http://127.0.0.1:8000/`.
- `TINKER_CLIENT_MODEL_NAME`: model name sent to the Tinker cookbook.
- `TINKER_CLIENT_TOKENIZER_PATH`: tokenizer path override.
- `TEST_NAME`: workload selector.

The client runner sets `TINKER_API_KEY=tml-verl-tinker-local` before invoking
the workload.
