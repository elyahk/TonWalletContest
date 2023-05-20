import ComposableArchitecture
import SwiftyTON
import Foundation

struct EnterAmountReducer: ReducerProtocol {
    struct Amount: Equatable {
        var address: String
        var amount: String
    }

    struct State: Equatable, Identifiable {
        var address: String
        var allAmount: Double
        var humanAddress: String
        var amount: String = ""
        var isAllAmount = false

        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var events: Events
        
        init(address: String, allAmount: Double, humanAddress: String, destination: Destination.State? = nil, events: Events) {
            self.address = address
            self.allAmount = allAmount
            self.humanAddress = humanAddress
            self.destination = destination
            self.events = events
        }

        static let preview: State = .init(
            address: "ksjfkjsklfjlksfsdf",
            allAmount: 21.23232,
            humanAddress: "xaxa.ton",
            events: .init(createConfirmReducerState: { _ in
                .preview
            },
            getTransaction: { _ in
                return .previewInstance
            })
        )
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case destinationState(Destination.State)
        case continueButtonTapped
        case changed(StateType)
    }

    enum StateType: Equatable {
        case text(String)
        case toggle(Bool)
    }
    
    struct Events: AlwaysEquitable {
        var createConfirmReducerState: (Transaction1) async -> ConfirmReducer.State
        var getTransaction: (Amount) async throws -> Transaction1
    }
    
    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .changed(let type):
                switch type {
                case .text(let value):
                    state.amount = value
                case .toggle(let value):
                    if value {
                        state.amount = state.allAmount.description
                    } else {
                        state.amount = ""
                    }
                    state.isAllAmount = value
                }

                return .none

            case let .destinationState(destinationState):
                state.destination = destinationState
                
                return .none
            case .continueButtonTapped:
                return .run { [events = state.events, state] send in
                    let transaction = try await events.getTransaction(.init(address: state.address, amount: state.amount))
                    await send(.destinationState(.confirmView(await events.createConfirmReducerState(transaction))))
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

extension EnterAmountReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case confirmView(ConfirmReducer.State)

            var id: AnyHashable {
                switch self {
                case let .confirmView(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case confirmView(ConfirmReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.confirmView, action: /Action.confirmView) {
                ConfirmReducer()
            }
        }
    }
}
