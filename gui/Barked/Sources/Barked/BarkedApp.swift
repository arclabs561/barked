import SwiftUI
import AppKit

@main
struct BarkedApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(nsImage: Self.menuBarIconGreen)
        }

        Window("Barked", id: "main") {
            ContentView()
                .frame(minWidth: 700, minHeight: 500)
                .onAppear {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
        }
        .defaultPosition(.center)
    }

    /// Green shield — normal state
    static let menuBarIconGreen: NSImage = makeShieldIcon(
        fill: NSColor(red: 0.322, green: 0.718, blue: 0.533, alpha: 1), // #52b788
        mark: .none
    )

    /// Red shield with X — alert state
    static let menuBarIconRed: NSImage = makeShieldIcon(
        fill: NSColor(red: 0.906, green: 0.298, blue: 0.235, alpha: 1), // #e74c3c
        mark: .xmark
    )

    enum ShieldMark { case none, checkmark, xmark }

    private static func makeShieldIcon(fill: NSColor, mark: ShieldMark) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: true) { rect in
            let w = rect.width
            let h = rect.height
            let cx = w / 2

            // Shield shape
            let shield = NSBezierPath()
            shield.move(to: NSPoint(x: cx, y: h - 0.5))
            shield.line(to: NSPoint(x: w * 0.12, y: h * 0.35))
            shield.line(to: NSPoint(x: w * 0.12, y: h * 0.18))
            shield.curve(to: NSPoint(x: cx, y: 0.5),
                         controlPoint1: NSPoint(x: w * 0.12, y: h * 0.05),
                         controlPoint2: NSPoint(x: w * 0.3, y: 0.5))
            shield.curve(to: NSPoint(x: w * 0.88, y: h * 0.18),
                         controlPoint1: NSPoint(x: w * 0.7, y: 0.5),
                         controlPoint2: NSPoint(x: w * 0.88, y: h * 0.05))
            shield.line(to: NSPoint(x: w * 0.88, y: h * 0.35))
            shield.close()

            fill.setFill()
            shield.fill()

            // White mark
            if mark != .none {
                NSColor.white.setStroke()
                let stroke = NSBezierPath()
                stroke.lineWidth = 1.8
                stroke.lineCapStyle = .round
                stroke.lineJoinStyle = .round

                switch mark {
                case .checkmark:
                    stroke.move(to: NSPoint(x: w * 0.3, y: h * 0.48))
                    stroke.line(to: NSPoint(x: w * 0.44, y: h * 0.62))
                    stroke.line(to: NSPoint(x: w * 0.7, y: h * 0.32))
                case .xmark:
                    stroke.move(to: NSPoint(x: w * 0.32, y: h * 0.3))
                    stroke.line(to: NSPoint(x: w * 0.68, y: h * 0.6))
                    stroke.move(to: NSPoint(x: w * 0.68, y: h * 0.3))
                    stroke.line(to: NSPoint(x: w * 0.32, y: h * 0.6))
                case .none:
                    break
                }

                stroke.stroke()
            }
            return true
        }
        image.isTemplate = false
        return image
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let window = NSApplication.shared.windows.first(where: { $0.title == "Barked" }) {
                window.makeKeyAndOrderFront(nil)
            }
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
}
