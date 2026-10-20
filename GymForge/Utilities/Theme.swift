import SwiftUI

enum GFTheme {
    static let bg = Color(red: 0.035, green: 0.04, blue: 0.05)
    static let card = Color(red: 0.075, green: 0.085, blue: 0.105)
    static let accent = Color(red: 0.15, green: 0.55, blue: 1.0)
    static let success = Color.green
    static let warning = Color.orange
}

extension View {
    func gfCard() -> some View {
        self.padding(16).background(GFTheme.card).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.07), lineWidth: 1))
    }
}
