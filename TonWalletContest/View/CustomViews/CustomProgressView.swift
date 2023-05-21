import SwiftUI

struct CustomProgressView: View {
    @State private var rotationAngle: Double = 0.0
    private var color: UIColor
    private var strokeWidth: CGFloat

    init(color: UIColor, strokeWidth: CGFloat) {
        self.color = color
        self.strokeWidth = strokeWidth
    }

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.6)
            .stroke(
                Color.init(color.cgColor),
                style: StrokeStyle(
                    lineWidth: strokeWidth,
                    lineCap: .round
                )
            )
            .onAppear {
                rotationAngle = 360
            }
            .rotationEffect(.init(degrees: rotationAngle))
            .animation(.linear(duration: 1.5).delay(0.0).repeatForever(autoreverses: false), value: rotationAngle)
    }
}

struct CustomProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomProgressView(color: .yellow, strokeWidth: 1.33)
                .frame(width: 10, height: 10)
        }

    }
}
