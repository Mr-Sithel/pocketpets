### PocketPets

* Inspired by the addon [BigMode](https://github.com/JayTDawgzone/bigmode)

- Resize all players pets with 1 command.

### Private Server Approval

| Server | Status | Date |
| :--- | :--- | :--- |
| **HorizonXI** | ${\textsf{\color{orange}{Pending}}}$ | -- |
| **PhoenixXI** | ${\textsf{\color{orange}{Pending}}}$ | -- |

### Overview

Displays all player pets to any size (0.5-2.0) 

Pets include SMN Avatars, PUP,DRG, and BST jug/charmed pets.

* Commands: /pp or /pocketpets
  - /pp                - Toggles automatic pet resizing on/off.
  - /pp help           - Lists available commands below.
  - /pp s|size (value) - Adjusts all pet sizes (e.g., 0.5 to 2.0)
  - /pp st|status      - Shows active status and current size scale.
  - /pp h|hide         - Hide all pets (ModelSize = 0)
  - /pp r|reset        - Resets all active pets to default size (1.0)

### Added

- Added: Settings config
- Added: shortcut commands (Ex. /pp s or /pp size does the same)

### Changes

- Pet sizes can only be changed to .5, 1, 1.5, 2 (Anything else would cause pets to flicker)

### Known Issues
- Possible issue when multiple entities in zone causing random mobs to resize.

---

### Screenshot

![pp](https://github.com/Mr-Sithel/pocketpets/blob/main/Example.png?raw=true)

### Installation

* Download and unzip the correct version of PocketPets at https://github.com/Mr-Sithel/pocketpets/releases/
* Copy the `pocketpets` folder from inside of the `PocketPets-(X.X.X)` folder into your Ashita addons directory
* Addon example directory : `HorizonXI\Game\addons` or `PhoenixXI\addons`
* This was created for `Ashita (Interface v4.30)`
* You can load the addon by typing `/load addon pocketpets`.  It is recommended you add this line to the appropriate place in `scripts/default.txt` to auto load.

#### Credit

Sithel
