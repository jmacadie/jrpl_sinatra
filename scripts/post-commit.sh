#!/bin/bash

# Make sure we're in the repo root directory
ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"

# Recover protected config files
scripts/restore_configs.rb