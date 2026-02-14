// MARK: - Pixel-Perfect Free Draw View
import SwiftUI

struct FreeDrawView: View {
    @ObservedObject var manager: PencilSensorManager
    @State private var showShareSheet = false
    
    // Custom Colors
    let paperColor = Color(red: 0.99, green: 0.98, blue: 0.96)
    
    var body: some View {
        ZStack {
            // 1. Background (Lined Paper)
            paperColor.ignoresSafeArea()
            LinedPaperBackground()
            
            // 2. Drawing Layer
            Canvas { context, size in
                for path in manager.paths {
                    drawPath(path, context: &context)
                }
                drawPath(manager.currentPath, context: &context)
            }
            .overlay(PencilTrackingView(manager: manager))
            
            // 3. Floating UI Elements
            VStack {
                // Top Header (Custom)
                HStack {
                    // Placeholder for back button if needed, or just layout spacing
                    Button(action: {}) {
                         HStack {
                            Image(systemName: "chevron.left")
                            Text("Gallery")
                        }
                        .foregroundColor(.blue)
                    }
                    .opacity(0) // Hidden for now as it is the root view in TabView
                    
                    Spacer()
                    
                    Text("New Document")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color.white.opacity(0.8))
                
                // Stabilizer Pill (Floating)
                HStack {
                     // Status Indicator
                     Circle()
                        .fill(manager.isStabilizationEnabled ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text(manager.isStabilizationEnabled ? "Stabilizer Active" : "Raw Input")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Toggle("", isOn: $manager.isStabilizationEnabled)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
                .padding(.top, 10)
                .frame(maxWidth: 220) // Compact pill
                
                Spacer()
                
                // Bottom Tool Palette
                ToolPalette(manager: manager)
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = manager.logger.currentLogURL {
                ShareSheet(items: [url])
            } else {
                Text("No Log Data Available")
            }
        }
    }
    
    func drawPath(_ path: [PointData], context: inout GraphicsContext) {
        guard path.count > 1 else { return }
        for i in 0..<path.count-1 {
            let p1 = path[i]
            let p2 = path[i+1]
            var p = Path()
            p.move(to: p1.point)
            p.addLine(to: p2.point)
            context.stroke(p, with: .color(p1.color), lineWidth: p1.width)
        }
    }
}

struct LinedPaperBackground: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 40
            let lines = Int(size.height / spacing)
            
            var path = Path()
            for i in 1..<lines {
                let y = CGFloat(i) * spacing
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(path, with: .color(Color.blue.opacity(0.1)), lineWidth: 1)
            
            // Margin Line
            var margin = Path()
            margin.move(to: CGPoint(x: 80, y: 0))
            margin.addLine(to: CGPoint(x: 80, y: size.height))
            context.stroke(margin, with: .color(Color.red.opacity(0.1)), lineWidth: 1)
        }
        .ignoresSafeArea()
    }
}

struct ToolPalette: View {
    @ObservedObject var manager: PencilSensorManager
    
    var body: some View {
         VStack(spacing: 16) {
             // Slider Row
             VStack(alignment: .leading, spacing: 4) {
                 HStack {
                     Text("Correction Level")
                         .font(.caption)
                         .foregroundColor(.gray)
                     Spacer()
                     Text("\(Int(manager.correctionLevel * 100))%")
                         .font(.caption)
                         .bold()
                         .foregroundColor(.blue)
                 }
                 
                 Slider(value: $manager.correctionLevel, in: 0...1)
                     .tint(.blue)
                 
                 HStack {
                     Text("Natural").font(.caption2).foregroundColor(.gray)
                     Spacer()
                     Text("Steady").font(.caption2).foregroundColor(.gray)
                 }
             }
             .padding(.horizontal)
             
             // Tools Row
             HStack(spacing: 20) {
                 ToolButton(icon: "eraser.fill", isSelected: false) {
                     manager.clearCanvas()
                 }
                 
                 ToolButton(icon: "arrow.uturn.backward", isSelected: false) {
                     manager.undo()
                 }
                 
                 ToolButton(icon: "pencil.tip", isSelected: true, color: .blue) {}
                 
                 ToolButton(icon: "arrow.uturn.forward", isSelected: false, color: .gray.opacity(0.3)) {} // Redo Placeholder
                 
                 // Color Picker Placeholder
                 Circle()
                     .fill(Color.black)
                     .frame(width: 24, height: 24)
                     .overlay(Circle().stroke(Color.gray, lineWidth: 1))
             }
         }
         .padding(20)
         .background(Color.white)
         .cornerRadius(24)
         .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
         .padding(.horizontal, 40)
    }
}

struct ToolButton: View {
    let icon: String
    var isSelected: Bool
    var color: Color = .black
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isSelected ? .white : color)
                .frame(width: 50, height: 50)
                .background(isSelected ? Color.blue : Color(uiColor: .systemGray6))
                .clipShape(Circle())
        }
    }
}
