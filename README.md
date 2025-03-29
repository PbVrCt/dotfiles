```
        a8888b.           Host        -  nixos@nixos
       d888888b.          Machine     -  LENOVO ThinkPad X1 Carbon 5th 20HQS73D00
       8P"YP"Y88          Kernel      -  6.12.18
       8|o||o|88          Distro      -  NixOS 25.05 (Warbler)
       8'    .88          DE          -  River
       8`._.' Y8.         Packages    -  2427 (nix)
      d/      `8b.        Shell       -  fish
     dP        Y8b.       Terminal    -  tmux: server
    d8:       ::88b.      Brightness  -  100%
   d8"         'Y88b      Resolution  -  1920x1080
  :8P           :888      Uptime      -  1h 31m
   8a.         _a88P      CPU         -  Intel® Core™ i7-7500U CPU @ 2.70GHz (4)
 ._/"Yaa     .| 88P|      CPU Load    -  26%
 \    YP"    `|     `.    Memory      -  3.1 GB / 7.9 GB
 /     \.___.d|    .'     Battery     -  75% & Discharging
 `--..__)     `._.'
```

| Function             | Program                  |
|----------------------|--------------------------|
| IDE                  | Helix                    |
| AI                   | Aichat, Claude-code      |
| Compositor           | River                    |
| Keyboard remapper    | Kanata                   |
| Terminal emulator    | Foot, Ghostty            |
| Terminal multiplexer | Tmux                     |
| File manager         | Yazi+Bashmount           |
| Backups              | Restic                   |
| Secrets              | Sops-nix                 |


# Goals, in order:

1. Simple: Minimize cognitive load, minimize configuration.
2. Effective: Get close to the best developer experience available.
3. Reliable: Favor well stablished technologies, favor software with less dependencies, favor lightweight, favor UNIX philosophy.
4. Reproducible: Be able to set up the work environment in a new machine quickly.
5. Minimize maintenance: Do the configuration effort upfront.


# Api key management

The api keys are encrypted.
To use them, place the decryption key at ~/.config/keys.txt. It looks like this:

```keys.txt
AGE-SECRET-KEY-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Then do:

```cat /run/secrets/$SECRET```

# Installation

1. Download the [official recommended graphical iso image](https://nixos.org/download/).
2. Burn it into an usb.
3. Install into a new machine.
At boot choose the UEFI option if available. During the wizard choose GNOME. At the partitioning section choose 'Erase all'.
4. Clone this repo into ~/.config/nixos. 

4a. Copy it from my backup, mounted from another usb:
```bash
nix-shell -p restic
restic restore latest -r "/run/media/$USERNAME/$USB/restic-repo" --target "/home/$USERNAME/restore/"
cp /home/$USERNAME/restore/home/$USERNAME/.config/nixos /home/$USERNAME/.config/nixos -r
```
If using the backup, also copy personal stuff:
```bash
cp /run/media/$USERNAME/$USB/restic-repo /home/nixos/restic-repo -r
cp /home/$USERNAME/restore/home/$USERNAME/.config/keys.txt /home/$USERNAME/.config/keys.txt
cp /home/$USERNAME/restore/home/$USERNAME/projects /home/$USERNAME/projects -r
cp /home/$USERNAME/restore/home/$USERNAME/vault /home/$USERNAME/vault -r
```
5. Add a new entry to the flake outputs.
To do so copy the `hardware-configuration.nix` that has been generated at `/etc/nixos/hardware-configuration.nix`
6. Run:
```bash
nix-shell -p stow
~/.config/nixos/scripts/stow_restow.sh
```
7. Run:
```bash
nix-shell -p git
sudo nixos-rebuild switch --flake "$HOME/.config/nixos#$ENTRY"
```
Takes a while, downloads ~15GB. At the end, if kanata gives a permission error, ignore it.

8. Run: `reboot`

# To do:

- Ask LLMs questions through voice. Look into:
  https://github.com/oddlama/whisper-overlay
  https://github.com/KoljaB/RealtimeSTT

- [Consider remote development](https://www.youtube.com/watch?v=KQ2gz5i7VAA). Look into:
  vps providers
  tailscale
  nixos-anywhere
