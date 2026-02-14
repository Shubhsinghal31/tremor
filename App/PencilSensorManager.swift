
import SwiftUI
import UIKit
import Combine


struct PointData: Identifiable {
    let id = UUID()
    let point: CGPoint
    let color: Color
    let width: CGFloat
}

@MainActor
class PencilSensorManager: NSObject, ObservableObject {
    @Published var paths: [[PointData]] = []
    @Published var currentPath: [PointData] = []
    
    // Undo/Redo Stacks
    private var undoStack: [[[PointData]]] = []
    
    @Published var currentHoverPoint: CGPoint?
    
    // State
    @Published var isStabilizationEnabled: Bool = true
    @Published var isSqueezing: Bool = false // Just sensor state now
    
    // Sensor Data (Restored)
    @Published var altitude: CGFloat = 0.0
    @Published var azimuth: CGFloat = 0.0
    @Published var roll: CGFloat = 0.0
    @Published var pressure: CGFloat = 0.0
    
    // Logger
    let logger = BiometricLogger()
    
    // Magnetic Targets (Frames in global coordinate space) - Still useful for UI snapping
    var magneticTargets: [CGRect] = []
    
    // Settings / Configuration
    @Published var hoverLockingStrength: Double = 0.5 // 0.0 to 1.0
    @Published var squeezeSensitivity: Double = 0.5 // 0.0 (Light) to 1.0 (Firm)
    @Published var isSqueezeHapticEnabled: Bool = true
    
    // UI Binding for "Correction Level" (0.0 to 1.0)
    // Maps to 1€ filter parameters (beta/mincutoff)
    @Published var correctionLevel: Double = 0.85 {
        didSet {
            updateFilterParameters()
        }
    }
    
    // Live Metrics for Settings
    @Published var lastTremorMagnitude: CGFloat = 0.0
    @Published var lastSqueezeForce: CGFloat = 0.0
    
    // For visualization
    @Published var sensorLog: String = "Ready to Write"
    
    // Pencil Interaction
    private var cleanUp: (() -> Void)?
    
    // Smoothing Filters
    // Low cutoff for stabilization
    private var pointFilter = OneEuroPointFilter(mincutoff: 1.0, beta: 0.005, dcutoff: 1.0)
    
    override init() {
        super.init()
        updateFilterParameters()
    }
    
    private func updateFilterParameters() {
        // High correction = Low Beta (Smoother, more lag)
        // Low correction = High Beta (Responsive, more jitter)
        // Range: Beta 0.1 (Fast) -> 0.001 (Slow/Smooth)
        
        let minBeta = 0.001
        let maxBeta = 0.1
        
        // Invert level: 1.0 (High Correction) -> minBeta
        let newBeta = maxBeta - (correctionLevel * (maxBeta - minBeta))
        
        // MinCutoff also affects lag vs jitter at low speeds
        // 1.0 Hz (Fast) -> 0.05 Hz (Slow)
        let newMinCutoff = 1.0 - (correctionLevel * 0.95)
        
        pointFilter.updateParams(mincutoff: newMinCutoff, beta: newBeta)
    }
    
    // UIPencilInteraction is handled by the View (PencilTrackingView)
    
    // MARK: - Drawing Lifecycle (Called by Views)
    
    func startStroke(at location: CGPoint, pressure: CGFloat, roll: CGFloat) {
        // Reset filter state on new stroke to avoid jumping from previous lift
        // ideally we re-init or use a gap, but 1€ filter usually adapts quick.
        // For best results, we might want to 'reset' the filter here if exposed.
        
        let point = isStabilizationEnabled ? pointFilter.filter(location) : location
        addPoint(point, pressure: pressure, roll: roll)
        
        HapticManager.shared.playSelection() // Feedback on touch down
        logger.startSession() // Start logging on stroke
    }
    
    func moveStroke(to location: CGPoint, pressure: CGFloat, roll: CGFloat) {
        let point = isStabilizationEnabled ? pointFilter.filter(location) : location
        addPoint(point, pressure: pressure, roll: roll)
        
        // Log
        logger.log(point, pressure: pressure, altitude: altitude, azimuth: azimuth, roll: roll)
    }
    
    func endStroke() {
        if !currentPath.isEmpty {
            undoStack.append(paths) // Save state before adding new path
            paths.append(currentPath)
            currentPath = []
            // Clear redo stack on new action
            // redoStack.removeAll() (If implemented)
        }
        logger.stopSession()
    }
    
    func undo() {
        guard !paths.isEmpty else { return }
        // For simple path undo, just remove last
        // If we want full state undo:
        if let previousState = undoStack.popLast() {
             paths = previousState
        } else if !paths.isEmpty {
             // Fallback if stack empty but paths exist (initial)
             paths.removeLast()
        }
    }
    
    func clearCanvas() {
        undoStack.append(paths)
        paths.removeAll()
    }
    
    private func addPoint(_ point: CGPoint, pressure: CGFloat, roll: CGFloat) {
        let width = max(2, (pressure * 10) + 2)
        // Hue from Roll
        let normalizedRoll = (roll + .pi) / (2 * .pi)
        let color = Color(hue: normalizedRoll, saturation: 1.0, brightness: 1.0)
        
        let data = PointData(point: point, color: color, width: width)
        currentPath.append(data)
        
        // Update current point for UI cursor if needed (though finger/pencil is there)
        currentHoverPoint = point
    }
    
    // MARK: - Sensor Updates
    
    func update(from touch: UITouch, in view: UIView) {
        // This is called by touchesMoved/Began
        // We extract data and call stroke methods
        // BUT, touchesBegan/Moved in the View should map to start/moveStroke.
        // We'll update sensor properties here.
        
        altitude = touch.altitudeAngle
        azimuth = touch.azimuthAngle(in: view)
        
        if #available(iOS 17.5, *) {
            roll = touch.rollAngle
        }
        
        pressure = touch.force
        
        updateLog()
    }
    
    @MainActor func updateHover(from gesture: UIHoverGestureRecognizer, in view: UIView) {
        // Hover is now just for Cursor / Magnetic Targets (Accessibility)
        // NO DRAWING in hover.
        
        switch gesture.state {
        case .began, .changed:
            let rawLocation = gesture.location(in: view)
            
            // Filter cursor too? Yes, consistent feel.
            var filteredPoint = isStabilizationEnabled ? pointFilter.filter(rawLocation) : rawLocation
            
            // Magnetic Snapping
            for target in magneticTargets {
                // Expanded hit area dependent on setting
                // Low(0.0) -> 0 padding, High(1.0) -> 60 padding
                let magnetism = hoverLockingStrength * 60
                let detectionFrame = target.insetBy(dx: -magnetism, dy: -magnetism)
                
                if detectionFrame.contains(filteredPoint) {
                    filteredPoint = CGPoint(x: target.midX, y: target.midY)
                    HapticManager.shared.playSelection()
                    break
                }
            }
            // Apply tremor cancellation
        let filtered = pointFilter.filter(rawLocation)
        currentHoverPoint = filtered
        
        // Calculate Metrics
        let dx = rawLocation.x - filtered.x
        let dy = rawLocation.y - filtered.y
        lastTremorMagnitude = sqrt(dx*dx + dy*dy)
        // The hover gesture doesn't provide `touch.force`, so `lastSqueezeForce` cannot be updated here directly from `touch.force`.
        // If `lastSqueezeForce` is meant to reflect actual squeeze, it should be updated via `handleSqueeze` or `update(from: UITouch)`.
        // For now, I'll comment out the line as `gesture` does not have a `force` property.
        // lastSqueezeForce = touch.force * 1000 // approx grams?
        
        // Angles        // Update Angles
            altitude = gesture.altitudeAngle
            azimuth = gesture.azimuthAngle(in: view)
             if #available(iOS 17.5, *) { roll = gesture.rollAngle }
            
            updateLog()
            
        case .ended, .cancelled:
            currentHoverPoint = nil
            
        default:
            break
        }
    }
    
    func handleSqueeze(_ squeezing: Bool) {
        isSqueezing = squeezing
        if squeezing {
            // Feature: Squeeze to clear current stroke or Undo?
            // For now, let's just log it.
        }
        updateLog()
    }
    
    private func updateLog() {
        let rollDeg = roll * 180 / .pi
        let altDeg = altitude * 180 / .pi
        
        sensorLog = """
        Stabilization: \(isStabilizationEnabled ? "ON" : "OFF")
        Altitude: \(String(format: "%.1f°", altDeg))
        Roll: \(String(format: "%.1f°", rollDeg))
        Squeeze: \(isSqueezing ? "YES" : "NO")
        """
    }
}

extension PencilSensorManager: UIPencilInteractionDelegate {
    func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
        // Double tap toggle stabilization?
        isStabilizationEnabled.toggle()
        if isStabilizationEnabled {
             HapticManager.shared.playSuccess()
        } else {
             HapticManager.shared.playImpact()
        }
        updateLog()
    }
}

// MARK: - Bridge for SwiftUI
// Updated to call start/move/end Stroke
class PredictionInputView: UIView {
    weak var manager: PencilSensorManager?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let hover = UIHoverGestureRecognizer(target: self, action: #selector(onHover(_:)))
        self.addGestureRecognizer(hover)
        self.isMultipleTouchEnabled = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc func onHover(_ gesture: UIHoverGestureRecognizer) {
        manager?.updateHover(from: gesture, in: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touch.type == .pencil else { return }
        manager?.update(from: touch, in: self)
        
        let loc = touch.location(in: self)
        var r: CGFloat = 0
        if #available(iOS 17.5, *) { r = touch.rollAngle }
        
        manager?.startStroke(at: loc, pressure: touch.force, roll: r)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touch.type == .pencil else { return }
        manager?.update(from: touch, in: self)
        
        let loc = touch.location(in: self)
        var r: CGFloat = 0
        if #available(iOS 17.5, *) { r = touch.rollAngle }
        
        manager?.moveStroke(to: loc, pressure: touch.force, roll: r)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touch.type == .pencil else { return }
        manager?.endStroke()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        manager?.endStroke()
    }
}

// MARK: - Bridge for SwiftUI
struct PencilTrackingView: UIViewRepresentable {
    @ObservedObject var manager: PencilSensorManager
    
    func makeUIView(context: Context) -> PredictionInputView {
        let view = PredictionInputView()
        view.manager = manager
        
        let interaction = UIPencilInteraction()
        interaction.delegate = manager
        view.addInteraction(interaction)
        
        return view
    }
    
    func updateUIView(_ uiView: PredictionInputView, context: Context) {
        // Updates if needed
    }
}


