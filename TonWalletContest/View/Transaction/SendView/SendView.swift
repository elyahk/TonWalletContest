//
//  SendView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 05/05/23.
//

import SwiftUI
import CodeScanner
import ComposableArchitecture

struct SendView: View {
    let store: StoreOf<SendReducer>

    init(store: StoreOf<SendReducer>) {
        self.store = store
    }

    @State var address: String = ""
    //    @FocusState private var isFocused: Bool

    @State var transactionHistory: [Transaction] = [
        Transaction(senderAddress: "wedo3irjwljOj)J09JH0j9josdijfo394", humanAddress: "EldorTheCoolest.ton", amount: 1.2, comment: "", fee: 0.0023123, date: .init(), status: .pending, isTransactionSend: true, transactionId: "dsdf"),
        Transaction(senderAddress: "wedo3irjwljOj)J09JH0j9josdijfo394", humanAddress: "GoingCrazy.ton", amount: 110.2, comment: "", fee: 0.23123, date: .init().addingTimeInterval(86400 * 5), status: .cancelled, isTransactionSend: false, transactionId: "SDFsdfwr23r23w"),
        Transaction(senderAddress: "wedo3irjwljOj)J09JH0j9josdijfo394", humanAddress: "", amount: 110.2, comment: "", fee: 0.23123, date: .init().addingTimeInterval(86400), status: .success, isTransactionSend: true, transactionId: "ASDA23er23dsad23")
    ]

    @Environment(\.presentationMode) var presentationMode
    @State var isShowingScanner: Bool = false

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                #warning("Add placeholder text to legacyTextField")
                LegacyTextField(
                    text: viewStore.binding(get: { $0.address }, send: { return .changedAddress($0) } ),
                    isFirstResponder: .constant(true)
                )
                .clearButton(isHidden: address.isEmpty, action: {
                    self.address = ""
                })
                .frame(width: .infinity, height: 50, alignment: .leading)
                .padding(.horizontal, 16)
                .background(Color("LightGray"))
                .cornerRadius(10)
                .padding(.horizontal, 16)

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
                        isShowingScanner = true
                    } label: {
                        HStack {
                            Image("scan")
                            Text("Scan")
                        }
                    }
                }
                .padding(.horizontal, 16)

                if !viewStore.transactions.isEmpty {
                    List {
                        Section {
                            ForEach(transactionHistory) { transaction in
                                VStack(alignment: .leading) {
                                    if !transaction.humanAddress.isEmpty {
                                        Text(transaction.humanAddress)
                                    } else {
                                        Text(transaction.senderAddress.prefix(4) + "..." + transaction.senderAddress.suffix(4))
                                    }

                                    Text("")
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
                    //                    EnterAmountView(address: $address)
                    Text("")
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
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "asdfkjm934orjo23de", completion: handleScan)
            }
        }
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            address = result.string
        case .failure(let error):
            print("Scanning failure \(error.localizedDescription)")
        }
    }
}

extension View {
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

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SendView(store: .init(initialState: .preview, reducer: SendReducer()))
                .navigationTitle("Send TON")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
