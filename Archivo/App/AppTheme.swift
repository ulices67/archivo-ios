import SwiftUI

enum ArchivoTheme {
    static let background = Color(red: 0.055, green: 0.063, blue: 0.065)
    static let surface = Color(red: 0.095, green: 0.105, blue: 0.11)
    static let elevated = Color(red: 0.13, green: 0.14, blue: 0.145)
    static let ink = Color(red: 0.94, green: 0.93, blue: 0.89)
    static let muted = Color(red: 0.61, green: 0.62, blue: 0.59)
    static let accent = Color(red: 0.86, green: 0.84, blue: 0.78)
}

struct ArchivoCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(ArchivoTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.1)))
    }
}

extension View {
    func archivoCard() -> some View { modifier(ArchivoCard()) }
}

