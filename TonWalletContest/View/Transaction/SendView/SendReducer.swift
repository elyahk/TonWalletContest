import ComposableArchitecture
import SwiftyTON
import Foundation

struct SendReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var events: Events

        init(destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.events = events
        }

        static let preview: State = .init(events: .init(
            createEnterAmountReducerState: { .preview }
        ))
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case viewWalletButtonTapped
        case destinationState(Destination.State)
    }

    struct Events: AlwaysEquitable {
        var createEnterAmountReducerState: () async ->  EnterAmountReducer.State
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
                    await send(.destinationState(.enterAmountView(await events.createEnterAmountReducerState())))
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

extension SendReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case enterAmountView(EnterAmountReducer.State)

            var id: AnyHashable {
                switch self {
                case let .enterAmountView(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case enterAmountView(EnterAmountReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.enterAmountView, action: /Action.enterAmountView) {
                EnterAmountReducer()
            }
        }
    }
}
