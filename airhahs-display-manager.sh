#!/bin/bash
# ~/.local/bin/airhahs-display-manager.sh
# shellcheck disable=SC2312

# --- 1. Display Detection ---
INTERNAL_DISPLAY=$(kscreen-doctor -o | grep -E 'eDP|LVDS|DSI' | awk '{print $3}' | head -n 1)

for _ in {1..5}; do
	EXTERNAL_DISPLAY=$(kscreen-doctor -o | grep -E 'DP|eDP|LVDS|DSI' | grep -v "${INTERNAL_DISPLAY}" | awk '{print $3}' | head -n 1)
	if [[ -n ${EXTERNAL_DISPLAY} ]]; then
		break
	fi
	sleep 0.2
done

if [[ -z ${EXTERNAL_DISPLAY} ]]; then
	notify-send "Display Switch Error" "Could not find an external display." -i display-error -a "System"
	exit 1
fi

# --- 2. Dynamic Resolution & Scale Extraction ---
INT_W=$(kscreen-doctor -o | grep -A 15 "Output:.*${INTERNAL_DISPLAY}" | grep '\*current' | grep -oE '[0-9]+x[0-9]+' | cut -d'x' -f1 | head -n 1)
EXT_W=$(kscreen-doctor -o | grep -A 15 "Output:.*${EXTERNAL_DISPLAY}" | grep '\*current' | grep -oE '[0-9]+x[0-9]+' | cut -d'x' -f1 | head -n 1)
EXT_H=$(kscreen-doctor -o | grep -A 15 "Output:.*${EXTERNAL_DISPLAY}" | grep '\*current' | grep -oE '[0-9]+x[0-9]+' | cut -d'x' -f2 | head -n 1)

[[ -z ${INT_W} ]] && INT_W=2560
[[ -z ${EXT_W} ]] && EXT_W=3840
[[ -z ${EXT_H} ]] && EXT_H=2160

INT_SCALE=$(kscreen-doctor -o | grep -iA 5 "Output:.*${INTERNAL_DISPLAY}" | grep -ioE 'scale: [0-9.]+' | awk '{print $2}' | head -n 1)
EXT_SCALE=$(kscreen-doctor -o | grep -iA 5 "Output:.*${EXTERNAL_DISPLAY}" | grep -ioE 'scale: [0-9.]+' | awk '{print $2}' | head -n 1)

[[ -z ${INT_SCALE} ]] && INT_SCALE=1.5
[[ -z ${EXT_SCALE} ]] && EXT_SCALE=1.75

# --- 3. Display Mode Functions ---
apply_internal_only() {
	kscreen-doctor output."${INTERNAL_DISPLAY}".enable output."${INTERNAL_DISPLAY}".scale."${INT_SCALE}" output."${EXTERNAL_DISPLAY}".disable
	notify-send "Laptop Only" -t 2000 -a "System"
}

apply_external_only() {
	kscreen-doctor output."${INTERNAL_DISPLAY}".disable output."${EXTERNAL_DISPLAY}".enable output."${EXTERNAL_DISPLAY}".scale."${EXT_SCALE}"
	notify-send "External Only" -t 2000 -a "System"
}

apply_both_extended() {
	export LC_ALL=C

	# SC2155 Fix: Declare and assign separately
	local log_int_w log_ext_w log_ext_h
	log_int_w=$(awk "BEGIN {printf \"%.0f\", ${INT_W} / ${INT_SCALE}}")
	log_ext_w=$(awk "BEGIN {printf \"%.0f\", ${EXT_W} / ${EXT_SCALE}}")
	log_ext_h=$(awk "BEGIN {printf \"%.0f\", ${EXT_H} / ${EXT_SCALE}}")

	local int_pos_x=0
	local ext_pos_x=0

	if [[ "$(awk "BEGIN {print (${log_ext_w} > ${log_int_w}) ? 1 : 0}")" -eq 1 ]]; then
		int_pos_x=$(awk "BEGIN {printf \"%.0f\", (${log_ext_w} - ${log_int_w}) / 2}")
	else
		ext_pos_x=$(awk "BEGIN {printf \"%.0f\", (${log_int_w} - ${log_ext_w}) / 2}")
	fi

	notify-send "Math Check" "Int at ${int_pos_x},${log_ext_h} | Ext at ${ext_pos_x},0" -t 4000

	kscreen-doctor \
		output."${EXTERNAL_DISPLAY}".enable output."${EXTERNAL_DISPLAY}".scale."${EXT_SCALE}" \
		output."${INTERNAL_DISPLAY}".enable output."${INTERNAL_DISPLAY}".scale."${INT_SCALE}"

	sleep 0.8

	kscreen-doctor \
		output."${EXTERNAL_DISPLAY}".position."${ext_pos_x}",0 \
		output."${INTERNAL_DISPLAY}".position."${int_pos_x}","${log_ext_h}"

	notify-send "Dual Display" "Extended mode stacked." -t 2000 -a "System"
}

# --- 4. Main Cycling Logic ---
cycle_states() {
	# SC2155 Fix: Declare and assign separately
	local internal_enabled external_enabled
	internal_enabled=$(kscreen-doctor -o | grep -A1 "Output:.*${INTERNAL_DISPLAY}" | grep -q "enabled" && echo "true" || echo "false")
	external_enabled=$(kscreen-doctor -o | grep -A1 "Output:.*${EXTERNAL_DISPLAY}" | grep -q "enabled" && echo "true" || echo "false")

	if [[ ${internal_enabled} == "false" ]] && [[ ${external_enabled} == "true" ]]; then
		CURRENT_STATE="external"
	elif [[ ${internal_enabled} == "true" ]] && [[ ${external_enabled} == "false" ]]; then
		CURRENT_STATE="internal"
	elif [[ ${internal_enabled} == "true" ]] && [[ ${external_enabled} == "true" ]]; then
		CURRENT_STATE="extended"
	fi

	# SC2221/2222 Fix: Removed duplicate empty string catch-alls
	case "${CURRENT_STATE}" in
	extended) apply_external_only ;;
	external) apply_internal_only ;;
	internal | "") apply_both_extended ;;
	*) exit 1 ;;
	esac
}

### --- Main Argument Parser ---
case "$1" in
cycle | "") cycle_states ;;
extended) apply_both_extended ;;
external) apply_external_only ;;
internal) apply_internal_only ;;
*) exit 1 ;;
esac
exit 0
