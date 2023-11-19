#!/system/bin/sh

# Module directory and name
MODDIR="${0%/*}"
MAIN_MODULE_PROP="/data/adb/modules/$(basename "$(dirname "$0")")/module.prop"

# Copy module.prop to the temporary location and modify the description
FAILED_STATUS=$(sed -E 's/^description=(\[.*][[:space:]]*)?/description=[⛔ The module is non-functioning] /g' "$MODDIR/module.prop")
echo -n "$FAILED_STATUS" > "$MAIN_MODULE_PROP"

# Remove the status file and temporary file
rm -rf "/data/adb/yt-revanced/.tmp/status"

# Exit with success
exit 0
