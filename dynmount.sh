#!/system/bin/sh

# MODDIR holds the absolute path that script is located in
MODDIR="${0%/*}"
# MODNAME holds the name of module directory
MODNAME="${MODDIR##*/}"
# TMPFILE holds the path to the module.prop file
TMPFILE="$MAGISKTMP/.magisk/modules/$MODNAME/module.prop"
# PACKAGE_NAME variable holds the package name for the YouTube app
PACKAGE_NAME=com.google.android.youtube
# RVXP variable holds the path to revanced.apk
RVXP="$MODDIR/revanced.apk"
# YTP variable holds the PM path for the YouTube app
YTP=$(pm path $PACKAGE_NAME | head -1 | sed 's/^package://g')
# API_VERSION variable holds version number of api 
# API_VERSION = 1
# STAGE variable which is either "prepareEnterMntNs" or "EnterMntNs"
STAGE="$1"  # prepareEnterMntNs or EnterMntNs
# PID variable holds process id of app
PID="$2"    # PID of app process
# UID variable holds uid of app
UID="$3"    # UID of app process
# PROC variable holds the process name (eg. com.google.android.gms.unstable)
PROC="$4"   # Process name. Example: com.google.android.gms.unstable
# USERID variable holds user id of app
USERID="$5" # USER ID of app
# API_VERSION = 2
# MAGISKTMP variable holds the magisk temporary directory
# Enviroment variables: MAGISKTMP, API_VERSION

# RUN_SCRIPT function carries out the appropriate operation based on the value of STAGE
RUN_SCRIPT() {
    if [ "$STAGE" == "prepareEnterMntNs" ]; then
        prepareEnterMntNs
    elif [ "$STAGE" == "EnterMntNs" ]; then
        EnterMntNs
    fi
}

# prepareEnterMntNs function carries out operations before entering the mount namespace of the app process
prepareEnterMntNs() {
    # Check the current API_VERSION, script will only run with API 2 and newer
    if [ "$API_VERSION" -lt 2 ]; then
        # Need API 2 and newer
        exit 1
    fi

    # If Youtube app or system UI process or if UID is less than 10000, update the description in module.prop, create loaded file and exit
    if [ "$PROC" == "com.google.android.youtube" ] || [ "$UID" -lt 10000 ] || [ "$PROC" == "com.android.systemui" ]; then
        touch "$MODDIR/loaded"
        W=$(sed -E 's/^description=(\[.*][[:space:]]*)?/description=[ 😋 Dynamic mount is operational. ] /g' "$MODDIR/module.prop")
        echo -n "$W" >"$TMPFILE"
        exit 0
    fi

    #exit 0 # allow script to run in EnterMntNs stage
    exit 1 # close script and don't allow script to run in EnterMntNs stage
}

# EnterMntNs function carries out operations after entering the mount namespace of the app process
EnterMntNs() {
    # If YTP variable is empty , exit
    if [ -z "$YTP" ]; then exit 0; fi
    # Change the context of revanced.apk to magisk_file
    chcon u:object_r:magisk_file:s0 "$RVXP"
    # Change permissions of revanced.apk
    chmod 0755 "$RVXP"
    # Mount revanced.apk to YouTube 
    mount -o bind "$RVXP" "$YTP"
    # Exit
    exit 1
}

# Run the script
RUN_SCRIPT