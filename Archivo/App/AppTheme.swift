import SwiftUI

/// Archivo design system colors and responsive layout guidelines.
/// Based on the canonical modern iPhone canvas: 393 × 852 pt (Retina @3x = 1179 × 2556 px).
enum ArchivoTheme {
    static let background = Color(red: 0.02, green: 0.02, blue: 0.02) // #050505 OLED deep black
    static let surface = Color(red: 0.08, green: 0.085, blue: 0.09)     // Card & bar background
    static let elevated = Color(red: 0.12, green: 0.125, blue: 0.13)    // Higher hierarchy surface
    static let ink = Color(red: 0.97, green: 0.97, blue: 0.96)          // #F7F7F5 pure off-white text
    static let muted = Color(red: 0.60, green: 0.60, blue: 0.62)        // Secondary text & subtle icons
    static let border = Color.white.opacity(0.10)                       // Subtle hair-line borders
    static let accent = Color(red: 0.88, green: 0.86, blue: 0.82)       // Archivo signature cream accent
    static let accentInk = Color.black                                  // Contrast text on top of accent
}

/// Responsive design and layout metrics.
enum ArchivoLayout {
    /// Reference design canvas in points (iPhone 16 / 15 Pro)
    static let canvasWidth: CGFloat = 393
    static let canvasHeight: CGFloat = 852

    /// Maximum readable width for single-column cards/forms on iPad or landscape
    static let maxContentWidth: CGFloat = 430

    /// Component corner radii
    static let cardCornerRadius: CGFloat = 20
    static let buttonCornerRadius: CGFloat = 14
    static let inputCornerRadius: CGFloat = 12

    /// Minimum HIG tap target size in points
    static let minTouchTarget: CGFloat = 44
}

// MARK: - View Modifiers

struct ArchivoCardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(ArchivoTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: ArchivoLayout.cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ArchivoLayout.cardCornerRadius, style: .continuous)
                    .stroke(ArchivoTheme.border, lineWidth: 1)
            )
    }
}

struct ResponsiveContainerModifier: ViewModifier {
    var maxWidth: CGFloat = ArchivoLayout.maxContentWidth

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity) // Automatically centers when parent width exceeds maxWidth
    }
}

extension View {
    /// Applies the signature Archivo card styling with smooth rounded corners and border.
    func archivoCard(padding: CGFloat = 16) -> some View {
        modifier(ArchivoCardModifier(padding: padding))
    }

    /// Adapts the view to prevent over-stretching on iPad / Pro Max while remaining fluid on compact devices.
    func responsiveContainer(maxWidth: CGFloat = ArchivoLayout.maxContentWidth) -> some View {
        modifier(ResponsiveContainerModifier(maxWidth: maxWidth))
    }
}
