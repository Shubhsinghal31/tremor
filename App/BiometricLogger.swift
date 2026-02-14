
import Foundation
import UIKit
import SwiftUI

struct BiometricDataPoint: Codable {
    let timestamp: TimeInterval
    let x: Double
    let y: Double
    let pressure: Double
    let altitude: Double
    let azimuth: Double
    let roll: Double
    
    func toCSV() -> String {
        return String(format: "%.5f,%.2f,%.2f,%.4f,%.4f,%.4f,%.4f", 
                      timestamp, x, y, pressure, altitude, azimuth, roll)
    }
    
    static func csvHeader() -> String {
        return "Timestamp,X,Y,Pressure,Altitude,Azimuth,Roll"
    }
}

final class BiometricLogger: ObservableObject, @unchecked Sendable {
    @Published var isLogging: Bool = false
    private var logBuffer: [String] = []
    private var startTime: TimeInterval = 0
    private let queue = DispatchQueue(label: "com.airwriting.logger", qos: .utility)
    
    // File Management
    var currentLogURL: URL?
    
    func startSession() {
        isLogging = true
        startTime = CACurrentMediaTime()
        logBuffer.removeAll()
        logBuffer.append(BiometricDataPoint.csvHeader())
    }
    
    func stopSession() {
        isLogging = false
        saveLogFile()
    }
    
    func log(_ point: CGPoint, pressure: CGFloat, altitude: CGFloat, azimuth: CGFloat, roll: CGFloat) {
        guard isLogging else { return }
        
        // Record relative time for easier analysis
        let now = CACurrentMediaTime() - startTime
        
        let data = BiometricDataPoint(
            timestamp: now,
            x: Double(point.x),
            y: Double(point.y),
            pressure: Double(pressure),
            altitude: Double(altitude),
            azimuth: Double(azimuth),
            roll: Double(roll)
        )
        
        queue.async {
            self.logBuffer.append(data.toCSV())
        }
    }
    
    private func saveLogFile() {
        queue.async {
            let csvString = self.logBuffer.joined(separator: "\n")
            
            let fileName = "TremorLog_\(Date().ISO8601Format()).csv"
            let tempParams = FileManager.default.temporaryDirectory
            let fileURL = tempParams.appendingPathComponent(fileName)
            
            do {
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                DispatchQueue.main.async {
                    self.currentLogURL = fileURL
                }
                print("Log saved to: \(fileURL.path)")
            } catch {
                print("Failed to save log: \(error)")
            }
        }
    }
}

// Helper for Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
