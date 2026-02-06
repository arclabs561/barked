import SwiftUI

struct SuccessBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            MascotView(mood: .cheer, pixelSize: 2.5)
            VStack(alignment: .leading, spacing: 2) {
                Text(message)
                    .font(.callout.bold())
                    .foregroundStyle(.green)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.green.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
}
