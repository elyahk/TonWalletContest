//
//  TransactionView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 18/05/23.
//

import SwiftUI

extension Double {
    func integerString() -> String {
        return String(Int(self.rounded(.down)))
    }

    func fractionalString() -> String {
        let stringAmount = String(self)
        return String(stringAmount.suffix(from: stringAmount.firstIndex(of: ".") ?? stringAmount.endIndex))
    }
}

extension Date {
    enum FormatType {
        case full
        case short

        var format: String {
            switch self {
            case .full: return "MMM d, yyyy 'at' HH:mm"
            case .short: return "HH:mm"
            }
        }
    }

    func formattedDateString(type: FormatType) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = type.format
        return dateFormatter.string(from: self)
    }
}

struct TransactionAmountView: View {
    typealias Size = (largeSize: CGFloat, smallSize: CGFloat, iconSize: CGFloat)
    var amount: Double
    @State var size: Size
    @State var isSent: Bool
    @State var integerString: String
    @State var fractionalString: String

    init(amount: Double, isSent: Bool, size: Size = (48, 30, 36)) {
        self.amount = amount
        self.size = size
        self.isSent = isSent
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
            .foregroundColor(isSent ? .red : .green)
        }
    }
}

struct TransactionView: View {
    let transaction: Transaction1
    @State private var rotationAngle: Double = 0.0

    var body: some View {
        let transactionDirection = transaction.isTransactionSend ? "Recepient" : "Sender"

        VStack(spacing: 4) {

            TransactionAmountView(amount: transaction.amount, isSent: transaction.isTransactionSend)

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
                Text(transaction.date.formattedDateString(type: .full))
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.bottom)
                if !transaction.comment.isEmpty {
                    ZStack {
                        Text(transaction.comment)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color("LightGray"))
                            .clipShape(RoundedRectangle(cornerRadius: 17.0, style: .continuous))

                    }
                    
                }
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
            Text("DETAILS")
                .foregroundColor(.gray)
                .font(.footnote)
                .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                .padding(.leading, 20)
                .padding(.bottom, -20)
            List {
                Section {

                    if !transaction.humanAddress.isEmpty && !transaction.isTransactionSend {
                        HStack {
                            Text(transactionDirection)
                            Spacer()
                            Text(transaction.humanAddress)
                                .foregroundColor(.gray)
                        }
                    }
                    HStack {
                        Text("\(transactionDirection) address")
                        Spacer()
                        Text(transaction.senderAddress.prefix(4) + "..." + transaction.senderAddress.suffix(4))
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Transaction")
                        Spacer()
                        Text(transaction.transactionId.prefix(6) + "..." + transaction.transactionId.suffix(6))
                            .foregroundColor(.gray)
                    }
                } footer: {
                    Button {
                        //action
                    } label: {
                        Text("View in explorer")
                            .foregroundColor(.blue)
//                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
//                            .padding(.leading, 16)
                    }
                }
            }
            .listStyle(.plain)

            if transaction.status == .cancelled {
                Button {
                    //action
                } label: {
                    Text("Retry transaction")
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                        .customWideBlueButtonStyle()
                        .padding(.bottom)
                }
            } else {
                NavigationLink {
                    //                EnterAmountView(address: $address)
                } label: {
                    Text("Send TON to this address")
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                        .customWideBlueButtonStyle()
                        .padding(.bottom)
                }
            }
        }
        .padding(.top, 76)
    }
}


struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionView(transaction: .previewInstance)
        }
    }
}
