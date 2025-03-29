#!/usr/bin/env bash
# Selects a device and copy the snapshots from ~/restic-repo to $MOUNT_POINT/restic-repo

# Check if the source repository exists
SOURCE_REPO="$HOME/restic-repo"
if [ ! -d "$SOURCE_REPO" ]; then
    echo "Source repository not found at $SOURCE_REPO" | gum style --foreground 1
    exit 1
fi

# Get all mounted drives using lsblk
echo "Scanning for mounted drives..."
gum spin --title "Scanning drives" -- sleep 1
MOUNTED_DRIVES=$(lsblk -o NAME,MOUNTPOINT,SIZE,LABEL -n | grep "/run/media/$USER" | awk '{print $4 " (" $3 ") - " $2}')
if [ -z "$MOUNTED_DRIVES" ]; then
    echo "No drives mounted at /run/media/$USER" | gum style --foreground 1
    exit 1
fi

# Let user select a drive using gum
readarray -t DRIVE_OPTIONS <<< "$MOUNTED_DRIVES"
gum style --foreground 6 "Select a drive to copy all snapshots to:"
SELECTED_DRIVE=$(gum choose --height 15 "${DRIVE_OPTIONS[@]}")
if [ -z "$SELECTED_DRIVE" ]; then
    echo "No drive selected. Exiting." | gum style --foreground 1
    exit 1
fi

# Extract the mount point from the selected drive
MOUNT_POINT=$(echo "$SELECTED_DRIVE" | sed -E 's/.*- (\/run\/media\/[^ ]+).*/\1/')
DRIVE_LABEL=$(echo "$SELECTED_DRIVE" | awk '{print $1}')
TARGET_REPO="$MOUNT_POINT/restic-repo"

# Check if there's enough free space on the target drive
SOURCE_SIZE=$(du -s "$SOURCE_REPO" | awk '{print $1}')
TARGET_FREE=$(df -k "$MOUNT_POINT" | tail -1 | awk '{print $4}')

if (( TARGET_FREE < SOURCE_SIZE )); then
    echo "Warning: The target drive may not have enough space." | gum style --foreground 3
    echo "Required: $(numfmt --to=iec-i $SOURCE_SIZE)B, Available: $(numfmt --to=iec-i $TARGET_FREE)B" | gum style --foreground 3
    if ! gum confirm "Continue anyway?"; then
        echo "Operation canceled." | gum style --foreground 3
        exit 0
    fi
fi

# Ensure target directory exists
if [ ! -d "$TARGET_REPO" ]; then
    echo "Creating repository directory on target drive..." | gum style --foreground 6
    mkdir -p "$TARGET_REPO"
fi
# Might need: sudo chown -R $USER:users /run/media/nixos/USB

# Confirm the operation
echo "Source: $SOURCE_REPO" | gum style --foreground 6
echo "Target: $TARGET_REPO on $DRIVE_LABEL" | gum style --foreground 6

if ! gum confirm "Copy ALL snapshots to the target drive?"; then
    echo "Operation canceled." | gum style --foreground 3
    exit 0
fi

# Initialize target repo if it's empty
if [ ! -f "$TARGET_REPO/config" ]; then
    echo "Initializing target repository..." | gum style --foreground 6
    gum style --foreground 3 "IMPORTANT: Use the SAME PASSWORD as your source repository"
    restic -r "$TARGET_REPO" init
    if [ $? -ne 0 ]; then
        echo "Failed to initialize target repository." | gum style --foreground 1
        exit 1
    fi
fi

# Copy all snapshots
echo "Copying all snapshots to target drive..." | gum style --foreground 6
restic copy --from-repo "$SOURCE_REPO" --repo "$TARGET_REPO"

# Check command status
if [ $? -ne 0 ]; then
    gum style --foreground 1 --border double --align center --width 60 \
        "✗ Failed to copy snapshots to $DRIVE_LABEL"
    exit 1
fi

# Ask if user wants to prune old snapshots
if gum confirm "Do you want to prune old snapshots from the USB drive?"; then
    # Let user select a retention policy
    gum style --foreground 6 "Select a retention policy for pruning:"
    RETENTION_POLICY=$(gum choose "Keep last 7 days" "Keep last 30 days" "Keep last 90 days" "Custom")
    
    FORGET_ARGS=""
    case "$RETENTION_POLICY" in
        "Keep last 7 days")
            FORGET_ARGS="--keep-within 7d"
            ;;
        "Keep last 30 days")
            FORGET_ARGS="--keep-within 30d"
            ;;
        "Keep last 90 days")
            FORGET_ARGS="--keep-within 90d"
            ;;
        "Custom")
            gum style --foreground 6 "Enter custom retention policy (e.g., --keep-last 10 --keep-daily 7):"
            FORGET_ARGS=$(gum input --placeholder "Enter restic forget arguments")
            ;;
    esac
    
    if [ -n "$FORGET_ARGS" ]; then
        echo "Pruning old snapshots with policy: $FORGET_ARGS" | gum style --foreground 6
        
        # Show what would be pruned first
        echo "The following snapshots would be removed:" | gum style --foreground 3
        FORGET_CMD="restic forget --dry-run $FORGET_ARGS -r \"$TARGET_REPO\""
        eval "$FORGET_CMD"
        
        # Confirm before actual pruning
        if gum confirm "Proceed with pruning these snapshots?"; then
            echo "Pruning snapshots..." | gum style --foreground 6
            FORGET_CMD="restic forget --prune $FORGET_ARGS -r \"$TARGET_REPO\""
            eval "$FORGET_CMD"
            
            if [ $? -eq 0 ]; then
                gum style --foreground 2 --align center --width 60 \
                    "✓ Successfully pruned old snapshots"
            else
                gum style --foreground 1 --align center --width 60 \
                    "✗ Failed to prune snapshots"
            fi
        else
            echo "Pruning canceled." | gum style --foreground 3
        fi
    fi
fi

# Final success message
gum style --foreground 2 --border rounded --align center --width 60 \
    "✓ Successfully copied all snapshots to $DRIVE_LABEL"
