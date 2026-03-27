#!/bin/bash

# --- Icons & Options ---
CH_LAPTOP="󰌢    Laptop Only"
CH_EXTERNAL="󰍹    External Only"
CH_BOTH="󰹑    Extend Both"
OPTIONS="${CH_LAPTOP}\n${CH_EXTERNAL}\n${CH_BOTH}"
FONT="GeistMono Nerd Font"

# --- Vibrant Color Palette (Restored) ---
# Using more opaque colors to prevent the "washed out" look
BG="#1E1E2E"           # Solid base to pop against
ACCENT="#c678dd"       # Purple
SELECTION="#c678dd"    # Full saturation purple for selected
CREAM="#F5E0DC"        # The "cream" from your original screenshot
SELECT_TEXT="#11111B"  # Dark text for high contrast on light buttons

# --- Wofi Config ---
CONFIG_FILE=$(mktemp --suffix=wofi.conf)
trap 'rm -f "${CONFIG_FILE}" "${STYLE_FILE}"' EXIT
cat >"${CONFIG_FILE}" <<EOF
hide_search=true
close_on_focus_loss=true
show=dmenu
width=500
lines=3
location=center
EOF

# --- Wofi Style (Expressive Version) ---
STYLE_FILE=$(mktemp --suffix=wofi.css)
cat >"${STYLE_FILE}" <<EOF
window {
    border-radius: 32px;
    border: 2px solid rgba(198, 120, 221, 0.3);
    background-color: ${BG};
    font-family: "${FONT}";
}

#outer-box {
    margin: 20px;
    padding: 10px;
}

#entry {
    padding: 20px;
    margin: 8px 0px;
    border-radius: 20px;
    background-color: ${CREAM}; /* Default cream background */
}

#entry #text {
    color: ${SELECT_TEXT}; /* Dark text on cream */
    font-weight: 600;
    font-size: 17px;
}

#entry:selected {
    background-color: ${SELECTION}; /* Purple when selected */
    outline: none;
}

#entry:selected #text {
    color: #ffffff; /* White text on purple */
}

/* Recreating the "Header" feel via margin/padding on the box */
#inner-box {
    background-color: transparent;
}

/* Completely nuke search area */
#input {
    display: none;
    opacity: 0;
}
EOF

# --- Launch ---
if command -v wofi >/dev/null 2>&1; then
    CHOICE=$(echo -e "${OPTIONS}" | wofi --conf "${CONFIG_FILE}" --style "${STYLE_FILE}")
else
    # Your Rofi fallback already looks great, keeping it as is
    CHOICE=$(echo -e "${OPTIONS}" | rofi -dmenu -i -p "󰒓  Layout")
fi

# --- Switching Engine ---
case "${CHOICE}" in
*"Laptop Only"*) /home/"${USER}"/.local/bin/airhahs-display-manager.sh internal ;;
*"External Only"*) /home/"${USER}"/.local/bin/airhahs-display-manager.sh external ;;
*"Extend Both"*) /home/"${USER}"/.local/bin/airhahs-display-manager.sh extended ;;
*) exit 0 ;;
esac