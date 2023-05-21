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
        var userWallet: UserSettings.UserWallet?

        init(state: MainViewReducer.State) {
            self.userWallet = state.userWallet
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init ) { viewStore in
            VStack {
                VStack {
                    HStack {
                        Button {

                        } label: {
                            Image("ic_scan")
                                .resizable()
                                .frame(width: 22.0, height: 22.0)
                                .padding()
                        }
                        Spacer()
                        Button {

                        } label: {
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 22.0, height: 22.0)
                                .foregroundColor(Color.white)
                                .padding()
                        }
                    }

                    VStack {
                        Text(viewStore.userWallet?.address ?? "")
                            .frame(width: 100)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .truncationMode(.middle)
                            .font(.system(size: 17, weight: .regular))

                        TransactionAmountView(amount: viewStore.userWallet?.allAmmount ?? 0, isSent: false)
                            .foregroundColor(Color.white)
                    }
                    .padding(.top, 28.0)

                    HStack(spacing: 12.0) {
                        Button {
                            viewStore.send(.tappedRecieveButton)
                        } label: {
                            Label {
                                Text("Recieve")
                            } icon: {
                                Image(systemName: "arrow.down.backward")
                            }
                            .frame(maxWidth: .infinity, minHeight: 50.0)
                            .font(.system(size: 17.0, weight: .semibold))
                            .foregroundColor(.white)
                            .background(Color.init(UIColor(red: 0.196, green: 0.667, blue: 0.996, alpha: 1).cgColor))
                            .cornerRadius(12)
                        }

                        Button {
                            viewStore.send(.tappedSendButton)
                        } label: {
                            Label {
                                Text("Send")
                            } icon: {
                                Image(systemName: "arrow.up.forward")
                            }
                            .frame(maxWidth: .infinity, minHeight: 50.0)
                            .font(.system(size: 17.0, weight: .semibold))
                            .foregroundColor(.white)
                            .background(Color.init(UIColor(red: 0.196, green: 0.667, blue: 0.996, alpha: 1).cgColor))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.init(top: 74.0, leading: 16.0, bottom: 16.0, trailing: 16.0))
                }

                VStack {
                    List {
                        ForEach(viewStore.userWallet?.transactions ?? []) { transaction in
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
                                    .lineLimit(1)
                                    .frame(width: 100)
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
                                    Button {
                                        viewStore.send(.tappedBackButton)
                                    } label: {
                                        HStack(spacing: 0.0) {
                                            Image(systemName: "chevron.backward")
                                            Text("Back")
                                        }
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
                                        Button {
                                            viewStore.send(.tappedBackButton)
                                        } label: {
                                            HStack(spacing: 0.0) {
                                                Image(systemName: "chevron.backward")
                                                Text("Back")
                                            }
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
        .ignoresSafeArea()
        .background(Color.black)
    }
}

