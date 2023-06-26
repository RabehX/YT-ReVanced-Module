#!/system/bin/sh

# Set the directory path of the module 
MODDIR="${0%/*}"
# Get the name of the module 
MODNAME="${MODDIR##*/}"
# Set the name of the package 
PACKAGE_NAME=com.google.android.youtube
# Get the path of MAGISKTMP or set it to /sbin if not found 
MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin
# Set the TMPFILE path 
TMPFILE="$MAGISKTMP/.magisk/modules/$MODNAME/module.prop"
# Wait until boot has completed 
while [ "$(resetprop sys.boot_completed)" != 1 ]; do
    sleep 1
done
sleep 1

# Exit if the file "loaded" is not present in the MODDIR 
[ -e "$MODDIR/loaded" ] || exit 0

# Edit the module.prop file by adding a description 
W=$(sed -E 's/^description=(\[.*][[:space:]]*)?/description=[ 😅 The file is mounted globally because Dynamic mount is NOT functional. ] /g' "$MODDIR/module.prop")
# Store the output of the edited module.prop to TMPFILE 
echo -n "$W" >"$TMPFILE"
# Force-stop the com.android.vending package 
am force-stop com.android.vending
# Execute detacher in the MODDIR 
$MODDIR/Detacher/detacher