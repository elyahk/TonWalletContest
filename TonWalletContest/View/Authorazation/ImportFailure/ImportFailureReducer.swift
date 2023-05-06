import ComposableArchitecture
import SwiftyTON
import Foundation

struct ImportFailureReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
    }

    indirect enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case createNewWalletTapped
        case importWordsTapped
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .createNewWalletTapped:
//                state.destination = .createWallet(.init())
                 #warning("Todo")

                return .none

            case .importWordsTapped:
                state.destination = .importWords(.init())
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

extension ImportFailureReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case createWallet(StartReducer.State)
            case importWords(ImportPhraseReducer.State)

            var id: AnyHashable {
                switch self {
                case let .createWallet(state):
                    return state.id
                case let .importWords(state):
                    return state.id
                }
            }
        }

        enum Action: Equatable {
            case createWallet(StartReducer.Action)
            case importWords(ImportPhraseReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.createWallet, action: /Action.createWallet) {
                StartReducer()
            }
            Scope(state: /State.importWords, action: /Action.importWords) {
                ImportPhraseReducer()
            }
        }
    }
}
