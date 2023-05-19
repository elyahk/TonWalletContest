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
        let transactionDirection = transaction.isTransactionSend ? "Recepient" : "Sender"

        VStack {
            Spacer()
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
                .foregroundColor(transaction.isTransactionSend ? .red : .green)
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
                    Button {
                        //action
                    } label: {
                        Text("View in explorer")
                            .foregroundColor(.blue)
                    }

                } header: {
                    Text("DETAILS")
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
    }

    func dateFormatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' HH:mm"
        return dateFormatter.string(from: date)
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionView(transaction: .previewInstance)
        }
    }
}
