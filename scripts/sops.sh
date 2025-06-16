#!/usr/bin/env bash

# Add a secret to sops
# Also see sopsnix.nix

export SOPS_AGE_KEY_FILE="$HOME/.config/keys.txt"
sops --config ~/.config/nixos/secrets/.sops.yaml ~/.config/nixos/secrets/secrets.yaml
