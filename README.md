# SteadyHand - Apple Pencil Tremor Assistance App

An innovative iPad application designed to assist users with hand tremors while using Apple Pencil for drawing and writing. Built for the Swift Student Challenge.

## 🎯 Features

### 1. Free Hand Drawing Mode
- **Real-time stabilization** using 1€ filter algorithm for tremor cancellation
- **Adjustable correction level** (0-100%) to balance between natural feel and stability
- **Pixel-perfect UI** with lined paper background
- **Tool palette** with eraser, undo, and drawing tools
- **Biometric data logging** for analysis and research

### 2. Assessment Mode
- **Spiral Coordination Task** for measuring tremor severity
- **Real-time accuracy calculation** and deviation tracking
- **Adaptive haptic feedback** with customizable intensity
- **Wall resistance** feature for guided drawing
- **Live metrics** showing tremor magnitude and performance

### 3. Settings & Customization
- **Hover locking strength** adjustment
- **Squeeze sensitivity** configuration
- **Live tremor metrics** visualization
- **Haptic feedback** preferences

## 📱 Technical Details

- **Platform**: iOS 17.0+
- **Language**: Swift 6
- **Framework**: SwiftUI
- **Supported Devices**: iPad & iPhone
- **Package Manager**: Swift Package Manager

## 🏗️ Project Structure

```
tremor/
├── App/
│   ├── MyApp.swift                 # App entry point
│   ├── ContentView.swift           # Main navigation (TabView)
│   ├── FreeDrawView.swift          # Free hand drawing mode
│   ├── SpiralExerciseView.swift   # Assessment/exercise mode
│   ├── SettingsView.swift          # Settings & configuration
│   ├── PencilSensorManager.swift  # Core pencil sensor handling
│   ├── BiometricLogger.swift      # Data logging & export
│   ├── OneEuroFilter.swift        # 1€ filter implementation
│   ├── HapticManager.swift        # Haptic feedback system
│   └── AirCanvas.swift            # Canvas rendering
├── Package.swift                   # Package configuration
└── .gitignore
```

## 🔧 Key Components

### PencilSensorManager
- Manages Apple Pencil sensor data (pressure, altitude, azimuth, roll)
- Implements stroke stabilization using 1€ filter
- Handles undo/redo functionality
- Integrates with BiometricLogger for data collection

### OneEuroFilter
- Advanced low-pass filter for tremor cancellation
- Dynamically adjusts cutoff frequency based on movement speed
- Reduces lag while maintaining smoothness

### BiometricLogger
- Logs sensor data to CSV files
- Thread-safe file operations
- Share functionality for data export

## 🎨 UI Design Philosophy

- **Pixel-perfect layouts** mimicking professional drawing apps
- **Intuitive tool palette** with visual feedback
- **Adaptive UI** that responds to user actions
- **Accessibility-focused** with clear visual indicators

## 🚀 Building & Running

This project requires Xcode and can be built using Swift Package Manager:

1. Open the project in Xcode
2. Select an iPad simulator or device
3. Build and run (⌘R)

**Note**: The project uses `AppleProductTypes` for Swift Playgrounds compatibility, so it must be built with Xcode on macOS.

## 📊 Tremor Assistance Technology

The app implements the **1€ filter** (One Euro Filter), a sophisticated signal smoothing algorithm specifically designed for:
- Low latency response
- Adaptive filtering based on movement speed
- Minimal lag for slow movements
- Strong smoothing for fast movements with jitter

### Algorithm Details
- **Low-pass filter** with adaptive cutoff frequency
- **Beta parameter** controls lag vs. jitter trade-off
- **MinCutoff parameter** sets baseline smoothing strength
- Real-time parameter adjustment via UI slider

## 🔒 Privacy & Data

- All sensor data is processed locally on device
- Optional data logging for research purposes
- Users have full control over data export
- No network connectivity required

## 📄 License

Copyright © 2026. All rights reserved.

## 👤 Author

Shubh Singhal
- Email: sj.singhal01@gmail.com
- GitHub: [@Shubhsinghal31](https://github.com/Shubhsinghal31)

---

**Built for Swift Student Challenge 2026** 🎓
