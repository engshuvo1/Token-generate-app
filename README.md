# Token-generate-app (TokenApp)

A modern Flutter application designed for queue management, token generation, and instant receipt printing via **Bluetooth Thermal Printers** (ESC/POS).

---

## Features

- **Queue & Token Generation**:
  - Live preview of generated token slips with department badges.
  - Multi-prefix support (`A`, `B`, `C`, `D`, `T`, `VIP`).
  - Automatic 3-digit sequence formatting (`A-001`, `B-042`).
  - Stepper controls (+1, -1) and reset sequence action.
  - Department / Counter categorization (`General`, `Cashier`, `Billing`, `Inquiry`, `Support`, `VIP`).

- **Bluetooth Thermal Printing**:
  - Wireless Bluetooth printer discovery and pairing status.
  - Direct ESC/POS byte streaming via `print_bluetooth_thermal` & `esc_pos_utils_plus`.
  - Supports standard **58mm** (portable/mobile) and **80mm** (desktop POS) thermal paper widths.
  - Automatic feed and paper cutting (`PosCutMode.full`).
  - Optional QR code generation on ticket for digital verification.
  - Quick "Test Print" slip utility to confirm printer connectivity.

- **Queue Print History & Re-printing**:
  - Persistent log of recently generated tokens with timestamps.
  - Single-tap reprint for lost tickets.

- **Customizable Business Information & Settings**:
  - Configurable Organization / Business Name.
  - Subtitle, branch, and counter/desk name.
  - Custom footer notices and terms.
  - Toggle auto-increment on print.

---

## Project Structure

```
lib/
├── main.dart                 # Application entry point with Material 3 theme
├── models/
│   └── token_data.dart       # Token data model with JSON serialization
├── screens/
│   ├── home_screen.dart      # Main token generator and print action UI
│   ├── printer_screen.dart   # Bluetooth scan, connect/disconnect & test slip
│   └── settings_screen.dart  # Business details, paper size & print preferences
├── services/
│   └── printer_service.dart  # Bluetooth state & ESC/POS communication service
├── utils/
│   └── ticket_formatter.dart # ESC/POS ticket layout and formatting generator
└── widgets/
    ├── print_button.dart     # Action print button with responsive status
    ├── printer_status.dart   # Dynamic printer connection badge
    ├── time_picker_field.dart# Real-time clock and calendar display
    └── token_input.dart      # Token controls, sequence stepper & prefix chips
```

---

## Required Permissions (Android)

Thermal printing over Bluetooth requires the following permissions in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" android:maxSdkVersion="30" />
```

---

## Getting Started

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Analysis & Tests**:
   ```bash
   flutter analyze
   flutter test
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

4. **Connect a Thermal Printer**:
   - Turn on your 58mm or 80mm Bluetooth thermal printer.
   - Pair the printer in your mobile device's system Bluetooth settings.
   - Open TokenApp, navigate to **Printers**, select your printer, and tap **Connect**.
   - Tap **Test Print** to verify, then start generating tokens!
