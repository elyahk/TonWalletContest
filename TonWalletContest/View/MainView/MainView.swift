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

    init(store: StoreOf<MainViewReducer>) {
        self.store = store
    }

    struct ViewState: Equatable {
        var userWallet: UserWalletSettings.UserWallet?
        var balance: Double
        var timer: Int

        init(state: MainViewReducer.State) {
            self.userWallet = state.userWallet
            self.timer = state.timer
            self.balance = state.balance
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init ) { viewStore in
            ZStack {
                VStack {
                    VStack {
                        HStack {
                            NavigationLinkStore (
                                self.store.scope(state: \.$destination, action: MainViewReducer.Action.destination),
                                state: /MainViewReducer.Destination.State.scanQRCodeView,
                                action: MainViewReducer.Destination.Action.scanQRCodeView
                            ) {
                                viewStore.send(.tappedScanButton)
                            } destination: { store in
                                ScanQRCodeView(store: store)
                            } label: {
                                Image("ic_scan")
                                    .resizable()
                                    .frame(width: 22.0, height: 22.0)
                                    .padding()
                            }
                            Spacer()

                            NavigationLinkStore (
                                self.store.scope(state: \.$destination, action: MainViewReducer.Action.destination),
                                state: /MainViewReducer.Destination.State.settingsView,
                                action: MainViewReducer.Destination.Action.settingsView
                            ) {
                                viewStore.send(.tappedSettingsButton)
                            } destination: { store in
                                SettingsView(store: store)
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

                            HStack(alignment: .center) {
                                Image("ic_ton")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36, alignment: .center)
                                (
                                    Text(viewStore.balance.integerString())
                                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                                    + Text(viewStore.balance.fractionalString())
                                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                                )
                                .foregroundColor(.init(.white))
                            }
//
//                            TransactionAmountView(
//                                amount: viewStore.balance,
//                                color: .white)
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
                                TransactionListItemView(transaction: transaction)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        viewStore.send(.tappedTransaction(transaction))

                                    }
                            }

                        }
                        .listStyle(.plain)
                    }
                    .background(Color.white)
                    .cornerRadius(16.0)
                }

                IfLetStore(store.scope(state: \.transactionReducerState, action: MainViewReducer.Action.transactionView), then: { store in
                    TransactionView(store: store)
                })
            }
            .ignoresSafeArea(edges: .bottom)
            .background(Color.black)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onChange(of: viewStore.timer, perform: { newValue in
                viewStore.send(.startTimer)
            })
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
        .background(Color.black)
    }
}

