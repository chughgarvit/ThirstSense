# ThirstSense iOS App

**ThirstSense** is an iOS companion application for the multimodal in-ear hydration monitoring framework. It leverages AirPods Pro 2’s inward-facing microphone, motion sensors, and H1 on‑device compute to passively estimate user hydration and dryness in real time.

---

## Features

- **Echo-Based Hydration Sensing**: Plays an inaudible high-frequency chirp and captures ear-canal impulse response.
- **Voice Dryness Analysis**: Records a short speech sample and extracts formant, jitter, shimmer, and MFCC features.
- **IMU-Based Cough & Speech Detection**: Uses built-in accelerometer and gyroscope to detect cough events and speech activity.
- **Real-Time Inference**: Runs a CoreML regression model on-device to output a hydration score.
- **Interactive UI**: Displays hydration level, dryness warnings, and confidence metrics.

---

## Requirements

- Xcode 14.0 or later
- iOS 16.0 or later
- A device running iOS (AirPods Pro 2 pairing requires true wireless support)
- Swift 5.7

---

## Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/IMU-Airpods.git
   cd IMU-Airpods/IMUSensing
   ```

2. **Open the Xcode project**

   Double-click `IMUSensing.xcodeproj` to open in Xcode.

3. **Install dependencies** (if using CocoaPods or Swift Package Manager)

   - _CocoaPods_ (if `Podfile` present):
     ```bash
     pod install
     open IMUSensing.xcworkspace
     ```
   - _SwiftPM_: ensure any packages (e.g., AudioKit) are resolved in Xcode under **File > Packages > Resolve Package Versions**.

4. **Configure Signing & Capabilities**

   - Select the `IMUSensing` target.
   - In **Signing & Capabilities**, choose your development team.
   - Enable the following capabilities:
     - **Background Modes**: Audio, Bluetooth LE accessory.
     - **Microphone** usage.
     - **Motion & Fitness**.

5. **Pair AirPods Pro 2**

   - Make sure your iPhone or iPad is connected to the AirPods Pro 2.
   - Confirm in **Settings > Bluetooth** that the device is listed and connected.

---

## Running the App

1. **Select build target**
   - Choose your iOS device (real device required for Bluetooth/IMU data) in the toolbar.

2. **Build & Run**
   - Press **⌘R** or click **Run**.
   - The app will launch on your device.

3. **Grant Permissions**
   - On first launch, allow access to:
     - **Microphone** (for chirp + voice recording)
     - **Motion & Fitness** (for IMU data)
     - **Bluetooth** (for AirPods Pro accessory connection)

4. **Calibrate & Test**
   - Follow the on-screen prompts to:  
     1. Calibrate your baseline ear-canal impulse response.  
     2. Record a short speech sample.  
     3. Remain still for 60 seconds while cough detection runs in the background.  
   - View your real-time hydration score and dryness alert in the main dashboard.

---

## Usage Tips

- Ensure a snug fit of the AirPods Pro for consistent echo measurements.
- Perform calibration in a quiet environment for best impulse-response estimation.
- Avoid extreme head movements during the chirp and speech recordings.

---

## Troubleshooting

- **No IMU Data**: Verify that **Motion & Fitness** permission is granted in Settings.
- **Chirp Playback Silent**: Check **Volume** on both AirPods and device; test with a visible-chirp flag in settings.
- **Model Inference Fails**: Confirm the `.mlmodel` is included in **Build Phases > Copy Bundle Resources**.

---

## License

This project is released under the MIT License. See [LICENSE](./LICENSE) for details.

