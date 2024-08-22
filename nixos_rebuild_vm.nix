#!/run/current-system/sw/bin/env bash


export NIX_PATH="nixos-config=/home/mediacom/dotfiles/vm-res/configuration.nix"
sudo nixos-rebuild switch
