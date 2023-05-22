import ComposableArchitecture
import SwiftyTON
import Foundation

struct ConfirmReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var transaction: Transaction1
        var numberCharacter: Int = 10
        var isTextEditor = false
        var isOverLimit = false
        var isLoading: Bool = false
        
        @PresentationState var destination: Destination.State?
        var events: Events
        
        init(transaction: Transaction1, destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.events = events
            self.transaction = transaction
        }
        
        static let preview: State = .init(
            transaction: .previewInstance,
            events: .init(
            sendTon: { _ in return },
            createPendingReducerState: { _ in .init(walletAddress: "Wallwerwesadfklsdfkls", events: .init()) }
        ))
    }
    
    enum StateChangeTypes: Equatable {
        case comment(String)
        case isOverLimit(Bool)
        case numberCharacter(Int)
    }
    
    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case destinationState(Destination.State)
        case sendButtonTapped
        case change(StateChangeTypes)
        case loading(Bool)
    }
    
    struct Events: AlwaysEquitable {
        var sendTon: (Transaction1) async throws -> Void
        var createPendingReducerState: (String) async ->  PendingReducer.State
    }
    
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .loading(let isLoading):
                state.isLoading = isLoading
                return .none

            case let .change(type):
                switch type {
                case let .comment(comment):
                    state.transaction.comment = comment
                case let .isOverLimit(isOverLimit):
                    state.isOverLimit = isOverLimit
                case let .numberCharacter(numberCharacter):
                    state.numberCharacter = numberCharacter
                }
                
                return .none
                
            case let .destinationState(destinationState):
                state.destination = destinationState
                
                return .none
            case .sendButtonTapped:
                return .run { [events = state.events, state] send in
                    await send(.loading(true))
                    try await events.sendTon(state.transaction)

                    let state = await events.createPendingReducerState(state.transaction.destinationShortAddress)
                    await send(.loading(false))
                    await send(.destinationState(.pendingView(state)))
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
