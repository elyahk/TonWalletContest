import ComposableArchitecture
import SwiftyTON
import Foundation

struct ReadyToGoReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var events: Events
        
        init(destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.events = events
        }
        
        static let preview: State = .init(events: .init(
            createMainViewReducerState: { .preview }
        ))
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case viewWalletButtonTapped
        case destinationState(Destination.State)
    }
    
    struct Events: AlwaysEquitable {
        var createMainViewReducerState: () async ->  MainViewReducer.State
    }
    
    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .destinationState(destinationState):
                state.destination = destinationState
                
                return .none
            case .viewWalletButtonTapped:
                return .run { [events = state.events] send in
                    await send(.destinationState(.wallet(await events.createMainViewReducerState())))
                }
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
