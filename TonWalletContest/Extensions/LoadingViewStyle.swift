import SwiftUI

struct LoadingViewStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.gray) // 2
            .padding(30)
            .background(Color.init(UIColor.secondarySystemBackground))
            .cornerRadius(8)
    }
}
