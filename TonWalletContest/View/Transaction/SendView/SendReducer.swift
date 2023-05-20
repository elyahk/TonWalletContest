import ComposableArchitecture
import SwiftyTON
import Foundation

struct SendReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var transactions: [Transaction]
        var address: String = ""

        var events: Events

        init(transactions: [Transaction], destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.events = events
            self.transactions = transactions
        }

        static let preview: State = .init(
            transactions:  [
                Transaction(senderAddress: "wedo3irjwljOj)J09JH0j9josdijfo394", humanAddress: "EldorTheCoolest.ton", amount: 1.2, comment: "", fee: 0.0023123, date: .init(), status: .pending, isTransactionSend: true, transactionId: "dsdf"),
                Transaction(senderAddress: "wedo3irjwljOj)J09JH0j9josdijfo394", humanAddress: "GoingCrazy.ton", amount: 110.2, comment: "", fee: 0.23123, date: .init().addingTimeInterval(86400 * 5), status: .cancelled, isTransactionSend: false, transactionId: "SDFsdfwr23r23w"),
                Transaction(senderAddress: "wedo3irjwljOj)J09JH0j9josdijfo394", humanAddress: "", amount: 110.2, comment: "", fee: 0.23123, date: .init().addingTimeInterval(86400), status: .success, isTransactionSend: true, transactionId: "ASDA23er23dsad23")
            ],
            events: .init(
                createEnterAmountReducerState: { .preview }
            )
        )
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case viewWalletButtonTapped
        case destinationState(Destination.State)
        case changedAddress(String)
    }

    struct Events: AlwaysEquitable {
        var createEnterAmountReducerState: () async ->  EnterAmountReducer.State
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .changedAddress(address):
                state.address = address
                return .none

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
