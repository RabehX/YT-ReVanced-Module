#!/system/bin/sh

# Removing the file UpdateFix.sh from the /data/adb/service.d/ directory
rm -rf /data/adb/service.d/UpdateFix.sh

# Checking if the package_cache directory exists and if so, deleting all of the files in it
[[ -e "/data/system/package_cache" ]] && rm -rf /data/system/package_cache/*
