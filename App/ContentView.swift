
import SwiftUI

struct ContentView: View {
    @StateObject private var manager = PencilSensorManager()
    
    var body: some View {
        TabView {
            // Mode 1: Free Write (SteadyHand)
            FreeDrawView(manager: manager)
                .tabItem {
                    Label("Free Hand", systemImage: "pencil.and.scribble")
                }
            
            // Mode 2: Assessment & Analytics
            TremorAnalyticsView(manager: manager)
                .tabItem {
                    Label("Analytics", systemImage: "chart.xyaxis.line")
                }
        }
    }
}




