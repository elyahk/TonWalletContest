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
                    Text(viewStore.humanAddress)
                        .frame(width: 100)
                        .truncationMode(.middle)

//                    if !viewStore.transaction.humanAddress.isEmpty {
//                        Text(viewStore.humanAddress)
//                            .foregroundColor(.gray)
//                    }

                    Spacer()
                    Button {
                        print("Edit button tapped")
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
                    TextField("0", text: viewStore.binding(
                        get: { $0.amount },
                        send: { return .changed(.text($0)) }
                    ))
                    .font(.largeTitle)
                }
                .padding(.horizontal, 16)

                Spacer()

                HStack {
                    Text("Send all")
                    Image("ic_ton")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 22, height: 22)
                    Text(viewStore.allAmount.description)
                    Spacer()
                    Toggle(isOn: viewStore.binding(
                        get: { $0.isAllAmount },
                        send: { return .changed(.toggle($0))}))  {
                    }


                }
                .padding(.horizontal, 16)

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
                        .padding(.bottom)
                }

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
