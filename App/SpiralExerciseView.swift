// MARK: - Pixel-Perfect Spiral Task View
import SwiftUI
import Foundation

struct SpiralExerciseView: View {
    @ObservedObject var manager: PencilSensorManager
    @Environment(\.dismiss) var dismiss
    
    // Game State
    @State private var accuracy: Double = 94.0 // Mock start for visual
    @State private var deviation: CGFloat = 1.2
    @State private var isTracing = false
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 45 // Mock for visual
    @State private var showSettings = false
    
    // UI State
    @State private var feedbackIntensity: Double = 0.6
    @State private var wallResistance: Bool = true
    
    // Custom Colors
    let bgBlue = Color(red: 0.95, green: 0.96, blue: 0.99)
    let cardShadow = Color.black.opacity(0.05)
    
    var body: some View {
        ZStack {
            // 1. Background (Dot Grid Pattern)
            bgBlue.ignoresSafeArea()
            DotGridBackground().opacity(0.3)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.left")
                            Text("Exercises")
                        }
                        .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("Spiral Coordination Task")
                        .font(.headline)
                    Spacer()
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape") // "gear" or "gearshape"
                    }
                    .foregroundColor(.gray)
                    
                    Button(action: {}) {
                        Image(systemName: "questionmark.circle")
                    }
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .sheet(isPresented: $showSettings) {
                    SettingsView(manager: manager)
                }
                
                // Drawing Area (Card)
                ZStack {
                    // Card Background
                    Color.white
                        .cornerRadius(24)
                        .shadow(color: cardShadow, radius: 10, y: 5)
                        .padding(20)
                    
                    // Internal Grid (Light)
                    DotGridBackground().opacity(0.15)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(20)
                    
                    // Status Badge (Top Right)
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Deviation").font(.caption).foregroundColor(.gray)
                                    Spacer()
                                    Text("1.2mm").font(.caption).bold().foregroundColor(.red)
                                }
                                HStack {
                                    Text("Tremor").font(.caption).foregroundColor(.gray)
                                    Spacer()
                                    Text("Low").font(.caption).bold().foregroundColor(.green)
                                }
                            }
                            .frame(width: 120)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.05), radius: 2)
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Circle().fill(Color.green).frame(width: 8, height: 8)
                                Text("Haptics: Adaptive").font(.caption).bold().foregroundColor(.green)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(20)
                        }
                        .padding(40) // Inside card padding
                        Spacer()
                    }
                    
                    // The Spiral
                    SpiralShape()
                        .stroke(Color.blue.opacity(0.1), style: StrokeStyle(lineWidth: 40, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .padding(20)
                    
                    SpiralShape()
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .padding(20)
                        .opacity(0.3)
                    
                    // User Path Render
                     Canvas { context, size in
                        // Scaling would be needed here to match the spiral frame
                        // For functionality, we keep the existing logic but overlay it
                        for stroke in manager.paths {
                            drawStroke(stroke, context: &context)
                        }
                        drawStroke(manager.currentPath, context: &context)
                    }
                    .frame(width: 300, height: 300) // Constrain drawing check
                    .overlay(PencilTrackingView(manager: manager))
                    
                    // Floating Cursor/Label (Mock "Tracing...")
                    VStack {
                        Spacer()
                        Text("Tracing...")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .offset(y: -60)
                    }
                }
                
                // Bottom Control Panel
                VStack(spacing: 20) {
                    // Accuracy & Time
                    HStack {
                        VStack(alignment: .leading) {
                            Text("ACCURACY").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                            Text("\(Int(accuracy))%").font(.system(size: 36, weight: .bold)).foregroundColor(.blue)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Time Elapsed").font(.caption).foregroundColor(.gray)
                            Text("00:45").font(.title3).fontWeight(.bold).foregroundColor(.black)
                        }
                    }
                    
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.gray.opacity(0.2)).frame(height: 8)
                            Capsule().fill(Color.blue).frame(width: geo.size.width * (accuracy / 100), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    // Sliders Row
                    HStack(alignment: .bottom, spacing: 30) {
                        // Feedback Intensity
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Feedback Intensity").font(.caption).fontWeight(.bold).foregroundColor(.black)
                                Spacer()
                                Text("60%").font(.caption).bold().foregroundColor(.blue)
                            }
                            
                            Slider(value: $feedbackIntensity, in: 0...1)
                                .tint(.blue)
                            
                            HStack {
                                Text("Soft").font(.caption).foregroundColor(.gray)
                                Spacer()
                                Text("Firm").font(.caption).foregroundColor(.gray)
                                Spacer()
                                Text("Rigid").font(.caption).foregroundColor(.gray)
                            }
                        }
                        
                        Divider().frame(height: 40)
                        
                        // Wall Resistance Toggle
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Wall Resistance").font(.caption).fontWeight(.bold).foregroundColor(.black)
                            Toggle("On", isOn: $wallResistance)
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                                .labelsHidden()
                            Text("On").font(.caption).foregroundColor(.green)
                        }
                    }
                    
                    // Bottom Buttons
                    HStack(spacing: 16) {
                        // Tool Toggles (Round)
                        HStack(spacing: 12) {
                            CircleButton(icon: "eraser.fill", isSelected: false)
                            CircleButton(icon: "arrow.uturn.backward", isSelected: false) { manager.undo() }
                            CircleButton(icon: "pencil", isSelected: true, color: .blue)
                            CircleButton(icon: "arrow.uturn.forward", isSelected: false)
                        }
                        
                        Spacer()
                        
                        // Finish Button
                        Button(action: { finishExercise() }) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Finish Exercise")
                            }
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.blue, lineWidth: 1.5))
                            .cornerRadius(30)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
            }
            .background(Color(uiColor: .systemGroupedBackground)) // Ensure bottom safe area is covered
        }
        .onReceive(manager.$currentPath) { _ in calculateAccuracy() }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if isTracing { elapsedTime += 1 }
        }
    }
    
    func drawStroke(_ points: [PointData], context: inout GraphicsContext) {
        guard points.count > 1 else { return }
        var path = Path()
        path.move(to: points[0].point)
        for i in 1..<points.count {
            path.addLine(to: points[i].point)
        }
        context.stroke(path, with: .color(.blue), lineWidth: 4)
    }
    
    // Simple Deviation Calculation
    func calculateAccuracy() {
        if !manager.currentPath.isEmpty {
            deviation = CGFloat.random(in: 0.5...2.5) // Mock logic
            accuracy = max(0, 100 - (Double(deviation) * 5))
        }
    }
    
    func finishExercise() {
        isTracing = false
        manager.paths.removeAll()
    }
}

// Simple Spiral Shape for UI
struct SpiralShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var angle: CGFloat = 0
        var radius: CGFloat = 10
        let maxRadius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        
        // Approx spiral
        while radius < maxRadius {
            angle += 0.1
            radius += 0.5
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}

struct CircleButton: View {
    let icon: String
    var isSelected: Bool
    var color: Color = .gray
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(width: 44, height: 44)
                .background(isSelected ? color : Color.gray.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

struct MetricView: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label).font(.caption).foregroundColor(.secondary)
            Text(value).font(.title2).bold().foregroundColor(color)
        }
    }
}

struct AngleGauge: View {
    let value: Double
    let label: String
    let range: ClosedRange<Double>
    
    var body: some View {
        VStack {
            Text(label).font(.caption)
            Gauge(value: min(max(value, range.lowerBound), range.upperBound), in: range) {
                Text("\(Int(value))°")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Gradient(colors: [.red, .green, .red]))
        }
        .padding(5)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}
