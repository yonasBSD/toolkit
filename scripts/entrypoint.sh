#!/bin/sh

# shellcheck disable=SC3000-SC4000
IFS=$'\n'
export CARGO_HOME=/usr/local/bin
export RUSTUP_HOME=/usr/local/rustup

# Use workflow commands to do things like set debug messages
printf '::notice file=entrypoint.sh,line=4::%s' "$INPUT_RUN"

for command in $INPUT_RUN; do
  echo "$command" | bash -euo pipefail -s

  exit_status=$?
  if [ $exit_status -ne 0 ]; then
    return 1
  fi
done

exit 0
