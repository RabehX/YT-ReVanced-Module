#!/system/bin/sh

# Get the directory and module name
MODDIR="${0%/*}"
MAIN_MODULE_PROP="$NVBASE/modules/$(basename "$(dirname "$0")")/module.prop"

# Wait for the system to complete booting
while [ "$(resetprop sys.boot_completed)" != 1 ]; do
    sleep 1
done

# Check if a specific file exists; if not, exit
[ -e "$NVBASE/yt-revanced/.tmp/status" ] || exit 0

# Modify a description and write it to a file
GLOBALLY_MOUNT_STATUS=$(sed -E 's/^description=(\[.*][[:space:]]*)?/description=[ 😅 The file is mounted globally because Dynamic mount is NOT functional. ] /g' "$MODDIR/module.prop")
echo -n "$GLOBALLY_MOUNT_STATUS" > "$MAIN_MODULE_PROP"

# Add any additional commands or operations here if needed

