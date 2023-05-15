import ComposableArchitecture
import SwiftyTON
import Foundation

struct ImportFailureReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var events: Events
        
        init(destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.events = events
        }
        
        static let preview: State = .init(events: .init(
            createStartReducerState: { .preview }
        ))
    }
    
    struct Events: AlwaysEquitable {
        var createStartReducerState: () async -> StartReducer.State
    }

    indirect enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case destinationState(Destination.State)
        case createNewWalletTapped
        case importWordsTapped
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .destinationState(let destinationState):
                state.destination = destinationState
                return .none
                
            case .createNewWalletTapped:
                return .run { [events = state.events] send in
                    await send(.destinationState(.createWallet(await events.createStartReducerState())))
                }

            case .importWordsTapped:
                #warning("Return back")
//                state.destination = .importWords(.init())
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

            var id: AnyHashable {
                switch self {
                case let .createWallet(state):
                    return state.id
                }
            }
        }

        enum Action: Equatable {
            case createWallet(StartReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.createWallet, action: /Action.createWallet) {
                StartReducer()
            }
        }
    }
}
