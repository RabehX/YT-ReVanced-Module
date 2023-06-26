#!/system/bin/sh

# This script sets up external tools, default keys, and a selector() function 
# for user input

# External Tools:
# Set the architecture to either arm or x86 depending on if IS64BIT is set
[ "$IS64BIT" ] && ARCH32='arm' || ARCH32='x86'
# Make sure the addon volumekey-Selector/lib directory has proper permissions
chmod -R 0755 "$MODPATH"/addon/VolumeKey-Selector/lib
# Add the addon to the path
export PATH="$MODPATH"/addon/VolumeKey-Selector/lib/"$ARCH32":"$PATH"

# Default keys:
# Set selectorValidationKey value to 42 and selectorDenyKey value to 41
export selectorValidationKey=42
export selectorDenyKey=41

# selector() function:
# Prompt user for their desired keys for validation and deny processes. 
# Allow user to input custom message, force return value, volume up & down keys, delay time, and max retry count.
selector() {
  # Set arguments to defaults if not included
  [ "$1" ] && inselector_message=$1 || inselector_message="Hello World"
  [ "$2" ] && force_ret=$2 || force_ret=null
  [ "$3" ] && vol_up=$3 || vol_up="Yes"
  [ "$4" ] && vol_down=$4 || vol_down="No"
  [ "$5" ] && delay=$5 || delay=5
  [ "$6" ] && max_retry_count=$6 || max_retry_count=3
  
  # Print user's custom message
  ui_print "- $inselector_message"

  # If force ret was set, we don't need to check for the key
  if [ "$force_ret" != null ]; then
    return 0
  fi

  # Print assigned keys 
  ui_print "   Vol Up += $vol_up"
  ui_print "   Vol Down += $vol_down"

  # Check keypresses with keycheck command 
  retry_count=0
  while [ $retry_count -lt $max_retry_count ]; do
    timeout 0 keycheck
    timeout $delay keycheck
    SEL=$?
    if [ $SEL -eq $selectorValidationKey ]; then
      return 0
    elif [ $SEL -eq $selectorDenyKey ]; then
      return 1
    else
      retry_count=$((retry_count + 1))
      retry_left=$((max_retry_count - retry_count + 1))
      ui_print "  Volume key not detected, Retry left: $retry_left"
    fi
  done

  # Set selectorValidationKey equal to selectorDenyKey as placeholder for loop
  selectorValidationKey=$selectorDenyKey

  # Loop until different keypresses are detected
  while [ $selectorValidationKey -eq $selectorDenyKey ]; do
    ui_print ''
    ui_print "[!] Failed to identify your Volume keys"
    ui_print "[!] Setting up new Volume keys..."
    ui_print ''

    # Prompt user to setup new keys
    ui_print "- Press a key to change the default key"
    ui_print "   Press UP"
    timeout 0 keycheck
    timeout 10 keycheck
    selectorValidationKey=$?
    ui_print "   Set to: $selectorValidationKey"

    ui_print "   Press DOWN"
    timeout 0 keycheck
    timeout 10 keycheck
    selectorDenyKey=$?
    ui_print "   Set to: $selectorDenyKey"
  done

  ui_print ''

  # Execute the function again
  selector "$inselector_message" "$force_ret" "$vol_up" "$vol_down" "$delay" "$max_retry_count"
}
