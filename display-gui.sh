#!/bin/bash

# --- Icons & Options ---
CH_LAPTOP="󰌢    Laptop Only"
CH_EXTERNAL="󰍹    External Only"
CH_BOTH="󰹑    Extend Both"
OPTIONS="${CH_LAPTOP}\n${CH_EXTERNAL}\n${CH_BOTH}"
FONT="GeistMono Nerd Font"

# --- Vibrant Material Palette ---
BG="#1E1E2E"
FG="#D9E0EE"
ACCENT="#c678dd"
SELECTION="#c678dd"
CREAM="#F5E0DC"
SELECT_TEXT="#11111B"

# --- Wofi Configuration ---
CONFIG_FILE=$(mktemp --suffix=wofi.conf)
STYLE_FILE=$(mktemp --suffix=wofi.css)
trap 'rm -f "${CONFIG_FILE}" "${STYLE_FILE}"' EXIT

cat >"${CONFIG_FILE}" <<WOFI
show=dmenu
width=480
lines=3
location=center
close_on_focus_loss=true
allow_images=false
prompt=""
WOFI

cat >"${STYLE_FILE}" <<WOFI
window {
    border-radius: 32px;
    border: 2px solid rgba(198, 120, 221, 0.3);
    background-color: ${BG};
    font-family: "${FONT}";
}

#outer-box {
    margin: 20px;
}

#input {
    display: none;
    opacity: 0;
    margin: -100px;
}

/* THE FIX: Specifically target the GTK selection layers that cause the "ghost" corners */
flowboxchild, row {
    border-radius: 22px;
    margin: 6px 0px;
    background-color: transparent; /* Kill the default rectangular highlight */
    outline: none;                /* Remove focus rings */
    box-shadow: none;             /* Remove default GTK selection shadows */
}

/* Ensure parents remain transparent even when selected */
flowboxchild:selected, row:selected {
    background-color: transparent;
    outline: none;
    box-shadow: none;
}

#entry {
    padding: 18px 25px;
    border-radius: 22px;
    background-color: ${CREAM};
    border: 1px solid transparent;
    overflow: hidden; /* Force content to respect the 22px radius */
}

#entry #text {
    color: ${SELECT_TEXT};
    font-weight: 600;
}

#entry:selected {
    background-color: ${SELECTION};
    border: 1px solid ${ACCENT};
    border-radius: 22px;
    overflow: hidden;
}

#entry:selected #text {
    color: #ffffff;
}

#scroll {
    border: none;
}
WOFI

# --- Execution ---
if command -v wofi >/dev/null 2>&1; then
	CHOICE=$(echo -e "${OPTIONS}" | wofi --conf "${CONFIG_FILE}" --style "${STYLE_FILE}" --hide-search --no-custom-entry --insensitive)
else
	CHOICE=$(echo -e "${OPTIONS}" | rofi -dmenu -i -p "󰒓  Layout")
fi

# --- Switching Logic ---
case "${CHOICE}" in
*"Laptop Only"*) /home/"${USER}"/.local/bin/airhahs-display-manager.sh internal ;;
*"External Only"*) /home/"${USER}"/.local/bin/airhahs-display-manager.sh external ;;
*"Extend Both"*) /home/"${USER}"/.local/bin/airhahs-display-manager.sh extended ;;
*) exit 0 ;;
esac
