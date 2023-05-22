//
//  EnterAmountView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 16/05/23.
//

import SwiftUI
import ComposableArchitecture

struct EnterAmountView: View {
    let store: StoreOf<EnterAmountReducer>

    init(store: StoreOf<EnterAmountReducer>) {
        self.store = store

    }

    var body: some View {
        WithViewStore.init(store, observe: { $0 }) { viewStore in
            VStack {
                Divider()
                    .padding(.horizontal, 16)
                    .frame(height: 0.33)
                HStack {
                    Text("Send to:")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text(viewStore.recieverAddress)
                        .frame(width: 100)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text(viewStore.recieverShortAddress)
                        .font(.callout)
                        .foregroundColor(.gray)

//                    if !viewStore.transaction.humanAddress.isEmpty {
//                        Text(viewStore.humanAddress)
//                            .foregroundColor(.gray)
//                    }

                    Spacer()
                    Button {
                        viewStore.send(.editButtonTapped)
                    } label: {
                        Text("Edit")
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                HStack {
                    Image("ic_ton")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 35, height: 35)

                    ZStack {
                        if viewStore.amount.isEmpty {
                            Text("0")
                                .font(.system(size: 48, weight: .semibold))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.leading], 6)
                        }
                        AmountTextField(
                            text: viewStore.binding(
                                get: { $0.amount },
                                send: { return .changed(.text($0)) }
                            ),
                            isOverLimit: .constant(false),
                            size: .constant((48, 30)),
                            isFirstResponder: .constant(true)
                        )
                    }
                }
                .frame(minWidth: 50, maxWidth: 100, maxHeight: 50)
                .padding(.horizontal, 16)

                Spacer()

                HStack {
                    Text("Send all")
                    Image("ic_ton")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 22, height: 22)
                    Text(viewStore.userWallet.allAmmount.description)
                    Spacer()
                    Toggle(isOn: viewStore.binding(
                        get: { $0.isAllAmount },
                        send: { return .changed(.toggle($0))}))  {
                    }


                }
                .padding(.horizontal, 16)

                ZStack(alignment: .trailing) {
                    NavigationLinkStore (
                        self.store.scope(state: \.$destination, action: EnterAmountReducer.Action.destination),
                        state: /EnterAmountReducer.Destination.State.confirmView,
                        action: EnterAmountReducer.Destination.Action.confirmView
                    ) {
                        viewStore.send(.continueButtonTapped)
                    } destination: { store in
                        ConfirmView(store: store)
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                            .customWideBlueButtonStyle()
                            .padding(.horizontal, 16)
                    }

                    if viewStore.isLoading {
                        CustomProgressView(color: .white, strokeWidth: 2.33)
                            .frame(width: 16, height: 16)
                            .padding([.trailing], 33)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Send TON")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EnterAmountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EnterAmountView(store: .init(initialState: .preview, reducer: EnterAmountReducer()))
        }
    }
}
