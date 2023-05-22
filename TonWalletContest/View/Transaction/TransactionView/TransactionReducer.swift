import ComposableArchitecture
import SwiftyTON
import Foundation

struct TransactionReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var transaction: Transaction1
        var isShowing: Bool

        @PresentationState var destination: Destination.State?
        var events: Events

        init(transaction: Transaction1, isShowing: Bool, destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.isShowing = isShowing
            self.events = events
            self.transaction = transaction
        }

        static let preview: State = .init(
            transaction: .previewInstance,
            isShowing: true,
            events: .init(
            ))
    }

    struct Events: AlwaysEquitable {

    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case destinationState(Destination.State)
        case doneButtonTapped
        case sendButtonTapped
        case sendTransaction(Transaction1)
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .doneButtonTapped:
                state.isShowing = false
                return .none

            case let .destinationState(destinationState):
                state.destination = destinationState

                return .none
            case .sendButtonTapped:
                return .run { [state] send in
                    await send(.sendTransaction(state.transaction))
                }
            case .sendTransaction:
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

extension TransactionReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case enterAmoutView(EnterAmountReducer.State)

            var id: AnyHashable {
                switch self {
                case let .enterAmoutView(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case enterAmoutView(EnterAmountReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.enterAmoutView, action: /Action.enterAmoutView) {
                EnterAmountReducer()
            }
        }
    }
}

