# CI Toolkit

[![Linting](https://github.com/yonasBSD/toolkit/actions/workflows/lint.yaml/badge.svg)](https://github.com/yonasBSD/toolkit/actions/workflows/lint.yaml)
[![CI](https://github.com/yonasBSD/toolkit/actions/workflows/ci.yaml/badge.svg)](https://github.com/yonasBSD/toolkit/actions/workflows/ci.yaml)

This action prints `Hello, World!` or `Hello, <who-to-greet>!` to the log. To
learn how this action was built, see
[Creating a Docker container action](https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action).

## Create Your Own Action

To create your own action, you can use this repository as a template! Just
follow the below instructions:

1. Click the **Use this template** button at the top of the repository
1. Select **Create a new repository**
1. Select an owner and name for your new repository
1. Click **Create repository**
1. Clone your new repository

## Usage

Here's an example of how to use this action in a workflow file:

```yaml
name: Example Workflow

on:
  workflow_dispatch:
    inputs:
      who-to-greet:
        description: Who to greet in the log
        required: true
        default: 'World'
        type: string

jobs:
  say-hello:
    name: Say Hello
    runs-on: ubuntu-latest

    steps:
      # Change @main to a specific commit SHA or version tag, e.g.:
      # yonasBSD/toolkit@09d048b7fab3d6ff0e5708a6ebee59dc4decd117
      # yonasBSD/toolkit@v0.1.0
      - name: Print to Log
        id: print-to-log
        uses: yonasBSD/toolkit@main
        with:
          run: |
            comtrya --version
            just --version
            task --version
            trufflehog --version
            trivy --version
            kcl --version
            rcl --version
            b3sum --version
            bash --version
            venom version
            hurl --version
            typst --version
            treefmt --version
            pipelight --version
            minijinja --version
            cosign version
            llvm-cov --version
            cargo llvm-cov --version
            cargo-binstall -V
            cargo-deny --version
            cargo-audit --version
            cargo-nextest --version
            cargo-insta --version
            cargo-cov --version
            cargo version
            cargo fmt --version
            cargo clippy --version
            ls /usr/local/bin/cargo-auditable
            ls /usr/local/bin/cargo-license
            ls /usr/local/bin/cargo2junit
```

For example workflow runs, check out the
[Actions tab](https://github.com/yonasBSD/toolkit/actions)! :rocket:

## Inputs

| Input          | Default | Description                     |
| -------------- | ------- | ------------------------------- |
| `who-to-greet` | `World` | The name of the person to greet |

## Outputs

| Output | Description             |
| ------ | ----------------------- |
| `time` | The time we greeted you |

## Test Locally

After you've cloned the repository to your local machine or codespace, you'll
need to perform some initial setup steps before you can test your action.

> [!NOTE]
>
> You'll need to have a reasonably modern version of
> [Docker](https://www.docker.com/get-started/) handy (e.g. docker engine
> version 20 or later).

1. :hammer_and_wrench: Build the container

   Make sure to replace `yonasBSD/toolkit` with an appropriate label for your
   container.

   ```bash
   docker build -t yonasBSD/toolkit .
   ```

1. :white_check_mark: Test the container

   You can pass individual environment variables using the `--env` or `-e` flag.

   ```bash
   $ docker run --env INPUT_WHO_TO_GREET="Mona Lisa Octocat" yonasBSD/toolkit
   ::notice file=entrypoint.sh,line=7::Hello, Mona Lisa Octocat!
   ```

   Or you can pass a file with environment variables using `--env-file`.

   ```bash
   $ echo "INPUT_WHO_TO_GREET=\"Mona Lisa Octocat\"" > ./.env.test

   $ docker run --env-file ./.env.testyonasBSD/toolkit
   ::notice file=entrypoint.sh,line=7::Hello, Mona Lisa Octocat!
   ```
