import ComposableArchitecture
import SwiftyTON
import Foundation

struct SendReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var userWallet: UserSettings.UserWallet
        var events: Events
        @PresentationState var destination: Destination.State?
        var id: UUID = .init()
        var address: String = ""
        var transactions: [Transaction1]
        var isLoading: Bool = false

        init(userWallet: UserSettings.UserWallet, destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.events = events
            self.userWallet = userWallet
            self.transactions = userWallet.transactions
        }

        static let preview: State = .init(
            userWallet: .preview,
            events: .init(
                createEnterAmountReducerState: { _, _, _ in .preview }
            )
        )
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case continueButtonTapped
        case editButtonTapped
        case destinationState(Destination.State)
        case changedAddress(String)
        case clearTransactions
        case changeAddress(String)
        case loading(Bool)
    }

    struct Events: AlwaysEquitable {
        var createEnterAmountReducerState: (String, String, UserSettings.UserWallet) async ->  EnterAmountReducer.State
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .loading(let isLoading):
                state.isLoading = isLoading
                return .none

            case .editButtonTapped:

                return .run { _ in
                    await dismiss()
                }
            case .changeAddress(let text):
                state.address = text
                return .none
            case .clearTransactions:
                state.transactions.removeAll()
                return .none
            case let .changedAddress(address):
                state.address = address
                return .none

            case let .destinationState(destinationState):
                state.destination = destinationState

                return .none
            case .continueButtonTapped:
                guard !state.isLoading else { return .none}

                return .run { [events = state.events, state] send in
                    await send(.loading(true))
                    await send(.destinationState(.enterAmountView(await events.createEnterAmountReducerState(state.address, "", state.userWallet))))
                    await send(.loading(false))
                }
            case .destination(.presented(.enterAmountView(.destination(.presented(.confirmView(.destination(.presented(.pendingView(.doneButtonTapped))))))))):
                return .run { send in
                    await dismiss()
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
