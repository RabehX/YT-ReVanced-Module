#!/system/bin/sh

# Check if installing from Recovery is supported
if ! $BOOTMODE; then
  abort "! Installing from Recovery is Not Supported."
fi

# Unzip Volume Key Selector Addon
unzip -o "$MODPATH/addon/VolumeKey-Selector.zip" -d "$MODPATH/addon/VolumeKey-Selector" &>/dev/null || abort "! Unzip failed"

# Run Volume Key Selector Addon if install scripts exist
if [ "$(ls -A "$MODPATH"/addon/*/install.sh 2>/dev/null)" ]; then
  for addon in "$MODPATH"/addon/*/install.sh; do
    . "$addon"
  done
fi

# Process Monitor Tool (PMT) variables
PMT_MODULE_PATH="$NVBASE/modules/magisk_proc_monitor"
PMTURL=https://github.com/HuskyDG/zygisk_proc_monitor/releases
PMT_VER_CODE="$(grep_prop versionCode "$PMT_MODULE_PATH/module.prop")"

# YouTube variables
YTVERSION=$(dumpsys package com.google.android.youtube | awk -F= '/versionName/ {print $2; exit}')
YRVERSION="$(grep_prop version "${TMPDIR}/module.prop" | sed 's/v//')"
YTURL="https://www.apkmirror.com/apk/google-inc/youtube/youtube-${YRVERSION//./-}-release/"

# Check Android version
if [ "$API" -lt 26 ]; then
  abort "! Only Android 8 and newer devices are Supported."
fi

# Check Process Monitor Tool
if [ ! -d "$PMT_MODULE_PATH" ]; then
  ui_print "! Process Monitor Tool is NOT Installed"
  am start -a android.intent.action.VIEW -d "$PMTURL" &>/dev/null
  abort "! Kindly install it from the following location: $PMTURL"
fi

if [ "$PMT_VER_CODE" -lt 10 ]; then
  ui_print "! Process Monitor Tool v2.3 or above is required"
  am start -a android.intent.action.VIEW -d "$PMTURL" &>/dev/null
  abort "! Kindly upgrade it from the following location: $PMTURL"
fi

if [ -f "$PMT_MODULE_PATH/disable" ] || [ -f "$PMT_MODULE_PATH/remove" ]; then
  ui_print "! Process Monitor Tool is either not enabled or will be removed."
  abort "! Kindly enable it in Magisk beforehand."
fi

# Check if YouTube is installed
if [ ! -d /proc/1/root/data/data/com.google.android.youtube ]; then
  am start -a android.intent.action.VIEW -d "$YTURL" &>/dev/null
  abort "! YouTube is NOT Installed"
fi

if [ "$YTVERSION" != "$YRVERSION" ]; then
  abort "! Apologies, your installed version of YouTube is not compatible with the version on the module."
fi

# Mount YouTube ReVanced
if [ "$ABI" == "armeabi-v7a" ] || [ "$ABI" == "arm64-v8a" ]; then
  THEME_SELECTED="MaterialYou"
  if selector "What is your favorite theme on YouTube ?" null "Amoled" "Material You"; then
    THEME_SELECTED="Amoled"
  fi
  ui_print "[+] Mount [$THEME_SELECTED] YouTube"
  mv "$MODPATH/YT-$THEME_SELECTED" "$MODPATH/yt-revanced.apk"
  rm -rf "$MODPATH/YT-MaterialYou" "$MODPATH/YT-Amoled"
else
  MOUNT_TYPE="Amoled"
  if [ "$API" -ge 32 ]; then
    #MOUNT_TYPE="MaterialYou"
    MOUNT_TYPE="Amoled"
  fi
  ui_print "[+] Automatically Mount [$MOUNT_TYPE] YouTube"
  mv "$MODPATH/YT-$MOUNT_TYPE" "$MODPATH/yt-revanced.apk"
  rm -rf "$MODPATH/YT-MaterialYou" "$MODPATH/YT-Amoled"
fi

# Disable Battery Optimization for YouTube ReVanced
dumpsys deviceidle whitelist + com.google.android.youtube >/dev/null 2>&1

# Cleanup
[ -d "$MODPATH/addon/" ] && rm -rf $MODPATH/addon/

# Finish
XURL=https://t.me/RabahX_Official
mkdir -p "$NVBASE/yt-revanced/.tmp"
am start -a android.intent.action.VIEW -d "$XURL" &>/dev/null && ui_print "- By RabahX, Telegram: @RabahX_Official"
