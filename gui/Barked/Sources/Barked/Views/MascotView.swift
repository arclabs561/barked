import SwiftUI

/// Pixel art mascot rendered natively in SwiftUI.
/// Each pixel maps to `pixelSize x pixelSize` points.
enum MascotMood {
    case idle
    case cheer
    case windy
}

struct MascotView: View {
    var mood: MascotMood = .idle
    var pixelSize: CGFloat = 4

    // Animation state
    @State private var bounceOffset: CGFloat = 0
    @State private var showSparkles = false
    @State private var pupilOffsetX: CGFloat = 0
    @State private var pupilOffsetY: CGFloat = 0
    @State private var isBlinking = false
    @State private var swayOffset: CGFloat = 0
    @State private var leafParticles: [LeafParticle] = []

    struct LeafParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var opacity: Double
        let color: Color
    }

    private var gridSize: CGFloat { 16 * pixelSize }

    var body: some View {
        ZStack {
            // Sparkles (cheer only)
            if mood == .cheer {
                sparkles
            }

            // Blown leaves (windy only)
            if mood == .windy {
                ForEach(leafParticles) { leaf in
                    leaf.color
                        .frame(width: pixelSize, height: pixelSize)
                        .opacity(leaf.opacity)
                        .offset(x: leaf.x * pixelSize, y: leaf.y * pixelSize)
                }
            }

            // Main tree body
            VStack(spacing: 0) {
                treeBody
                    .offset(x: swayOffset, y: bounceOffset)
                ground
            }
        }
        .frame(width: gridSize, height: gridSize)
        .onAppear { startAnimations() }
        .onChange(of: mood) { _ in startAnimations() }
    }

    // MARK: - Tree body (crown + eyes + smile + trunk)

    private var treeBody: some View {
        ZStack(alignment: .topLeading) {
            // Crown rows
            crownPixels

            // Eyes
            if mood == .windy && isBlinking {
                // Windy shut-eye lids
                pixel(x: 5, y: 6, w: 2, h: 1, color: Color(hex: 0x2d6a4f))
                pixel(x: 9, y: 6, w: 2, h: 1, color: Color(hex: 0x2d6a4f))
            } else if mood == .windy {
                // Squinting against wind — narrow 2x1 eyes, pupils looking right
                pixel(x: 5, y: 6, w: 2, h: 1, color: .white)
                pixel(x: 9, y: 6, w: 2, h: 1, color: .white)
                pixel(x: 6, y: 6, w: 1, h: 1, color: Color(hex: 0x111111))
                pixel(x: 10, y: 6, w: 1, h: 1, color: Color(hex: 0x111111))
            } else if isBlinking {
                // Blink: thin line at bottom of eye area
                pixel(x: 5, y: 6, w: 2, h: 1, color: .white)
                pixel(x: 9, y: 6, w: 2, h: 1, color: .white)
            } else {
                pixel(x: 5, y: 5, w: 2, h: 2, color: .white)
                pixel(x: 9, y: 5, w: 2, h: 2, color: .white)
                // Pupils
                pixel(x: 6 + Int(pupilOffsetX), y: 5 + Int(pupilOffsetY), w: 1, h: 1, color: Color(hex: 0x111111))
                pixel(x: 10 + Int(pupilOffsetX), y: 5 + Int(pupilOffsetY), w: 1, h: 1, color: Color(hex: 0x111111))
            }

            // Mouth
            if mood == .cheer {
                pixel(x: 6, y: 8, w: 4, h: 1, color: Color(hex: 0x1a4d2e))
                pixel(x: 7, y: 9, w: 2, h: 1, color: Color(hex: 0x1a4d2e))
            } else if mood == .windy {
                // Gritting mouth — one row lower
                pixel(x: 7, y: 9, w: 2, h: 1, color: Color(hex: 0x1a4d2e))
            } else {
                pixel(x: 7, y: 8, w: 2, h: 1, color: Color(hex: 0x1a4d2e))
            }

            // Trunk
            pixel(x: 7, y: 11, w: 2, h: 2, color: Color(hex: 0x8B5E3C))
            pixel(x: 6, y: 12, w: 4, h: 1, color: Color(hex: 0x6B3F2A))
        }
        .frame(width: gridSize, height: 13 * pixelSize)
    }

    private var ground: some View {
        ZStack(alignment: .topLeading) {
            pixel(x: 4, y: 0, w: 8, h: 1, color: Color(hex: 0x5C4033))
            pixel(x: 3, y: 1, w: 10, h: 1, color: Color(hex: 0x4a3728))
        }
        .frame(width: gridSize, height: 2 * pixelSize)
    }

    private var crownPixels: some View {
        ZStack(alignment: .topLeading) {
            pixel(x: 7, y: 1, w: 2, h: 1, color: Color(hex: 0x2d6a4f))
            pixel(x: 6, y: 2, w: 4, h: 1, color: Color(hex: 0x40916c))
            pixel(x: 5, y: 3, w: 6, h: 1, color: Color(hex: 0x40916c))
            pixel(x: 6, y: 4, w: 4, h: 1, color: Color(hex: 0x2d6a4f))
            pixel(x: 4, y: 5, w: 8, h: 1, color: Color(hex: 0x40916c))
            pixel(x: 3, y: 6, w: 10, h: 1, color: Color(hex: 0x40916c))
            pixel(x: 5, y: 7, w: 6, h: 1, color: Color(hex: 0x2d6a4f))
            pixel(x: 3, y: 8, w: 10, h: 1, color: Color(hex: 0x52b788))
            pixel(x: 2, y: 9, w: 12, h: 1, color: Color(hex: 0x40916c))
            pixel(x: 2, y: 10, w: 12, h: 1, color: Color(hex: 0x2d6a4f))
        }
    }

    private var sparkles: some View {
        ZStack(alignment: .topLeading) {
            pixel(x: 1, y: 3, w: 1, h: 1, color: Color(hex: 0xffd166)).opacity(showSparkles ? 1 : 0)
            pixel(x: 14, y: 2, w: 1, h: 1, color: Color(hex: 0xffd166)).opacity(showSparkles ? 1 : 0)
            pixel(x: 2, y: 1, w: 1, h: 1, color: Color(hex: 0xffd166)).opacity(showSparkles ? 0.7 : 0)
            pixel(x: 13, y: 4, w: 1, h: 1, color: Color(hex: 0xffd166)).opacity(showSparkles ? 0.7 : 0)
            pixel(x: 0, y: 5, w: 1, h: 1, color: Color(hex: 0x52b788)).opacity(showSparkles ? 1 : 0)
            pixel(x: 15, y: 1, w: 1, h: 1, color: Color(hex: 0x52b788)).opacity(showSparkles ? 1 : 0)
        }
        .frame(width: gridSize, height: gridSize)
    }

    // MARK: - Pixel helper

    private func pixel(x: Int, y: Int, w: Int, h: Int, color: Color) -> some View {
        color
            .frame(width: CGFloat(w) * pixelSize, height: CGFloat(h) * pixelSize)
            .offset(x: CGFloat(x) * pixelSize, y: CGFloat(y) * pixelSize)
    }

    // MARK: - Animations

    private func startAnimations() {
        switch mood {
        case .idle:
            startIdleAnimations()
        case .cheer:
            startCheerAnimations()
        case .windy:
            startWindyAnimations()
        }
    }

    private func startIdleAnimations() {
        // Blink every ~4 seconds
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.08)) { isBlinking = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.08)) { isBlinking = false }
            }
        }

        // Scan pupils: center → left → center → down → center, loop
        func scanLoop() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.2)) { pupilOffsetX = -1 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeInOut(duration: 0.2)) { pupilOffsetX = 0; pupilOffsetY = 1 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeInOut(duration: 0.2)) { pupilOffsetY = 0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                scanLoop()
            }
        }
        scanLoop()
    }

    private func startCheerAnimations() {
        // Bounce loop
        func bounceLoop() {
            withAnimation(.easeOut(duration: 0.2)) { bounceOffset = -pixelSize }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.2)) { bounceOffset = 0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.15)) { bounceOffset = -pixelSize * 0.5 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation(.easeIn(duration: 0.15)) { bounceOffset = 0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { bounceLoop() }
        }
        bounceLoop()

        // Sparkle toggle
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.25)) { showSparkles.toggle() }
        }
    }
    private func startWindyAnimations() {
        // Sustained lean left with tremor
        func swayLoop() {
            withAnimation(.easeInOut(duration: 0.3)) { swayOffset = -pixelSize * 0.5 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) { swayOffset = -pixelSize * 0.7 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.3)) { swayOffset = -pixelSize * 0.4 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeInOut(duration: 0.3)) { swayOffset = -pixelSize * 0.7 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { swayLoop() }
        }
        swayLoop()

        // Blink every 3s (open 35%, shut 15%, open 40%)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                withAnimation(.easeInOut(duration: 0.05)) { isBlinking = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.65) {
                withAnimation(.easeInOut(duration: 0.05)) { isBlinking = false }
            }
        }

        // Spawn leaf particles blowing right-to-left
        let leafColors: [Color] = [Color(hex: 0x52b788), Color(hex: 0x40916c), Color(hex: 0x2d6a4f)]
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            let startX = CGFloat(17)
            let startY = CGFloat.random(in: 1...11)
            let leaf = LeafParticle(x: startX, y: startY, opacity: 0.8, color: leafColors.randomElement()!)
            leafParticles.append(leaf)

            // Animate leaf blowing left and fading
            if let idx = leafParticles.firstIndex(where: { $0.id == leaf.id }) {
                withAnimation(.easeOut(duration: 1.4)) {
                    leafParticles[idx].x -= CGFloat.random(in: 14...18)
                    leafParticles[idx].y -= CGFloat.random(in: 1...3)
                    leafParticles[idx].opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    leafParticles.removeAll { $0.id == leaf.id }
                }
            }
        }
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
