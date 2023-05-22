import SwiftUI


struct ChatBubble<Content>: View where Content: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        HStack {
            content()
                .clipShape(ChatBubbleShape())

            Spacer()
        }
    }
}

struct ChatBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        return getLeftBubblePath(in: rect)
    }

    private func getLeftBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: CGPoint(x: 25, y: height))
            p.addLine(to: CGPoint(x: width - 20, y: height))
            p.addCurve(to: CGPoint(x: width, y: height - 20),
                       control1: CGPoint(x: width - 8, y: height),
                       control2: CGPoint(x: width, y: height - 8))
            p.addLine(to: CGPoint(x: width, y: 20))
            p.addCurve(to: CGPoint(x: width - 20, y: 0),
                       control1: CGPoint(x: width, y: 8),
                       control2: CGPoint(x: width - 8, y: 0))
            p.addLine(to: CGPoint(x: 21, y: 0))
            p.addCurve(to: CGPoint(x: 4, y: 20),
                       control1: CGPoint(x: 12, y: 0),
                       control2: CGPoint(x: 4, y: 8))
            p.addLine(to: CGPoint(x: 4, y: height - 11))
            p.addCurve(to: CGPoint(x: 0, y: height),
                       control1: CGPoint(x: 4, y: height - 1),
                       control2: CGPoint(x: 0, y: height))
            p.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
            p.addCurve(to: CGPoint(x: 11.0, y: height - 4.0),
                       control1: CGPoint(x: 4.0, y: height + 0.5),
                       control2: CGPoint(x: 8, y: height - 1))
            p.addCurve(to: CGPoint(x: 25, y: height),
                       control1: CGPoint(x: 16, y: height),
                       control2: CGPoint(x: 20, y: height))

        }
        return path
    }
}


struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatBubble {
                Text("Testing comment, D")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding([.trailing], 10)
                    .padding([.leading], 15)
                    .padding([.bottom, .top], 8)
                    .background(Color.gray)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
        }
    }
}



struct FocueCameraView<Content>: View where Content: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        HStack {
            content()
                .clipShape(FocueCameraViewShape())
        }
    }
}

struct FocueCameraViewShape: Shape {
    func path(in rect: CGRect) -> Path {
        return getLeftBubblePath(in: rect)
    }

    private func getLeftBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let centerWidth = width - 66 * 2

        let path = Path { p in
            p.addRect(.init(x: 0, y: 0, width: width, height: (height - centerWidth) / 2))
            p.addRect(.init(x: 0, y: 0, width: 66, height: height))
            p.addRect(.init(x: width - 66, y: 0, width: 66, height: height))
            p.addRect(.init(x: 0, y: height - (height - centerWidth) / 2, width: width, height: (height - centerWidth) / 2))
            p.move(to: CGPoint(x: 0, y: 0))
        }
        return path
    }
}


struct FocueCameraView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FocueCameraView {
                Text("Testing comment, D")
                    .frame(width: 400, height: 800)
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding([.trailing], 10)
                    .padding([.leading], 15)
                    .padding([.bottom, .top], 8)
                    .background(Color.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(width: .infinity, height: .infinity)
            .foregroundColor(.white)
        }
    }
}

