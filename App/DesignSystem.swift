import SwiftUI

// MARK: - Design System
enum DS {
    static let blue = Color(red: 0.16, green: 0.43, blue: 0.97)
    static let green = Color(red: 0.12, green: 0.78, blue: 0.50)
    static let orange = Color(red: 0.98, green: 0.68, blue: 0.10)

    static let text = Color.primary
    static let subtext = Color.secondary

    static let card = Color.white.opacity(0.85)
    static let cardStroke = Color.black.opacity(0.05)
    static let shadow = Color.black.opacity(0.06)

    static let radius: CGFloat = 18
    static let pad: CGFloat = 16
}

// Soft “card” container used everywhere
struct Card<Content: View>: View {
    var content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(DS.pad)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DS.radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.radius, style: .continuous)
                    .stroke(DS.cardStroke, lineWidth: 1)
            )
            .shadow(color: DS.shadow, radius: 18, x: 0, y: 10)
    }
}

// Pills like “Pre-meds”, “Fatigue”
struct Pill: View {
    var text: String
    var color: Color = DS.blue
    var filled: Bool = true

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(filled ? Color.white : color)
            .background(
                Capsule().fill(filled ? color : Color.clear)
            )
            .overlay(
                Capsule().stroke(color.opacity(filled ? 0 : 0.25), lineWidth: filled ? 0 : 1)
            )
    }
}

// Subtle dotted background like your screenshots
struct DottedBackground: View {
    var spacing: CGFloat = 18
    var dotSize: CGFloat = 2.2

    var body: some View {
        GeometryReader { geo in
            let cols = Int(geo.size.width / spacing) + 2
            let rows = Int(geo.size.height / spacing) + 2

            Canvas { ctx, size in
                let dot = Path(ellipseIn: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
                for r in 0..<rows {
                    for c in 0..<cols {
                        let x = CGFloat(c) * spacing
                        let y = CGFloat(r) * spacing
                        ctx.fill(dot.offsetBy(dx: x, dy: y),
                                 with: .color(Color.black.opacity(0.06)))
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}
