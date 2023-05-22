import SwiftUI

struct TransactionAmountView: View {
    typealias Size = (largeSize: CGFloat, smallSize: CGFloat, iconSize: CGFloat)
    var amount: Double
    @State var size: Size
    @State var integerString: String
    @State var fractionalString: String
    @State var color: UIColor

    init(amount: Double, color: UIColor, size: Size = (48, 30, 36)) {
        self.amount = amount
        self.size = size
        self.color = color
        self.integerString = amount.integerString()
        self.fractionalString = amount.fractionalString()
    }

    var body: some View {
        HStack(alignment: .center) {
            Image("ic_ton")
                .resizable()
                .scaledToFill()
                .frame(width: size.iconSize, height: size.iconSize, alignment: .center)
            (
                Text(integerString)
                    .font(.system(size: size.largeSize, weight: .semibold, design: .rounded))
                + Text(fractionalString)
                    .font(.system(size: size.smallSize, weight: .semibold, design: .rounded))
            )
            .foregroundColor(.init(color))
        }
    }
}
