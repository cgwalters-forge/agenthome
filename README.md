# agenthome

Agent configuration for [agentic-job](https://github.com/cgwalters-forge/agentic-job)
runs: per-agent settings (models, providers, permissions) and the
instructions the agents start with. Nothing else belongs here, and nothing
secret: the repository is public, and a run replaces the provider's address
and key with its own inference proxy and run token.

## Layout

Each agent's configuration is one directory, which a run selects by path.

- [`opencode/`](opencode): `opencode.json` (the one provider and its models),
  `opencode-runner.json` (the profile of an unattended run, merged over it)
  and `AGENTS.md` (the instructions).
- `claude/`: not present. agentic-job takes only a `CLAUDE.md` for Claude
  Code from a configuration repository, and no run uses one today.
- [`vibe/`](vibe): `config.toml`, the models Mistral Vibe may use and the
  one it starts with. Runs do not read it yet; see [Vibe](#vibe).
- [`skills/`](skills): reserved for a caller's own skills; empty.

Generic skills are not here: they live in agentic-job, which installs them
for every agent.

## Using it

agentic-job reads an agent's files from a public repository named by its
`agent-config-repo`, `agent-config-ref` and `agent-config-path` inputs
(`[agent] config-repo`, `config-ref` and `config-path` in a runner
configuration); see "Agent configuration repositories and model names" in
its [workflow documentation](https://github.com/cgwalters-forge/agentic-job/blob/main/docs/workflow.md).
The dispatch and review workflows, and the wrappers around them, take the
first and last from repository variables:

| Variable | Value |
| --- | --- |
| `AGENT_CONFIG_REPO` | this repository, as `OWNER/NAME` |
| `AGENT_CONFIG_PATH` | `opencode` |

With them, `AGENT_MODEL` is a name `opencode.json` defines, with its
provider prefix.

## Vibe

`vibe/config.toml` is the `config.toml` of a `VIBE_HOME`: copy it into a
directory, set `VIBE_HOME` to that and `MISTRAL_API_KEY` in the environment.
It holds no key and no provider, so Vibe's built-in `mistral` provider
serves its models.

A run does not use it today. agentic-job refuses a configuration repository
for Vibe and writes the whole `config.toml` itself: both providers pointed at
the broker's `/mistral/v1` route with the run token, and one model, the
run's `model` input, under a fixed alias. So a run selects a model with
`AGENT_MODEL` alone, as a bare name such as `zai-glm-5-3`, which the broker
has to serve. For runs to read this file, agentic-job has to accept
`agent-config-repo` for Vibe, read `config.toml` from it and take the models
and `active_model` from there while still writing the providers and the
switches itself; the dispatch and review workflows and their wrappers, which
forward the repository and path only for opencode, have to forward them for
Vibe too, with `vibe` as the path.

## Changing it

`just check` runs what `ci` runs: it parses the TOML and JSON files and lints
the Markdown and the workflows, each with a tool from a pinned container
image, so it needs only `just` and `podman`. `review.yml` calls agentic-job's
review workflow; `workflow/` holds that review's bounds and task, not agent
configuration.
