#!/usr/bin/env bash

# Extract nixosConfigurations from the 'flake show output'
FLAKE_DIR="$HOME/.config/nixos"
CONFIGS=$(nix flake show "$FLAKE_DIR" | grep -A 100 "nixosConfigurations" | grep "NixOS configuration" | sed 's/[│├└─ ]//g' | sed 's/:.*//')
if [ -z "$CONFIGS" ]; then
    echo "No NixOS configurations found in the flake. Exiting."
    exit 1
fi

# Allow user to choose a configuration
SELECTED_CONFIG=$(echo "$CONFIGS" | tr ' ' '\n' | gum choose)

sudo nixos-rebuild switch --flake "$FLAKE_DIR#$SELECTED_CONFIG"
# sudo nixos-rebuild switch --flake "$FLAKE_DIR#$SELECTED_CONFIG" --specialisation ...
