#!/system/bin/sh

# Module directory and name
MODDIR="${0%/*}"
NVBASE="/data/adb"

# File paths
MAIN_MODULE_PROP="$NVBASE/modules/$(basename "$(dirname "$0")")/module.prop"
TMP_MODULE_PROP="$NVBASE/yt-revanced/.tmp/yt-revanced.prop"

# Copy module.prop to the temporary location
cp -af "$MODDIR/module.prop" "$TMP_MODULE_PROP"

# Modify the description in the temporary file
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ ⛔ The Module is NOT functioning. ] /g' "$TMP_MODULE_PROP"

# Use flock to lock module.prop for exclusive access
flock "$MODDIR/module.prop" -c "mount --bind '$TMP_MODULE_PROP' '$MAIN_MODULE_PROP'"

# Remove the status directory
rm -rf "$NVBASE/yt-revanced/.tmp/status"

exit 0
