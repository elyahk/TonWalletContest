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
                                HStack {
                                    Text("\(transaction.amount) from")
                                    Spacer()
                                    Text("\(transaction.date)")
                                }
                                .padding(.bottom, -2.0)
                                Text(transaction.senderAddress)
                                Text("\(transaction.fee) storage fee")
                                Text(transaction.comment)
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

