//
//  TransactionView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 18/05/23.
//

import SwiftUI


struct TransactionView: View {

    let transaction: Transaction1
    @State private var rotationAngle: Double = 0.0


    var body: some View {

        let numberString = String(transaction.amount)
        let largeDigits = String(Int(transaction.amount))
        let smallDigits = numberString.suffix(from: numberString.firstIndex(of: ".") ?? numberString.endIndex)
        let transactionDirection = transaction.isTransactionSend ? "Recepient" : "Sender"

        VStack(spacing: 4) {
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
