import SwiftUI
import SwiftyTON
import ComposableArchitecture

struct MainViewReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var balance: String = ""
        var walletAddress: String = ""
        var events: Events
        var transactions: [Transaction1] = []

        static let preview: State = .init(
            events: .init(
                getBalance: { "2.333333" },
                getWalletAddress: { "WalletAddressWaxaxaxaxaxaxa"},
                getTransactions: { [
                    .init(senderAddress: "Sender address", humanAddress: "Human Address", amount: 1.0, comment: "Comment", fee: 0.0005, date: .init(), status: .cancelled, isTransactionSend: true, transactionId: "s23e|@e2"),
                    .previewInstance,
                    .previewInstance,
                    .previewInstance,
                    .previewInstance
                ] },
                createRecieveTonReducerState: { .preview },
                createSendReducerState: { .preview }
            )
        )
    }

    struct Events: AlwaysEquitable {
        var getBalance: () async -> String
        var getWalletAddress: () async -> String
        var getTransactions: () async throws -> [Transaction1]
        var createRecieveTonReducerState: () async -> RecieveTonReducer.State
        var createSendReducerState: () async -> SendReducer.State
    }

    enum Action: Equatable {
        case onAppear
        case configure(balance: String, address: String, transactions: [Transaction1])
        case tappedRecieveButton
        case tappedSendButton
        case tappedBackButton
        case destinationState(Destination.State)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .tappedSendButton:

                return .run { [events = state.events] send in
                    await send(.destinationState(.sendView(await events.createSendReducerState())))
                }
            case .destinationState(let destinationState):
                state.destination = destinationState
                return .none
            case .onAppear:
                return .run { [events = state.events] send in
                    let balance = await events.getBalance()
                    let address = await events.getWalletAddress()
                    let transactions = try await events.getTransactions()

                    await send(.configure(balance: balance, address: address, transactions: transactions))
                }

            case .tappedBackButton:
                state.destination = nil
                return .none
            case .tappedRecieveButton:

                return .run { [events = state.events] send in
                    await send(.destinationState(.recieveTonView(await events.createRecieveTonReducerState())))
                }

            case let .configure(balance, address, transactions):
                state.balance = balance
                state.walletAddress = address
                state.transactions = transactions

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

extension MainViewReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case recieveTonView(RecieveTonReducer.State)
            case sendView(SendReducer.State)

            var id: AnyHashable {
                switch self {
                case let .recieveTonView(state):
                    return state.id

                case let .sendView(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case recieveTonView(RecieveTonReducer.Action)
            case sendView(SendReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.recieveTonView, action: /Action.recieveTonView) {
                RecieveTonReducer()
            }
            Scope(state: /State.sendView, action: /Action.sendView) {
                SendReducer()
            }
        }
    }
}
