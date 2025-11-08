import SwiftUI

struct NightGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.09, blue: 0.13),
                Color(red: 0.02, green: 0.04, blue: 0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            AngularGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.20, green: 0.33, blue: 0.48).opacity(0.3),
                    Color(red: 0.45, green: 0.25, blue: 0.53).opacity(0.25),
                    Color(red: 0.18, green: 0.30, blue: 0.52).opacity(0.35),
                    Color(red: 0.07, green: 0.09, blue: 0.13).opacity(0.2)
                ]),
                center: .center
            )
            .blur(radius: 120)
        )
        .ignoresSafeArea()
    }
}

private struct NightGlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 22
    var padding: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 24, x: 0, y: 18)
            )
    }
}

extension View {
    func nightGlassCard(cornerRadius: CGFloat = 22, padding: CGFloat = 20) -> some View {
        modifier(NightGlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

struct PrimaryGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.accentColor.opacity(configuration.isPressed ? 0.65 : 0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(configuration.isPressed ? 0.45 : 0.25), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .shadow(color: Color.accentColor.opacity(configuration.isPressed ? 0.3 : 0.45), radius: configuration.isPressed ? 6 : 14, x: 0, y: configuration.isPressed ? 4 : 10)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct IconGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.semibold))
            .foregroundColor(.white.opacity(configuration.isPressed ? 0.8 : 0.95))
            .padding(10)
            .background(
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(configuration.isPressed ? 0.4 : 0.25), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.2 : 0.35), radius: configuration.isPressed ? 4 : 8, x: 0, y: configuration.isPressed ? 2 : 6)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ChipGlassButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(isSelected ? 0.32 : 0.16),
                                Color.white.opacity(isSelected ? 0.22 : 0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(isSelected ? 0.45 : 0.25), lineWidth: 1)
                    )
            )
            .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.85))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
