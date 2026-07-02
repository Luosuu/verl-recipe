# Tinker Server Client Examples

This directory contains client-side smoke workloads for the VeRL-backed Tinker
server. The examples use `tinker` and `tinker-cookbook` from a separate `uv`
environment and connect to an already-running server over HTTP.

## Setup

From this directory:

```bash
uv sync
```

This installs only client-side dependencies. It does not install core `verl` or
the `verl_tinker` server package.

## Start A Server

From the repository root, install and start the server first:

```bash
./install_verl.sh --recipe verl_tinker
pip install -e verl_tinker

python -m verl_tinker.start \
  --config verl_tinker/configs/quick_start/actor_rollout.yaml
```

For SFT-only tests that do not need sampling, use:

```bash
python -m verl_tinker.start \
  --config verl_tinker/configs/quick_start/actor.yaml
```

## Run A Workload

In another shell:

```bash
cd verl_tinker/client_examples
uv run tasks/run_single_test.py \
  --base-url http://127.0.0.1:8000/ \
  --test-name sft_tulu3
```

The runner waits for `/api/v1/healthz`, sets
`TINKER_API_KEY=tml-verl-tinker-local`, runs the selected workload, and asks the
server to shut down when the workload exits.

## Workloads

Set `--test-name` to one of:

- `sft_tulu3`
- `sft_norobot`
- `sft_norobot_no_rollout`
- `sdft_single_task`
- `rl_gsm8k`
- `sft_rl_gsm8k`

If `--test-name` is not set, the runner defaults to `sft_tulu3`.

Useful arguments:

- `--base-url`: server URL. Defaults to `http://127.0.0.1:8000/`.
- `--model-name`: model name sent to the Tinker Cookbook.
- `--tokenizer-name-or-path`: tokenizer path override. Defaults to
  `--model-name`.
- `--api-key`: Tinker API key compatibility value.
- `--test-name`: workload selector.

Some workloads download Hugging Face datasets. Configure the standard Hugging
Face cache environment variables if you need offline or pre-populated datasets.
