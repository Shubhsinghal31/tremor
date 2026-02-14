// MARK: - Pixel-Perfect Settings View
import SwiftUI

struct SettingsView: View {
    @ObservedObject var manager: PencilSensorManager
    @Environment(\.dismiss) var dismiss
    
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
                            Image(systemName: "chevron.left")
                            Text("Settings")
                        }
                        .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("Sensory Interaction Cues")
                        .font(.headline)
                        .padding(.leading, -20) // Center adjustment
                    Spacer()
                    Button("Reset") {
                        manager.hoverLockingStrength = 0.5
                        manager.squeezeSensitivity = 0.5
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // ROW 1: Live Metrics & Visualization
                        HStack(alignment: .top, spacing: 20) {
                            // Live Metrics Card
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundColor(.blue)
                                    Text("LIVE METRICS")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Tremor Cancelled").font(.subheadline).foregroundColor(.gray)
                                        Spacer()
                                        Text("\(Int(manager.lastTremorMagnitude * 10))mm").bold().foregroundColor(.green)
                                    }
                                    Divider().padding(.vertical, 8)
                                    HStack {
                                        Text("Squeeze Force").font(.subheadline).foregroundColor(.gray)
                                        Spacer()
                                        Text("\(Int(manager.lastSqueezeForce * 1000))g").bold().foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: cardShadow, radius: 10, y: 5)
                            .frame(width: 200) // Fixed width like mockup
                            
                            // Visualization (Center)
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 140, height: 140)
                                
                                // Tremor Ring (Green)
                                Circle()
                                    .trim(from: 0, to: 0.75) // Dynamic in real app
                                    .stroke(Color.green, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(-90))
                                
                                // Center Lock Icon
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 50, height: 50)
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.white)
                                
                                // Squeeze Tooltip
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.up.and.down")
                                    Text("Squeeze to Click")
                                }
                                .font(.caption).bold()
                                .padding(8)
                                .padding(.horizontal, 4)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .offset(x: 90) // Floating tooltip
                            }
                        }
                        .padding(.top, 20)
                        
                        // ROW 2: Hover Target Locking
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "viewfinder")
                                    .foregroundColor(.blue)
                                Text("Hover Target Locking")
                                    .font(.headline)
                                Spacer()
                                Text("High")
                                    .font(.caption).bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)
                            }
                            
                            Text("Adjust how aggressively the cursor snaps to interactive elements.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            VStack(spacing: 8) {
                                Slider(value: $manager.hoverLockingStrength, in: 0...1)
                                    .tint(.blue)
                                HStack {
                                    Text("Natural").font(.caption).foregroundColor(.gray)
                                    Spacer()
                                    Text("Balanced").font(.caption).foregroundColor(.gray)
                                    Spacer()
                                    Text("Strong Magnetism").font(.caption).foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: cardShadow, radius: 10, y: 5)
                        
                        // ROW 3: Squeeze for Precision
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                                    .foregroundColor(.blue)
                                Text("Squeeze for Precision")
                                    .font(.headline)
                                Spacer()
                                Toggle("Haptic", isOn: $manager.isSqueezeHapticEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: .green))
                                    .labelsHidden()
                                Text("Haptic").font(.caption).foregroundColor(.gray)
                            }
                            
                            Text("Set the force required to trigger a selection.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            VStack(spacing: 8) {
                                HStack(spacing: 12) {
                                    // Segmented Buttons (Custom)
                                    SensitivitySegment(title: "", isSelected: manager.squeezeSensitivity == 0.2) { manager.squeezeSensitivity = 0.2 }
                                    SensitivitySegment(title: "", isSelected: manager.squeezeSensitivity == 0.5) { manager.squeezeSensitivity = 0.5 }
                                    SensitivitySegment(title: "", isSelected: manager.squeezeSensitivity == 0.8) { manager.squeezeSensitivity = 0.8 }
                                    Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 48).cornerRadius(8) // Placeholder for mock
                                    Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 48).cornerRadius(8)
                                }
                                .frame(height: 50)
                                
                                HStack {
                                    Text("Light Touch").font(.caption).foregroundColor(.gray)
                                    Spacer()
                                    Text("Firm Squeeze").font(.caption).foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: cardShadow, radius: 10, y: 5)
                        
                        // SAVE BUTTON
                        Button(action: { dismiss() }) {
                            Text("Save Configuration")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        .padding(.top, 10)
                        
                    }
                    .padding(24)
                }
            }
        }
    }
}

// Helper Components
struct DotGridBackground: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 30
            let rows = Int(size.height / spacing)
            let cols = Int(size.width / spacing)
            
            for r in 0...rows {
                for c in 0...cols {
                    let x = CGFloat(c) * spacing
                    let y = CGFloat(r) * spacing
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)), with: .color(.gray.opacity(0.3)))
                }
            }
        }
    }
}

struct SensitivitySegment: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue : Color.blue.opacity(0.8)) // Mock gradient
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
