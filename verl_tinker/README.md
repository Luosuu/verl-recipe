# VeRL Tinker Server

`verl_tinker` runs a local FastAPI/Ray Serve HTTP server that exposes
Tinker-compatible endpoints backed by VeRL actors. It is intended for users who
have their own GPU capacity and want to run Tinker client code against a local
or self-managed VeRL deployment.

The server owns one global model/session/sampler state. It is designed for a
single active training client, not isolated multi-tenant Tinker sessions.

## Installation

Install the compatible core `verl` first. This repo follows the standard
`REQUIRED_VERL.txt` convention:

```bash
./install_verl.sh --recipe verl_tinker
```

Then install this server package from the repository root:

```bash
pip install -e verl_tinker
```

When rollout/sampling is enabled, install the GPU/runtime dependencies needed by
the selected VeRL rollout backend, such as vLLM.

## Configuration

The server starts from a YAML config that follows the usual VeRL config shape,
with an additional top-level `server` section.

Quick-start configs launch Qwen3-1.7B by default. Override it with
`TINKER_SERVER_MODEL` or by editing `actor_rollout_ref.model.path`.

- `configs/quick_start/actor_rollout.yaml`: actor + rollout. Use this when
  Tinker code needs `asample`.
- `configs/quick_start/actor_rollout_ref.yaml`: actor + rollout + reference
  model. Use this when KL-enabled loss requires reference log probabilities.
- `configs/quick_start/actor.yaml`: actor only. Sampling is unavailable; use
  this for forward/backward and optimizer-only workflows.

## Start The Server

From the repository root:

```bash
python -m verl_tinker.start \
  --config verl_tinker/configs/quick_start/actor_rollout.yaml
```

Actor-only mode:

```bash
python -m verl_tinker.start \
  --config verl_tinker/configs/quick_start/actor.yaml
```

Actor + rollout + reference mode:

```bash
python -m verl_tinker.start \
  --config verl_tinker/configs/quick_start/actor_rollout_ref.yaml
```

The process initializes Ray, deploys a single Ray Serve replica, and loads the
VeRL backend asynchronously. Check readiness with:

```bash
curl http://127.0.0.1:8000/api/v1/healthz
```

Launch helpers are available under `launch_scripts/`.

## Tinker Client Setup

Point Tinker clients at the server:

```python
import os

os.environ["TINKER_BASE_URL"] = "http://127.0.0.1:8000/"
os.environ["TINKER_API_KEY"] = "tml-verl-tinker-local"
```

The current server accepts API keys that start with `tml`.

## Client Examples

Client examples live in `client_examples/` and intentionally use a separate
environment with `tinker` and `tinker-cookbook`. See
`client_examples/README.md`.

## API Surface

Compatibility and lifecycle:

- `GET /api/v1/healthz`
- `POST /api/v1/shutdown`
- `GET|POST /api/v1/get_server_capabilities`
- `POST /api/v1/client/config`
- `POST /api/v1/telemetry`

Session/model metadata:

- `POST /api/v1/get_info`
- `POST /api/v1/create_session`
- `GET /api/v1/sessions/{session_id}`
- `POST /api/v1/sessions`
- `POST /api/v1/create_model`
- `POST /api/v1/create_sampling_session`
- `GET /api/v1/samplers/{sampler_id}`
- `POST /api/v1/session_heartbeat`

Training, sampling, and checkpoint operations:

- `POST /api/v1/forward`
- `POST /api/v1/forward_backward`
- `POST /api/v1/optim_step`
- `POST /api/v1/save_weights_for_sampler`
- `POST /api/v1/save_weights`
- `POST /api/v1/load_weights`
- `POST /api/v1/weights_info`
- `POST /api/v1/export_model`
- `POST /api/v1/asample`
- `POST /api/v1/retrieve_future`

Most long-running operations return a `request_id`. Poll
`/api/v1/retrieve_future` with that ID until the result is available.

## Current Limitations

- Critic, reward model, and teacher model serving are not supported.
- LoRA training is not supported. Some LoRA-shaped metadata is returned for
  Tinker cookbook compatibility, but the backend trains full model weights.
- Multiple clients are not isolated: they share one model state, optimizer
  state, and sampler state.
