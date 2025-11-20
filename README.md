# Razer Naga V2 HS Configurator (Karabiner Edition)

A native macOS app to configure the **Razer Naga V2 HyperSpeed** mouse using **Karabiner-Elements** as the backend engine.

This tool generates complex modification rules for Karabiner, allowing you to map the 12 side buttons to keyboard shortcuts, macros, and special keys (like Fn/Globe) with a visual GUI.

## ✨ Features

*   **Visual Grid:** Map buttons 1-12 easily.
*   **Macro Recording:** Record complex shortcuts (e.g., `Cmd + Shift + Left`).
*   **Fn / Globe Support:** Map buttons to the Function key (useful for Dictation/Emoji).
*   **Auto-Save:** Changes apply instantly to Karabiner-Elements.
*   **Conflict Resolution:** Automatically handles the default "123" output of the Naga hardware.

## ⚡️ Prerequisites

1.  **Install Karabiner-Elements**: [Download Here](https://karabiner-elements.pqrs.org/).
2.  **Configure Karabiner**:
    *   Go to **Devices** -> Find "Razer Naga V2 HS".
    *   ✅ Toggle **"Modify events"** ON.
    *   ❌ Ensure **"Treat as built-in keyboard"** is OFF.
    *   ❌ Ensure **"Disable built-in keyboard..."** is OFF.
3.  **Clean Up Simple Mods**:
    *   Go to **Simple Modifications**.
    *   Ensure there are **NO** mappings for the Naga (e.g., `1 -> b`). Delete them if they exist, as they override macros.

## 🚀 Installation

1.  Clone this repo.
2.  Run the build script:
    ```bash
    ./package_app.sh
    ```
3.  Move `Naga.app` to your Applications folder.
4.  Open it! (It lives in your Menu Bar).

## 🛠️ Usage

1.  Click the **Mouse Icon 🖱️** in your Menu Bar -> **Preferences**.
2.  Select a button (1-12).
3.  **Record Macro:** Click the button and press keys. Press **Esc** to stop.
4.  **Add Fn:** Click the "Add Fn" button to manually insert the Globe key.
5.  **Clear:** Wipe a button's settings.
6.  **Reset All:** Wipe everything.

## ⚙️ Architecture

*   **Frontend:** SwiftUI (Native macOS App).
*   **Backend:** Direct JSON injection into `~/.config/karabiner/karabiner.json`.
*   **Why:** This approach avoids fighting macOS "Secure Input" and "HID Seizure" issues by leveraging Karabiner's kernel-level virtual driver.

## 🐛 Troubleshooting

*   **Button types '1' instead of Macro:**
    *   Check "Simple Modifications" in Karabiner and delete any rules for the mouse.
*   **Fn key not working:**
    *   Use the "Add Fn" button in the UI if recording the Globe key is inconsistent.