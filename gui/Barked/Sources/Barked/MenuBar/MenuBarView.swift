import SwiftUI

struct MenuBarView: View {
    @StateObject private var runner = ScriptRunner()
    @Environment(\.openWindow) private var openWindow
    private let configReader = ConfigReader()

    var body: some View {
        Button("Quick Clean") {
            Task { await runner.run(["--clean", "--force"]) }
        }
        .disabled(runner.isRunning)

        if runner.isRunning {
            Text("Cleaning...").foregroundStyle(.secondary)
        }

        Divider()

        Button("Open Barked...") {
            openWindow(id: "main")
            NSApplication.shared.activate(ignoringOtherApps: true)
        }

        Divider()

        Text(configReader.scheduleDisplayText)
            .foregroundStyle(.secondary)

        Button("Check for Updates...") {
            Task {
                await runner.run(["--update-app"])
                if runner.output.contains("__BARKED_RELAUNCH__") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let proc = Process()
                        proc.executableURL = URL(fileURLWithPath: "/usr/bin/open")
                        proc.arguments = ["-n", "/Applications/Barked.app"]
                        try? proc.run()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            NSApplication.shared.terminate(nil)
                        }
                    }
                }
            }
        }
        .disabled(runner.isRunning)

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }

}
