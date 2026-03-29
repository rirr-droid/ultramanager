import SwiftUI
import SwiftData

@main
struct UltraManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Runner.self])
    }
}
