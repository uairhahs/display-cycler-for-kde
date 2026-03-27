#!/bin/bash

# --- Icons & Options ---
CH_LAPTOP="󰌢  Laptop Only"
CH_EXTERNAL="󰍹  External Only"
CH_BOTH="󰹑  Extend Both"

OPTIONS="${CH_LAPTOP}\n${CH_EXTERNAL}\n${CH_BOTH}"
FONT="GeistMono Nerd Font"

# --- Launch Rofi with Vibrant Purple HUD ---
CHOICE=$(echo -e "${OPTIONS}" | rofi -dmenu -i -p "󰒓 Display Layout" \
	-theme-str '
    * {
        /* Deep Indigo Glass */
        bg: #1E1E2ED4; 
        /* Vibrant Electric Purple */
        purple-select: #c678dd;
        fg: #ffffff;
    }
    window {
        location:         center;
        anchor:           center;
        width:            450px;
        border:           2px;
        border-radius:    24px;
        border-color:     #c678dd55;
        background-color: @bg;
    }
    mainbox {
        background-color: transparent;
        children: [ inputbar, listview ];
    }
    inputbar {
        background-color: transparent;
        padding: 25px 25px 10px 25px;
        children: [ prompt ];
    }
    prompt {
        /* Step out of single quotes to evaluate variable, step back in */
        font: "'"${FONT}"' Bold 16";
        background-color: transparent;
        text-color: #f5c2e7;
    }
    listview {
        background-color: transparent;
        columns: 1;
        lines: 3;
        spacing: 12px;
        padding: 10px 25px 25px 25px;
        /* Hides the grey scrollbar */
        scrollbar: false;
    }
    element {
        padding: 15px;
        border-radius: 16px;
        background-color: transparent;
        text-color: @fg;
    }
    /* This forces the purple highlight and removes the grey */
    element selected.normal {
        background-color: @purple-select;
        text-color: #ffffff;
    }
    element-text {
        /* Step out of single quotes to evaluate variable, step back in */
        font: "'"${FONT}"' 13";
        background-color: transparent;
        text-color: inherit;
        vertical-align: 0.5;
    }
    /* Specifically disabling scrollbar components */
    scrollbar {
        width: 0px;
        border: 0px;
        handle-width: 0px;
    }
    ')

# --- Logic (Calling switching engine) ---
case "${CHOICE}" in
*"Laptop Only"*)
	/home/"${USER}"/.local/bin/airhahs-display-manager.sh internal
	;;
*"External Only"*)
	/home/"${USER}"/.local/bin/airhahs-display-manager.sh external
	;;
*"Extend Both"*)
	/home/"${USER}"/.local/bin/airhahs-display-manager.sh extended
	;;
*)
	# Exit gracefully if the menu is closed without a selection
	exit 0
	;;
esac