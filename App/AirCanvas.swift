
import SwiftUI

struct AirCanvas: View {
    @ObservedObject var manager: PencilSensorManager
    
    var body: some View {
        ZStack {
            // Drawing Layer
            Canvas { context, size in
                for path in manager.paths {
                    draw(path: path, in: &context)
                }
                if !manager.currentPath.isEmpty {
                    draw(path: manager.currentPath, in: &context)
                }
            }
            .allowsHitTesting(false)
            
            // Cursor / Hover Indicator
            if let point = manager.currentHoverPoint {
                Circle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 20, height: 20)
                    .position(point)
                    .shadow(radius: 5)
                
                // Show orientation stick
                Path { path in
                    path.move(to: point)
                    let len: CGFloat = 40
                    let endX = point.x + len * cos(manager.azimuth)
                    let endY = point.y + len * sin(manager.azimuth)
                    path.addLine(to: CGPoint(x: endX, y: endY))
                }
                .stroke(Color.red, lineWidth: 2)
            }
        }
        // Logic moved to Manager (Touch-based drawing)
        // This view is now purely for rendering.
    }
    
    func draw(path: [PointData], in context: inout GraphicsContext) {
        // Draw segments to support variable color/width
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
