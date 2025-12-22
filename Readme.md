# Airhahs Display Cycler for KDE

A utility for cycling through display configurations in KDE Plasma targeting mainly Laptop dock users with a single external monitor (niche use case, I know). This is primarily intended for personal use and backup as I share no affiliation with KDE or any of it's products, affiliates or services.


## Description

This tool allows you to quickly switch between three different display display configurations (single monitor internel only, single monitor external only, extended display with external dispaly centered above internal) in KDE Plasma environments.

## Dependancies

- rofi 
- libkscreen
- GeistMono Nerd Font (or any other preferred font, update in airhahs-display-cycler.sh if needed)

## Installation

```bash
# Clone the repository
git clone https://github.com/uairhahs/display-cycler-for-kde.git
cd display-cycler-for-kde
```


- Note: if you have issues use: 

  ```bash
    chown `whoami`:`whoami` .
  ```
    and/or:
  ```bash
    chmod 755 -R .
  ```
    commands to assure correct ownership and permission on the scripts

```bash
# copy to desired path (preferably ~/.local/bin)
sudo cp . ~/.local/bin
```


## Usage

```bash
# Cycle configurations
./airhahs-display-cycler.sh

# Internal Only
./airhahs-display-cycler.sh internal

# External Only
./airhahs-display-cycler.sh external

# Extended Display
./airhahs-display-cycler.sh extended
```

## Configuration

You can customize the display configurations by modifying the script to suit your specific monitor setup. The script uses `kscreen-doctor` commands to set the display modes, so you may need to adjust the parameters based on your hardware.

To configure the script navigate the KDE system settings to the keyboard section and find the keyboard shortcuts section.
This is where you will be able to able to add a new shortcut for either of the commands and name the new keyboard shortcut In my experience it is necessary to use the `airhahs-display-cycler.sh` handler script though your expereince may vary.
E.g. 
- Command: `/path/to/airhahs-display-cycler.sh`

![Create Shortcut](res/create-shorcut.png)

Once the command is created you are able to assign a keyboard shorcut to it.

That's it done!

## Requirements

- KDE Plasma 5.x or later
- kscreen utilities

## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.