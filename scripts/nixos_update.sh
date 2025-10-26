#!/usr/bin/env bash

# 1. Update an input in the flake.lock
nix flake update nixpkgs

# 2. To apply the updates, rebuild
