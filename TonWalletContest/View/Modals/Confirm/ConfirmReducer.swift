import ComposableArchitecture
import SwiftyTON
import Foundation

struct ConfirmReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var comment: String = ""
        var numberCharacter: Int = 10
        var isTextEditor = false
        var isOverLimit = false
        @PresentationState var destination: Destination.State?
        var events: Events
        
        init(destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.events = events
        }
        
        static let preview: State = .init(events: .init(
            sendTon: { true },
            createPendingReducerState: { .init() }
        ))
    }
    
    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case destinationState(Destination.State)
        case sendButtonTapped
    }
    
    struct Events: AlwaysEquitable {
        var sendTon: () async -> Bool
        var createPendingReducerState: () async ->  PendingReducer.State
    }
    
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .destinationState(destinationState):
                state.destination = destinationState
                
                return .none
            case .sendButtonTapped:
                return .run { [events = state.events] send in
                    if await events.sendTon() {
                        let state = await events.createPendingReducerState()
                        await send(.destinationState(.pendingView(state)))
                    }
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

extension ConfirmReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case pendingView(PendingReducer.State)

            var id: AnyHashable {
                switch self {
                case let .pendingView(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case pendingView(PendingReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.pendingView, action: /Action.pendingView) {
                PendingReducer()
            }
        }
    }
}
