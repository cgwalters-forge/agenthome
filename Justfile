# The checks of this repository. CI runs `just check`; so can you.
#
# The layering is: GitHub Actions -> Justfile -> podman -> the tool.
# Every tool comes from a container image pinned by digest, so all a
# machine needs is just and podman (or docker: CONTAINER_RUNTIME=docker).
#
# There is no recipe for YAML: the only YAML here is the workflows, which
# actionlint parses, and markdownlint's own configuration.

runtime := env("CONTAINER_RUNTIME", "podman")
# The repository, read-only, as the tool's working directory.
run := runtime + " run --rm --security-opt label=disable -v '" + justfile_directory() + "':/src:ro -w /src"

taplo := "docker.io/tamasfe/taplo:0.10.0@sha256:27a6488268dd2ef27f64c64af569d72984759d8e3a8cbb4d5d237b746c304f25"
biome := "ghcr.io/biomejs/biome:2.5.15@sha256:deef100144b7293af92eb7f953a67942bad85966ccf0ad2fe391034fdf9ae49a"
markdownlint := "docker.io/davidanson/markdownlint-cli2:v0.23.3@sha256:5fb117aec35c6581d33016b8cba08da0592ce3065e90ea5c7ed0b2942d49c261"
actionlint := "docker.io/rhysd/actionlint:1.7.12@sha256:9d36088643581e728c969f35141f88139fec77280b2be23c1f66f8e40e1025e7"

# List the recipes
default:
    @just --list

# Run every check
check: check-toml check-json check-markdown check-workflows

# Parse the TOML files
[group('check')]
check-toml:
    {{ run }} {{ taplo }} lint --no-schema

# Parse the JSON files, which may have comments, and refuse duplicate keys
[group('check')]
check-json:
    {{ run }} {{ biome }} lint --json-parse-allow-comments=true .

# Lint the Markdown files
[group('check')]
check-markdown:
    {{ run }} {{ markdownlint }} "**/*.md"

# Lint the workflows
[group('check')]
check-workflows:
    {{ run }} {{ actionlint }} -color
