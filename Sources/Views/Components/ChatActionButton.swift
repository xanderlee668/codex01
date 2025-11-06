import SwiftUI

struct ChatActionButton: View {
    enum Style {
        case filled
        case tinted
    }

    let title: String
    let icon: String
    let style: Style
    let action: () -> Void

    init(title: String = "发消息", icon: String = "bubble.right", style: Style = .filled, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .labelStyle(.titleAndIcon)
                .font(font)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
                .frame(minHeight: 28)
                .background(background)
                .foregroundColor(foregroundColor)
                .overlay(border)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private var font: Font {
        switch style {
        case .filled:
            return .caption.weight(.semibold)
        case .tinted:
            return .footnote.weight(.semibold)
        }
    }

    private var verticalPadding: CGFloat {
        switch style {
        case .filled:
            return 6
        case .tinted:
            return 4
        }
    }

    private var horizontalPadding: CGFloat {
        switch style {
        case .filled:
            return 12
        case .tinted:
            return 10
        }
    }

    private var background: some View {
        Group {
            switch style {
            case .filled:
                Capsule().fill(Color.accentColor)
            case .tinted:
                Capsule().fill(Color.accentColor.opacity(0.12))
            }
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .filled:
            return .white
        case .tinted:
            return .accentColor
        }
    }

    private var border: some View {
        Group {
            switch style {
            case .filled:
                Capsule().stroke(Color.white.opacity(0.2))
            case .tinted:
                Capsule().stroke(Color.accentColor.opacity(0.25))
            }
        }
    }
}

struct ChatActionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ChatActionButton(style: .filled) {}
            ChatActionButton(style: .tinted) {}
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
