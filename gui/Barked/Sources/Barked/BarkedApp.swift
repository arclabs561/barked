import SwiftUI

@main
struct BarkedApp: App {
    var body: some Scene {
        MenuBarExtra("Barked", systemImage: "shield.checkmark") {
            Text("Barked — Loading...")
            Divider()
            Button("Quit") { NSApplication.shared.terminate(nil) }
        }

        Window("Barked", id: "main") {
            Text("Barked GUI — coming soon")
                .frame(minWidth: 700, minHeight: 500)
        }
    }
}
