# TwinPics Scripts Documentation

## Overview
TwinPics is a script suite for Capture One that automates variant creation when capturing photos. It consists of two scripts:
- `TwinPics.applescript`: Configuration interface
- `TwinPicsOnBackground.applescript`: Background automation handle

![twinpics](https://github.com/Igrekess/TwinPics/blob/main/img/twinpics.gif)

- macOS 10.10 (Yosemite) or later
- Capture One
- PrefsStorageLib v1.1.0
- Dialog Toolkit Plus v1.1.3

## Installation

1. Place TwinPics.applescript in your capture one scripts folder, and TwinPicsOnBackground in your capture one scripts folder / background scripts.

2. Install required libraries (optionel if you use the run-only compiled bundle scptd files,[zip archive here](/Compiled%20Bundle%20Run-Only), its included):
- PrefsStorageLib
- Dialog Toolkit Plus

3. Due to a bug, launching a script via the Capture One menu with the mouse does not work consistently. Occasionally, selecting the script manually from the menu fails to execute it as expected. This inconsistency suggests that alternative triggers may be necessary for reliable execution. I strongly recommend configuring a keyboard shortcut for TwinPics:

    - Open **System Preferences** and go to **Keyboard**.
    - Select the **Shortcuts** tab, then click on **App Shortcuts** in the sidebar.
    - Click the **+** button to add a new shortcut.
    - In the **Application** dropdown, select **Capture One**.
    - In the **Menu Title** field, type the exact name of the menu command you want to assign a shortcut to (e.g., "TwinPics").
    - In the **Keyboard** Shortcut field, press the key combination you’d like to use.
    - Click **Add** to save the shortcut.
   
## Configuration (TwinPics.applescript)

Launch TwinPics.applescript to configure automation preferences through a GUI:

### Settings

- **Twin Type**
  - `new variant`: Creates a fresh variant
  - `clone variant`: Duplicates existing variant

- **Twin Adjustments**
  - `B&W / Color`: Creates a B&W/Color pair
  - `Flat Raw`: Resets all adjustments
  - `Preset`: Applies selected style

- **Viewer Selection**
  - `A`: Shows original only
  - `B`: Shows variant only
  - `A&B`: Shows both variants

- **Keywords**
  - Enter comma-separated keywords to apply

- **ON/OFF Toggle**
  - Enables/disables automation

### Preset Selection
Choose from available Capture One styles to apply to variants

## Background Process (TwinPicsOnBackground.applescript)

Automatically triggers when new photos are captured:

1. Checks if automation is enabled
2. Creates variant based on settings
3. Applies selected adjustments
4. Sets viewer configuration
5. Applies keywords

## Usage Example

1. Open TwinPics.applescript
2. Configure desired settings
3. Enable automation with ON checkbox
4. Click SAVE
5. Start capturing photos in Capture One
6. Variants will be created automatically

## Preferences Storage

Settings are stored in domain `com.yse.twinpics`:
- variationSelected
- selectedPreset
- TwinPicsOn
- VariantType
- viewSelection
- TwinPickeywords

## Troubleshooting

- Verify scripts are in correct folder
- Check required libraries are installed
- Ensure Capture One scripts are enabled
- Verify TwinPicsOn is enabled
- Check Console.app for errors
