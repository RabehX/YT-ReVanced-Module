#!/system/bin/sh

MODDIR="${0%/*}"
NVBASE="/data/adb"
MAIN_MODULE_PROP="$NVBASE/modules/$(basename "$(dirname "$0")")/module.prop"
YOUTUBE_PACKAGE_PATH=$(pm path com.google.android.youtube | head -1 | sed 's/^package://g')
REVANCED_APK_PATH="$MODDIR/yt-revanced.apk"
STAGE="$1"
UID="$3"
PROC="$4"

RUN_SCRIPT() {
    case "$STAGE" in
    "prepareEnterMntNs")
        prepareEnterMntNs
        ;;
    "EnterMntNs")
        EnterMntNs
        ;;
    "OnSetUID")
        exit 1
        ;;
    esac
}

prepareEnterMntNs() {
    [ "$API_VERSION" -lt 4 ] && exit 1

    if [ "$PROC" == "com.google.android.youtube" ] || [ "$UID" -lt 10000 ] || [ "$PROC" == "com.android.systemui" ]; then
        touch "$NVBASE/yt-revanced/.tmp/status"
        DYNAMIC_MOUNT_STATUS=$(sed -E 's/^description=(\[.*][[:space:]]*)?/description=[ 😋 Dynamic mount is operational. ] /g' "$MODDIR/module.prop")
        echo -n "$DYNAMIC_MOUNT_STATUS" >"$MAIN_MODULE_PROP"
        exit 0
    fi

    exit 1
}

EnterMntNs() {
    [ -z "$YOUTUBE_PACKAGE_PATH" ] && exit 0

    chcon u:object_r:apk_data_file:s0 "$REVANCED_APK_PATH"
    chmod 0755 "$REVANCED_APK_PATH"
    mount -o bind "$REVANCED_APK_PATH" "$YOUTUBE_PACKAGE_PATH"
    exit 1

}

RUN_SCRIPT
