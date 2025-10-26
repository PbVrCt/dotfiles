#!/usr/bin/env bash
export SOPS_AGE_KEY_FILE="$HOME/.config/sops_private_key.txt"
sops --config ~/.config/nixos/secrets/.sops.yaml ~/.config/nixos/secrets/secrets.yaml
