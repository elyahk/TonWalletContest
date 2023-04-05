import SwiftUI

struct TextButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17.0, weight: .semibold))
            .foregroundColor(.white)
            .background(Color.accentColor)
            .cornerRadius(12)
            .padding(.horizontal, 48)
    }
}

extension View {
    func customButtonStyle() -> some View {
        self
            .modifier(TextButtonStyle())
    }
}
