# Tremor - Apple Pencil Drawing App for Tremor Assistance

A sophisticated iPad app designed to help users with tremor draw more easily using Apple Pencil with advanced stabilization and tremor cancellation.

## 🎯 Features

### Core Drawing Features
- ✅ **Apple Pencil Support**: Full pressure sensitivity and tilt detection
- ✅ **Stroke Stabilization**: Advanced 1€ Filter algorithm for smooth, steady lines
- ✅ **Real-time Drawing**: Low-latency drawing with instant feedback
- ✅ **Tremor Cancellation**: Adjustable correction levels (0-100%)
- ✅ **Undo/Clear**: Full drawing management with undo stack
- ✅ **Haptic Feedback**: Tactile responses for drawing actions

### Two Modes

#### 1. Free Hand Mode
- Natural lined paper background
- Adjustable stabilization with live preview
- Color-coded strokes based on Apple Pencil roll angle
- Variable line width based on pressure
- Tool palette with brush controls

#### 2. Assessment Mode (Spiral Exercise)
- Guided spiral tracing for tremor assessment
- Real-time accuracy tracking
- Deviation measurement
- Tremor magnitude analysis
- Performance metrics and timing

### Advanced Features
- 📊 **Biometric Data Logging**: CSV export of drawing data with timestamps, pressure, angles
- 🎛️ **Settings Panel**: Fine-tune hover locking, squeeze sensitivity
- 📱 **Share Functionality**: Export drawing data for analysis
- ♿ **Accessibility**: Magnetic target locking for easier interaction

## 🛠️ Technical Implementation

### Architecture
- **Swift 6** with full concurrency support
- **SwiftUI** for modern, declarative UI
- **UIKit integration** for low-level pencil interaction
- **Combine** for reactive state management

### Key Components

#### PencilSensorManager
- Main state manager for pencil input
- Handles touch events, hover, and squeeze detection
- Manages drawing paths and undo stack
- Implements 1€ Filter for stabilization
- Thread-safe with `@MainActor` annotations

#### OneEuroFilter
- Industry-standard jitter reduction algorithm
- Adaptive cutoff frequency based on velocity
- Configurable parameters for different use cases
- Safe implementation without force unwrapping

#### BiometricLogger
- Real-time data logging during drawing
- CSV format for easy analysis
- Captures: position, pressure, altitude, azimuth, roll
- File export with share sheet integration

#### HapticManager
- Singleton pattern for consistent feedback
- Selection, impact, and notification haptics
- Pre-prepared generators for low latency

## 🚀 How to Use

### Requirements
- iPad running iOS 17.0 or later
- Apple Pencil (1st or 2nd generation)
- Xcode 15+ or Swift Playgrounds app

### Opening the Project

#### Option 1: Xcode (Recommended for Development)
1. Open Xcode
2. File → Open → Select the `tremor` folder
3. Wait for Swift Package Manager to resolve dependencies
4. Select iPad simulator or connected iPad
5. Click Run (⌘R)

#### Option 2: Swift Playgrounds (Recommended for Testing on iPad)
1. Transfer the entire `tremor` folder to iPad via AirDrop or iCloud
2. Open Swift Playgrounds app
3. Tap "Open" and select the project
4. Tap "Run My Code"

### Using the App

#### Free Hand Mode
1. Start drawing with Apple Pencil
2. Toggle stabilization with double-tap on Apple Pencil
3. Adjust "Correction Level" slider:
   - **0% (Natural)**: Raw input, no smoothing
   - **50% (Balanced)**: Moderate smoothing
   - **100% (Steady)**: Maximum stabilization
4. Use tool buttons:
   - Eraser: Clear entire canvas
   - Undo: Remove last stroke
   - Pencil: Active drawing tool
5. Tap share button to export drawing data

#### Assessment Mode
1. Switch to "Assessment" tab
2. Trace the displayed spiral path
3. Monitor real-time accuracy percentage
4. Adjust feedback intensity and wall resistance
5. Tap "Finish Exercise" to complete

## 🔧 Recent Fixes

### Critical Issues Resolved
1. **Swift 6 Concurrency**: Added `@MainActor` to touch handling methods
2. **Filter Reset**: Implemented proper filter state reset on new strokes
3. **Hover Gesture**: Removed invalid angle properties from UIHoverGestureRecognizer
4. **Force Unwrapping**: Replaced unsafe force unwraps with safe optional binding
5. **Thread Safety**: Ensured all UI updates happen on main actor

### Build Status
✅ **All compilation errors fixed**
✅ **All concurrency warnings resolved**
✅ **No runtime crash risks identified**
✅ **Ready for testing on device**

## 📝 Code Structure

```
tremor/
├── App/
│   ├── MyApp.swift              # App entry point
│   ├── ContentView.swift        # Tab view controller
│   ├── FreeDrawView.swift       # Free drawing interface
│   ├── SpiralExerciseView.swift # Assessment mode
│   ├── SettingsView.swift       # Settings panel
│   ├── PencilSensorManager.swift # Core pencil handling
│   ├── OneEuroFilter.swift      # Stabilization algorithm
│   ├── BiometricLogger.swift    # Data logging
│   ├── HapticManager.swift      # Haptic feedback
│   └── AirCanvas.swift          # Canvas rendering
└── Package.swift                # Swift Package manifest
```

## 🎨 UI Components

- **LinedPaperBackground**: Realistic lined paper with margin
- **DotGridBackground**: Subtle dot grid for assessment mode
- **ToolPalette**: Floating tool panel with controls
- **PencilTrackingView**: UIKit bridge for touch handling
- **ShareSheet**: System share sheet for data export

## 🧪 Testing Checklist

- [ ] Test on actual iPad with Apple Pencil
- [ ] Verify pressure sensitivity works
- [ ] Test stabilization at different correction levels
- [ ] Verify double-tap to toggle stabilization
- [ ] Test undo/clear functionality
- [ ] Verify haptic feedback triggers
- [ ] Test data logging and export
- [ ] Verify spiral tracing accuracy
- [ ] Test all settings adjustments
- [ ] Verify hover cursor behavior

## 🎓 Swift Student Challenge Ready

This app demonstrates:
- ✅ Advanced Swift 6 features (concurrency, actors)
- ✅ UIKit + SwiftUI integration
- ✅ Complex gesture handling
- ✅ Real-time data processing
- ✅ Accessibility considerations
- ✅ Professional UI/UX design
- ✅ Scientific algorithm implementation (1€ Filter)
- ✅ Data export and sharing

## 📚 Algorithm Reference

The 1€ Filter implementation is based on:
*"1€ Filter: A Simple Speed-based Low-pass Filter for Noisy Input"*
by Géry Casiez, Nicolas Roussel, and Daniel Vogel (CHI 2012)

## 📄 License

This project is designed for educational purposes as part of the Swift Student Challenge.

## 🤝 Contributing

This is a student project. For questions or suggestions, please open an issue on GitHub.

---

**Built with ❤️ for the Swift Student Challenge 2026**
