//
//  MainView.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 26/04/23.
//

import SwiftUI
import SwiftyTON
import ComposableArchitecture

struct MainView: View {
    let store: StoreOf<MainViewReducer>
    @State var isModal: Bool = false

    init(store: StoreOf<MainViewReducer>) {
        self.store = store
    }

    struct ViewState: Equatable {
        var balance: String
        var walletAddress: String
        var transactions: [Transaction1]
        //        var destination: MainViewReducer.Destination.State?

        init(state: MainViewReducer.State) {
            self.balance = state.balance
            self.walletAddress = state.walletAddress
            self.transactions = state.transactions
            //            self.destination = state.destination
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init ) { viewStore in
            VStack {
                VStack {
                    HStack {
                        Button("+") {

                        }
                        .frame(width: 28.0, height: 28.0)
                        Spacer()
                        Button("-") {

                        }
                        .frame(width: 28.0, height: 28.0)
                    }
                    .padding(.init(top: 8.0, leading: 14.0, bottom: 8.0, trailing: 14.0))

                    VStack {
                        Text(viewStore.walletAddress)
                            .frame(width: 100)
                            .lineLimit(1)
                            .foregroundColor(.white)
                        Text(viewStore.balance)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 28.0)

                    HStack(spacing: 12.0) {
                        Button("Recieve") {
                            viewStore.send(.tappedRecieveButton)
                        }
                        .frame(maxWidth: .infinity, minHeight: 50.0)
                        .customBlueButtonStyle()

                        Button("Send") {
                            viewStore.send(.tappedSendButton)
                        }
                        .frame(maxWidth: .infinity, minHeight: 50.0)
                        .customBlueButtonStyle()
                    }
                    .padding(.init(top: 74.0, leading: 16.0, bottom: 16.0, trailing: 16.0))
                    .frame(width: .infinity)
                }

                VStack {
                    List {
                        ForEach(viewStore.transactions) { transaction in
                            VStack(alignment: .leading, spacing: 8.0) {
                                HStack(spacing: 3.0) {
                                    TransactionAmountView(
                                        amount: transaction.amount,
                                        isSent: transaction.isTransactionSend,
                                        size: (19, 18, 16)
                                    )
                                    Text(transaction.isTransactionSend ? "to" : "from")
                                        .font(.system(size: 18, weight: .regular))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(transaction.date.formattedDateString(type: .short))
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.secondary)
                                }

                                Text(transaction.senderAddress)
                                    .font(.system(size: 15, weight: .regular))
                                Text("\(transaction.fee) storage fee")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.secondary)
                                ChatBubble {
                                    Text(transaction.comment)
                                        .font(.system(size: 15, weight: .regular))
                                        .padding([.trailing], 10)
                                        .padding([.leading], 15)
                                        .padding([.bottom, .top], 8)
                                        .multilineTextAlignment(.center)
                                        .background(Color(UIColor(red: 0.937, green: 0.937, blue: 0.953, alpha: 1).cgColor))
                                }
                            }
                        }

                    }
                    .listStyle(.plain)
                }
                .background(Color.white)
                .cornerRadius(16.0)
            }
            .ignoresSafeArea(edges: .bottom)
            .background(Color.black)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .sheet(
                store: self.store.scope(
                    state: \.$destination,
                    action: MainViewReducer.Action.destination),
                state: /MainViewReducer.Destination.State.recieveTonView,
                action: MainViewReducer.Destination.Action.recieveTonView) { store in
                    NavigationView {
                        RecieveTonView(store: store)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("< Back") {
                                        viewStore.send(.tappedBackButton)
                                    }
                                }
                            }
                    }
                }

                .sheet(
                    store: self.store.scope(
                        state: \.$destination,
                        action: MainViewReducer.Action.destination),
                    state: /MainViewReducer.Destination.State.sendView,
                    action: MainViewReducer.Destination.Action.sendView) { store in
                        NavigationView {
                            SendView(store: store)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarLeading) {
                                        Button("< Back") {
                                            viewStore.send(.tappedBackButton)
                                        }
                                    }
                                }
                        }
                    }
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainView(store: .init(
                initialState: .preview,
                reducer: MainViewReducer()
            ))
        }
    }
}

