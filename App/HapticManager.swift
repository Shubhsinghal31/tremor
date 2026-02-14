
import UIKit

@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        impactGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    func playImpact() {
        impactGenerator.impactOccurred()
    }
    
    func playSelection() {
        selectionGenerator.selectionChanged()
    }
    
    func playSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func playError() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    // Note: Pencil Haptics (Pro only) are usually system-handled for squeezes/taps.
    // But we can trigger device haptics as feedback for "Air" events which don't have physical resistance.
}
