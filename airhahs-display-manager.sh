#!/bin/bash
# ~/.local/bin/airhahs-display-manager.sh
# v5: Fully dynamic script with retry loop. Intended to be run by a caller.
# --- Display Detection ---
INTERNAL_DISPLAY=$(kscreen-doctor -o | grep -E 'eDP|LVDS|DSI' | awk '{print $3}')
# --- Retry Loop for External Display ---
for i in {1..5}; do
    EXTERNAL_DISPLAY=$(kscreen-doctor -o | grep -E 'DP|eDP|LVDS|DSI' | grep -v "$INTERNAL_DISPLAY" | awk '{print $3}')
    if [ ! -z "$EXTERNAL_DISPLAY" ]; then
        break # Exit loop if found
    fi
    sleep 0.2 # Wait 200ms before next attempt
done
# --- Exit if no external display is found ---
if [ -z "$EXTERNAL_DISPLAY" ]; then
    notify-send "Display Switch Error" "Could not find an external display." -i display-error
    exit 1
fi
# --- Resolution Detection ---
INTERNAL_RES_X=$(kscreen-doctor -o --json | sed -n '/^{/,/^}$/p' | jq -r ".outputs[] | select(.name == \"${INTERNAL_DISPLAY}\") | .modes[0].size.width")
EXTERNAL_RES_X=$(kscreen-doctor -o --json | sed -n '/^{/,/^}$/p' | jq -r ".outputs[] | select(.name == \"${EXTERNAL_DISPLAY}\") | .modes[0].size.width")
EXTERNAL_RES_Y=$(kscreen-doctor -o --json | sed -n '/^{/,/^}$/p' | jq -r ".outputs[] | select(.name == \"${EXTERNAL_DISPLAY}\") | .modes[0].size.height")
# Get scale with error handling - default to 1.0 if parsing fails
EXTERNAL_SCALE=$(kscreen-doctor -o --json | sed -n '/^{/,/^}$/p' | jq -r ".outputs[] | select(.name == \"${EXTERNAL_DISPLAY}\") | .scale ")
# Ensure we have a valid scale value
if [[ -z "$EXTERNAL_SCALE" ]] || [[ ! "$EXTERNAL_SCALE" =~ ^[0-9]+\.?[0-9]*$ ]]; then
    EXTERNAL_SCALE="1.0"
fi
# --- Functions for Display Modes ---
apply_internal_only() {
    kscreen-doctor output."${INTERNAL_DISPLAY}".enable output."${EXTERNAL_DISPLAY}".disable
    notify-send "Display Mode: Laptop Only" "Using ${INTERNAL_DISPLAY}" -i computer -a 'Display Cycler'
}
apply_external_only() {
    kscreen-doctor output."${INTERNAL_DISPLAY}".disable output."${EXTERNAL_DISPLAY}".enable
    notify-send "Display Mode: External Only" "Using ${EXTERNAL_DISPLAY}" -i video-display -a 'Display Cycler'
}
apply_both_extended() {
    # Calculate centered position: (external_width - internal_width) / 2
    local center_x=$(( (EXTERNAL_RES_X - INTERNAL_RES_X) / 2 ))
    local adjusted_y=$(echo "$EXTERNAL_RES_Y $EXTERNAL_SCALE" | awk '{printf "%.0f", $1 / $2}')
    # Position internal display centered below external display (no gap)
    # External display starts at Y=0, so internal should start at Y=EXTERNAL_RES_Y
    kscreen-doctor output."${EXTERNAL_DISPLAY}".enable output."${EXTERNAL_DISPLAY}".position.0,0 output."${INTERNAL_DISPLAY}".enable output."${INTERNAL_DISPLAY}".position.${center_x},${adjusted_y}
    notify-send "Display Mode: Extended" "Internal display centered below external" -i video-display -a 'Display Cycler'
}
# --- Main Cycling Logic ---
cycle_states() {
    local internal_enabled=$(kscreen-doctor -o | grep -A1 "Output:.*${INTERNAL_DISPLAY}" | grep -q "enabled" && echo "true" || echo "false")
    local external_enabled=$(kscreen-doctor -o --json | sed -n '/^{/,/^}$/p' | jq -r '(.outputs[] | select(.name | test("eDP|LVDS|DSI")) | .name) as $internal_name | .outputs[] | select(.name != $internal_name) | .enabled')
    
    if [ "$internal_enabled" = "false" ] && [ "$external_enabled" = "true" ]; then
         CURRENT_STATE="external"
    elif [ "$internal_enabled" = "true" ] && [ "$external_enabled" = "false" ]; then
         CURRENT_STATE="internal"
    elif [ "$internal_enabled" = "true" ] && [ "$external_enabled" = "true" ]; then
         CURRENT_STATE="extended"
    fi
    
    case "$CURRENT_STATE" in
    extended|"") apply_external_only;;
    external|"") apply_internal_only;;
    internal|"") apply_both_extended;;
    *) exit 1 ;;
    esac

    
}
### --- Main Argument Parser ---
case "$1" in
    cycle|"") cycle_states ;;
    extended|"") apply_both_extended;;
    external|"") apply_external_only;;
    internal|"") apply_internal_only;;
    *) exit 1 ;;
esac
exit 0
