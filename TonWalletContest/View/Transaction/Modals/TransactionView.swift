//
//  TransactionView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 18/05/23.
//

import SwiftUI

struct TransactionView: View {

    let transaction: Transaction
    @State private var rotationAngle: Double = 0.0


    var body: some View {

        let numberString = String(transaction.amount)
        let largeDigits = String(Int(transaction.amount))
        let smallDigits = numberString.suffix(from: numberString.firstIndex(of: ".") ?? numberString.endIndex)
        VStack {
            HStack(alignment: .center) {
                Image("ic_ton")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36, alignment: .center)
                (
                    Text(largeDigits)
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                    + Text(smallDigits)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                )
                .foregroundColor(.green)
            }
            Text(String(transaction.fee) + " transaction fee")
                .font(.callout)
                .foregroundColor(.gray)
                .padding(.bottom, 1)
            switch transaction.status {
            case .cancelled:
                Text("Canceled")
                    .font(.callout)
                    .foregroundColor(.red)
            case .success:
                Text(dateFormatter(date: transaction.date))
                    .font(.callout)
                    .foregroundColor(.gray)
            case .pending:
                HStack {
                    Image("progress")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 10, height: 10)
                        .rotationEffect(.init(degrees: rotationAngle))
                        .onAppear {
                            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }
                    Text("Pending")
                        .font(.callout)
                        .foregroundColor(.blue)
                }
            }
        }
    }

    func dateFormatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' HH:mm"
        return dateFormatter.string(from: date)
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView(transaction: .previewInstance)
    }
}
