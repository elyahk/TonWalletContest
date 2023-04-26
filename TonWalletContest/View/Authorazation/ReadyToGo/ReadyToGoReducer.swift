import ComposableArchitecture
import SwiftyTON
import Foundation

struct ReadyToGoReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case viewWalletButtonTapped
        case walletCreated(wallet3: Wallet3)
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewWalletButtonTapped:
                print("button tapped")

                return .run { send in
                    let key = try await TonKeyStore.shared.loadKey()
                    print("Key created")

                    if let key = key {
                        let wallet = try await TonWalletManager.shared.createWallet3(key: key)
                        print(wallet.contract.info)
                        await send(.walletCreated(wallet3: wallet))
                    }
                }

            case .walletCreated(let wallet3):
                state.destination = .wallet(.init(wallet3: wallet3))

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

extension ReadyToGoReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case wallet(MainViewReducer.State)

            var id: AnyHashable {
                switch self {
                case let .wallet(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case wallet(MainViewReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.wallet, action: /Action.wallet) {
                MainViewReducer()
            }
        }
    }
}
