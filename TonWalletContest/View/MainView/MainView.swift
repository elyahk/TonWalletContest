//
//  MainView.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 26/04/23.
//

import SwiftUI
import SwiftyTON
import ComposableArchitecture


struct MainViewReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var balance: String = ""
        var walletAddress: String = ""
        var events: Events
        var transactions: [Transaction] = []
    }

    struct Events: AlwaysEquitable {
        var getBalance: () async -> String
        var getWalletAddress: () async -> String
        var getTransactions: () async -> [Transaction]
    }

    enum Action: Equatable {
        case onAppear
        case configure(balance: String, address: String, transactions: [Transaction])
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [events = state.events] send in
                    let balance = await events.getBalance()
                    let address = await events.getWalletAddress()
                    let transactions = await events.getTransactions()

                    await send(.configure(balance: balance, address: address, transactions: transactions))
                }

            case let .configure(balance, address, transactions):
                state.balance = balance
                state.walletAddress = address
                state.transactions = transactions

                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

extension MainViewReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case wallet(PasscodeReducer.State)

            var id: AnyHashable {
                switch self {
                case let .wallet(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case wallet(PasscodeReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.wallet, action: /Action.wallet) {
                PasscodeReducer()
            }
        }
    }
}

struct MainView: View {
    let store: StoreOf<MainViewReducer>
    @State var isModal: Bool = false

    init(store: StoreOf<MainViewReducer>) {
        self.store = store
    }

    struct ViewState: Equatable {
        var balance: String
        var walletAddress: String
        var transactions: [Transaction]
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

                        }
                        .frame(maxWidth: .infinity, minHeight: 50.0)
                        .customBlueButtonStyle()

                        Button("Send") {

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
                UserDefaults.standard.set(AppState.walletCreated.rawValue , forKey: "state")
            }
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainView(store: .init(
                initialState: .init(events: .init(
                    getBalance: { "56.0000" },
                    getWalletAddress: { "ASDFSFSFSADFASDFASDFSADFSD"},
                    getTransactions: { [
                        .previewInstance,
                        .previewInstance,
                        .previewInstance
                    ] }
                )),
                reducer: MainViewReducer()
            ))
        }
    }
}

