# Shop Billing & Inventory System — Windows Release & Packaging Guide

This guide outlines how to build, package, and install the **Shop Billing & Inventory System** as a standalone Windows desktop application (`.exe`) using Flutter and Inno Setup.

---

## 1. Prerequisites (on a Windows Build Machine)
- **Flutter SDK** (Stable channel)
- **Visual Studio** (with the *"Desktop development with C++"* workload installed)
- **Inno Setup** (Free installer builder for Windows)

---

## 2. Building the Windows Release Executable
Open a terminal in the project root folder and run:
```bash
flutter build windows --release
```
This compiles the native Windows desktop binary into:
`build/windows/x64/runner/Release/`

---

## 3. Creating the Standalone Windows Installer (`.exe`)
1. Download and install **Inno Setup** (https://jrsoftware.org/isdl.php).
2. Open the provided Inno Setup script file:
   `InventorySystem-Setup-1.0.0.iss`
3. Click **Compile** (or press `Ctrl + F9`).
4. Inno Setup will generate the standalone installer executable in:
   `bin/installer/InventorySystem-Setup-1.0.0.exe`

---

## 4. Installing and Testing on a Clean PC
1. Copy `InventorySystem-Setup-1.0.0.exe` to a clean Windows 10/11 PC (no Flutter or SDK required).
2. Double-click the installer and follow the setup wizard.
3. Launch the application from the desktop shortcut or Start Menu.
4. Verify offline operation, Hive local database persistence, and Firebase cloud synchronization when online.
