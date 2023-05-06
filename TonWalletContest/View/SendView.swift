//
//  SendView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 05/05/23.
//

import SwiftUI

struct Transaction: Identifiable {
    var id = UUID()
    let senderAddress: String
    let humanAddress: String
    let transaction: String
    let amount: Double
    let comment = ""
    let fee: Double
    let date: Date
}

@available(iOS 15.0, *)
struct SendView: View {
    @State var address: String = ""
    @FocusState private var isFocused: Bool

    @State var transactionHistory: [Transaction] = [
        Transaction(senderAddress: "wedo3irjwljOj)J09JH0j9josdijfo394", humanAddress: "EldorTheCoolest.ton", transaction: "DF3RE23ewr@#e23ed", amount: 1.2, fee: 0.0023123, date: Date.now),
        Transaction(senderAddress: "wedo3irjwljOj)J09JH0j9josdijfo394", humanAddress: "GoingCrazy.ton", transaction: "DF3RE23ewr@#e23ed", amount: 110.2, fee: 0.23123, date: Date.now.addingTimeInterval(86400 * 5)),
        Transaction(senderAddress: "wedo3irjwljOj)J09JH0j9josdijfo394", humanAddress: "", transaction: "DF3RE23ewr@#e23ed", amount: 110.2, fee: 0.23123, date: Date.now.addingTimeInterval(86400))
    ]

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("Enter Wallet Address or Domain...", text: $address)
                    .clearButton(isHidden: address.isEmpty, action: {
                        self.address = ""
                    })
                    .frame(width: .infinity, height: 50, alignment: .leading)
                    .padding(.horizontal, 16)
                    .background(Color("LightGray"))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }

                Text("Paste the 24-letter wallet address of the recipient here or TON DNS.")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 16)
                HStack {
                    Button {
                        if let pasteboardText = UIPasteboard.general.string {
                            self.address = pasteboardText
                        }
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                            Text("Paste")
                        }
                    }
                    .padding(.trailing)
                    Button {
                        //
                    } label: {
                        HStack {
                            Image("scan")
                            Text("Scan")
                        }
                    }
                }
                .padding(.horizontal, 16)
                if !transactionHistory.isEmpty {
                    List {
                        Section {
                            ForEach(transactionHistory) { transaction in
                                VStack(alignment: .leading) {
                                    if !transaction.humanAddress.isEmpty {
                                        Text(transaction.humanAddress)
                                    } else {
                                        Text(transaction.senderAddress.prefix(4) + "..." + transaction.senderAddress.suffix(4))
                                    }
                                    Text(transaction.date, format: .dateTime.day().month())
                                        .font(.callout)
                                        .foregroundColor(.gray)
                                }
                            }
                        } header: {
                            HStack {
                                Text("RECENTS")
                                    .font(.callout)
                                Spacer()
                                Button {
                                    transactionHistory.removeAll()
                                } label: {
                                    Text("CLEAR")
                                        .font(.callout)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                Spacer()
                NavigationLink {
                    //
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                        .customWideBlueButtonStyle()
                        .padding(.bottom)
                }
            }
            .padding(.vertical)
            .navigationTitle("Send TON")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .font(.headline)
                            Text("Back")
                        }
                    }
                }
            }
        }
    }
}

extension TextField {
    func clearButton(isHidden: Bool, action: @escaping () -> Void) -> some View {
        ZStack(alignment: .trailing) {
            self

            if !isHidden {
                Button(action: action) {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.secondary)
                }

            }
        }
    }
}

@available(iOS 16.0, *)
struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView()
            .navigationTitle("Send TON")
            .navigationBarTitleDisplayMode(.inline)
    }
}
