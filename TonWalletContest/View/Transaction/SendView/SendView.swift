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

    @State var isShowingScanner: Bool = false
    @State var rotationAngle: CGFloat = 360.0

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                LegacyTextField(
                    text: viewStore.binding(get: { $0.address }, send: { return .changedAddress($0) } ),
                    placeHolderText: .constant("Enter Wallet Address or Domain..."),
                    isFirstResponder: .constant(true)
                )
                .clearButton(isHidden: viewStore.address.isEmpty, action: {
                    viewStore.send(.changeAddress(""))
                })
                .frame(height: 50, alignment: .leading)
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
                            viewStore.send(.changeAddress(pasteboardText))
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
                            ForEach(viewStore.transactions) { transaction in
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
                                    viewStore.send(.clearTransactions)
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

                ZStack(alignment: .trailing) {
                    NavigationLinkStore (
                        self.store.scope(
                            state: \.$destination,
                            action: SendReducer.Action.destination),
                        state: /SendReducer.Destination.State.enterAmountView,
                        action: SendReducer.Destination.Action.enterAmountView
                    ) {
                        ViewStore(store).send(.continueButtonTapped)
                    } destination: { store in
                        EnterAmountView(store: store)
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                            .customWideBlueButtonStyle()
                            .padding(.horizontal, 16)
                    }

//                    if viewStore.isLoading {
//                        CustomProgressView(color: .systemBlue, strokeWidth: 2.33)
//                            .frame(width: 16.0, height: 16.0)
//                            .padding([.trailing, 240])
//                    }
                }
                .padding(.bottom)
            }
            .padding(.vertical)
            .navigationTitle("Send TON")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "asdfkjm934orjo23de") { result in
                    if let value = handleScan(result: result) {
                        viewStore.send(.changeAddress(value))
                    }
                }
            }
        }
    }

    func handleScan(result: Result<ScanResult, ScanError>) -> String? {
        isShowingScanner = false
        switch result {
        case .success(let result):
            return result.string
        case .failure(let error):
            print("Scanning failure \(error.localizedDescription)")
            return nil
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
