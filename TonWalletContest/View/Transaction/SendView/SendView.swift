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

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                LegacyTextField(
                    text: viewStore.binding(get: { $0.address }, send: { return .changedAddress($0) } ),
                    placeHolderText: .constant("Enter Wallet Address or Domain..."),
                    isFirstResponder: viewStore.binding(
                        get: { !$0.isLoading }, send: .noAction
                    )
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

                    NavigationLinkStore (
                        self.store.scope(state: \.$destination, action: SendReducer.Action.destination),
                        state: /SendReducer.Destination.State.scanQRCodeView,
                        action: SendReducer.Destination.Action.scanQRCodeView
                    ) {
                        viewStore.send(.scanButtonTapped)
                    } destination: { store in
                        ScanQRCodeView(store: store)
                    } label: {
                        HStack {
                            Image("ic_scan_blue")
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
                                    if !transaction.destinationShortAddress.isEmpty {
                                        Text(transaction.destinationShortAddress)
                                            .frame(width: 100)
                                            .truncationMode(.middle)
                                            .font(.system(size: 16, weight: .regular))
                                            .lineLimit(1)
                                    } else {
                                        Text(transaction.destinationAddress)
                                            .frame(width: 100)
                                            .truncationMode(.middle)
                                            .lineLimit(1)
                                            .font(.system(size: 16, weight: .regular))
                                    }

                                    Text("sdfsd")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.init(UIColor(red: 0.557, green: 0.557, blue: 0.573, alpha: 1)))
                                }
                            }
                        } header: {
                            HStack {
                                Text("RECENTS")
                                    .font(.system(size: 13, weight: .regular))
                                Spacer()
                                Button {
                                    viewStore.send(.clearTransactions)
                                } label: {
                                    Text("CLEAR")
                                        .font(.system(size: 13, weight: .regular))

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
