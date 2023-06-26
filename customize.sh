#!/system/bin/sh

# This code checks if the boot mode is valid and then unzips and runs an addon 
# It also checks whether Process Monitor Tool (PMT) is installed and has the minimum version required
# It also checks if YouTube is installed, with the correct version, and mounts either Amoled or Material You theme
# It then disables battery optimization for YouTube ReVanced and cleans up by deleting any unnecessary files
# Finally, it shows a message from RabahX on Telegram 
if ! $BOOTMODE; then
  abort "! Installing from Recovery is Not Supported."
fi

# Run Volume Key Selector Addon :
if [ "$(ls -A "$MODPATH"/addon/*/install.sh 2>/dev/null)" ]; then
  for addon in "$MODPATH"/addon/*/install.sh; do
    . "$addon"
  done
fi

# Magisk TMP :
MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin

# PMT Booleon :
PMT_MODULE_PATH="$MAGISKTMP/.magisk/modules/magisk_proc_monitor"
PMTURL=https://github.com/HuskyDG/zygisk_proc_monitor/releases
PMT_VER_CODE="$(grep_prop versionCode "$PMT_MODULE_PATH/module.prop")"
PMT_MIN_VER_CODE=8
PMT_NAMEVERSION="v2.1"
PMT="Process Monitor Tool"

# YouTube Booloen :
PACKAGE_NAME=com.google.android.youtube
YT_PATH=/proc/1/root/data/data/$PACKAGE_NAME
APPNAME="YouTube"
YTSTOCK=$(dumpsys package $PACKAGE_NAME | grep versionName | cut -d= -f 2 | sed -n '1p')
YTREVANCED="$(grep_prop version "$MODPATH/module.prop" | sed 's/v//')"
YTURL="https://www.apkmirror.com/apk/google-inc/youtube/youtube-$(echo -n "$YTREVANCED" | tr "." "-")-release/"

# Check Android :
if [ "$API" -lt 26 ]; then
  abort "! Only Android 8 and newer devices are Supported."
fi

# Check Process Monitor tool :
if [ ! -d "$PMT_MODULE_PATH" ]; then
  ui_print "! $PMT is NOT Installed"
  am start -a android.intent.action.VIEW -d "$PMTURL" &>/dev/null
  abort "! Kindly install it from the following location: $PMTURL"
fi

if [ "$PMT_VER_CODE" -lt "$PMT_MIN_VER_CODE" ]; then
  ui_print "! $PMT $PMT_NAMEVERSION or above is required"
  am start -a android.intent.action.VIEW -d "$PMTURL" &>/dev/null
  abort "! Kindly upgrade it from the following location: $PMTURL"
fi

if [ -f "$PMT_MODULE_PATH/disable" ] || [ -f "$PMT_MODULE_PATH/remove" ]; then
  ui_print "! $PMT is either not enabled or will be removed."
  abort "! Kindly enable it in Magisk beforehand."
fi

# Check YouTube Installed :
if [ ! -d "$YT_PATH" ]; then
  am start -a android.intent.action.VIEW -d "$YTURL" &>/dev/null
  abort "! $APPNAME is NOT Installed"
fi

if [ "$YTSTOCK" != "$YTREVANCED" ]; then
  abort "! Apologies, your installed version of YouTube is not compatible with the version on the module."
fi

# Mounted YouTube & Mindetch Addon :
if [ "$ABI" == "armeabi-v7a" ] || [ "$ABI" == "arm64-v8a" ]; then
  # User is prompted to select their favorite YouTube theme
  if selector "What is your favorite theme on YouTube ?" null "Amoled" "Material You"; then
    ui_print '[+] Mount [Amoled] YouTube'
    mv $MODPATH/YT-Amoled $MODPATH/revanced.apk
    rm -rf $MODPATH/YT-MaterialYou
    rm -rf $MODPATH/YT-Amoled
  else
    ui_print '[+] Mount [Material You] YouTube'
    mv $MODPATH/YT-MaterialYou $MODPATH/revanced.apk
    rm -rf $MODPATH/YT-MaterialYou
    rm -rf $MODPATH/YT-Amoled
  fi

  # User is prompted to install Mindetach module
  if selector "Would you like to install the Mindetach module ?" null "Yes" "No"; then
    mkdir "$MODPATH/Detacher"
    mv $MODPATH/addon/Detacher $MODPATH/Detacher 
    chmod +x $MODPATH/Detacher/detacher
    ui_print '[+] Mindetach Module is installed'
  else
    ui_print '[+] Mindetach Module installation has been neglected'
  fi

  # Warn user about clearing Play Store data
  if [ ! -d /data/data/com.android.vending/databases ]; then
    ui_print "! Avoid clearing Play Store data"
    abort "! Reopen Play Store and reflash the module"
  else
    ui_print "! Mindetach Module will operate only after reboot"
  fi

  # Force stop PlayStore and check the exit code 
  am force-stop com.android.vending
  C=$?
  if [ $C = 1 ]; then
    ui_print "! Mindetach Module will operate only after reboot"
  fi

# Automatically mount YouTube theme for non-supported ABI  
else
  if [ "$API" -ge 32 ]; then
    ui_print '[+] Automaticaly Mount [Material You] YouTube'
    mv $MODPATH/YT-MaterialYou $MODPATH/revanced.apk
    rm -rf $MODPATH/YT-MaterialYou
    rm -rf $MODPATH/YT-Amoled
  else
    ui_print '[+] Automaticaly Mount [Amoled] YouTube'
    mv $MODPATH/YT-Amoled $MODPATH/revanced.apk
    rm -rf $MODPATH/YT-MaterialYou
    rm -rf $MODPATH/YT-Amoled
  fi
  rm -rf "$MODPATH/addon/Detacher.zip"
  ui_print "! Mindetach Module is NOT Supported : $ABI"
fi

# Disable Battery Optimization for YouTube ReVanced :
sleep 1
dumpsys deviceidle whitelist + $PACKAGE_NAME >/dev/null 2>&1

# Cleanup
[ -d "$MODPATH/addon/" ] && rm -rf $MODPATH/addon/

# Finish
XURL=https://t.me/RabahX_Official
am start -a android.intent.action.VIEW -d "$XURL" &>/dev/null
ui_print "- By RabahX, Telegram: @RabahX_Official"
