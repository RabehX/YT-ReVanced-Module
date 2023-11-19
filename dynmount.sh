#!/system/bin/sh

MODDIR="${0%/*}"
NVBASE="/data/adb"
MAIN_MODULE_PROP="$NVBASE/modules/$(basename "$(dirname "$0")")/module.prop"
YOUTUBE_PACKAGE_PATH=$(pm path com.google.android.youtube | awk -F':' 'NR==1{print $2}')
REVANCED_APK_PATH="$MODDIR/yt-revanced.apk"
STAGE="$1"
UID="$3"
PROC="$4"

RUN_SCRIPT() {
    case "$STAGE" in
    "prepareEnterMntNs") prepareEnterMntNs ;;
    "EnterMntNs") EnterMntNs ;;
    esac
}

prepareEnterMntNs() {
    if [ "$API_VERSION" -lt 4 ] &&
        ! { [ "$PROC" = "com.google.android.youtube" ] || [ "$UID" -lt 10000 ] || [ "$PROC" = "com.android.systemui" ]; }; then
        exit 1
    fi

    touch "$NVBASE/yt-revanced/.tmp/status"
    YTVERSION=$(dumpsys package com.google.android.youtube | awk -F= '/versionName/{print $2; exit}')
    YRVERSION=$(awk -F= '/version/{print $2; exit}' "$MODDIR/module.prop" | sed 's/^v//')

    if [ "$YTVERSION" != "$YRVERSION" ]; then
        CHECK_VERSION_STATUS=$(sed -E 's/^description=(\[.*][[:space:]]*)?/description=[⛔ The module is deactivated due to an incompatible YouTube version] /g' "$MODDIR/module.prop")
        echo -n "$CHECK_VERSION_STATUS" >"$MAIN_MODULE_PROP"
        exit 1
    fi
    DYNAMIC_MOUNT_STATUS=$(sed -E 's/^description=(\[.*][[:space:]]*)?/description=[😋 The module is functioning] /g' "$MODDIR/module.prop")
    echo -n "$DYNAMIC_MOUNT_STATUS" >"$MAIN_MODULE_PROP"
    exit 0

}

EnterMntNs() {
    [ -z "$YOUTUBE_PACKAGE_PATH" ] && exit 0

    chcon u:object_r:apk_data_file:s0 "$REVANCED_APK_PATH"
    chmod 0755 "$REVANCED_APK_PATH"
    mount -o bind "$REVANCED_APK_PATH" "$YOUTUBE_PACKAGE_PATH"
    exit 1
}

RUN_SCRIPT
