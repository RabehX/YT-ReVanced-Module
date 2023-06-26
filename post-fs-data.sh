#!/system/bin/sh

# Save the variable containing module directory into MODDIR 
MODDIR="${0%/*}"
# Save the variable containing module name into MODNAME
MODNAME="${MODDIR##*/}"
# Get the Magisk Path and store in MAGISKTMP or set it to /sbin if not successful 
 MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin

# Set the module property file path
 PROPFILE="$MAGISKTMP/.magisk/modules/$MODNAME/module.prop"
# Set temporary file path 
 TMPFILE="$MAGISKTMP/yt-revanced.prop"
# Copy module property to temp file 
 cp -af "$MODDIR/module.prop" "$TMPFILE"

# Replace description value with new value
 sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ ⛔ The Module is NOT functioning. ] /g' "$TMPFILE"
# Appy lock on module property file
 flock "$MODDIR/module.prop"

# Bind the temp file path to module property file path
 mount --bind "$TMPFILE" "$PROPFILE"

# Remove the loaded file
 rm -rf "$MODDIR/loaded"
# Exit shellscript
 exit 0