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
        var events: Events
    }

    struct Events: AlwaysEquitable {
        var getBalance: () async -> String
    }

    enum Action: Equatable {
        case onAppear
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
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

    init(store: StoreOf<MainViewReducer>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                        Text("ADFSDFISDFSFSSDFASDFS")
                            .frame(width: 100)
                            .lineLimit(1)
                            .foregroundColor(.white)
                        Text("56.000000")
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
                        VStack(alignment: .leading, spacing: 8.0) {
                            HStack {
                                Text("0.01 from")
                                Spacer()
                                Text("22:52")
                            }
                            .padding(.bottom, -2.0)
                            Text("sjkfksfjjisjfisifsasdjfiosifs")
                            Text("0.000001 storage fee")
                            Text("Testing payments, D.")
                        }

                        VStack(alignment: .leading, spacing: 8.0) {
                            HStack {
                                Text("0.01 from")
                                Spacer()
                                Text("22:52")
                            }
                            .padding(.bottom, -2.0)
                            Text("sjkfksfjjisjfisifsasdjfiosifs")
                            Text("0.000001 storage fee")
                            Text("Testing payments, D.")
                        }

                        VStack(alignment: .leading, spacing: 8.0) {
                            HStack {
                                Text("0.01 from")
                                Spacer()
                                Text("22:52")
                            }
                            .padding(.bottom, -2.0)
                            Text("sjkfksfjjisjfisifsasdjfiosifs")
                            Text("0.000001 storage fee")
                            Text("Testing payments, D.")
                        }
                    }
                    .listStyle(.plain)
                }
                .background(Color.white)
                .cornerRadius(16.0)
            }
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
                initialState: .init(events: .init(getBalance: { return "56.0000"})),
                reducer: MainViewReducer()
            ))
        }
    }
}

