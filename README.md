# Razer Naga V2 HS Configurator (macOS)

A lightweight, native macOS app to configure the **Razer Naga V2 HyperSpeed** mouse using **Karabiner-Elements**.

It allows you to map the 12 side buttons to keyboard shortcuts or macros with a visual GUI.

## ⚡️ Prerequisites

1.  **Install Karabiner-Elements**: [Download Here](https://karabiner-elements.pqrs.org/).
2.  **Open Karabiner-Elements**:
    *   Go to **Devices**.
    *   Find "Razer Naga V2 HS".
    *   ✅ Toggle **"Modify events"** ON.
    *   ❌ Ensure **"Treat as built-in keyboard"** is OFF.
    *   ❌ Ensure **"Disable built-in keyboard..."** is OFF.
3.  **Clean Up**:
    *   Go to **Simple Modifications**.
    *   Ensure there are **NO** mappings for the Naga (e.g., `1 -> b`). Delete them if they exist.

## 🚀 Installation

1.  Clone this repo.
2.  Run the build script:
    ```bash
    ./package_app.sh
    ```
3.  Move `Naga.app` to your Applications folder.
4.  Open it!

## 🛠️ Usage

1.  Click the **Mouse Icon 🖱️** in your Menu Bar -> **Preferences**.
2.  Select a button (1-12).
3.  Click **Record Macro**.
4.  Press your desired shortcut (e.g., `Cmd + C`).
5.  Press **Esc** or **Stop Recording**.
6.  **Done!** The rule is instantly applied to Karabiner.

## ⚙️ How it Works

*   The app acts as a GUI for Karabiner's `complex_modifications`.
*   It reads/writes directly to `~/.config/karabiner/karabiner.json`.
*   It injects a rule named **"Naga Controller Rules"** into your active profile.
*   No background drivers, no kexts, no seizing devices. Just pure JSON config generation.

## 🐛 Troubleshooting

*   **Button types '1' instead of Macro:**
    *   You likely have a "Simple Modification" in Karabiner overriding the macro. Go to Karabiner -> Simple Modifications and delete it.
    *   Ensure "Modify events" is ON for the device.
*   **App doesn't show changes:**
    *   Restart the app to force a reload of the config state.
