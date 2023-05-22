import SwiftUI
import SwiftyTON
import ComposableArchitecture

struct MainViewReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var events: Events
        @PresentationState var destination: Destination.State?
        var id: UUID = .init()
        var userWallet: UserSettings.UserWallet?
        var walletAddress: String = ""
        var transactions: [Transaction1] = []
        var transactionReducerState: TransactionReducer.State?

        static let preview: State = .init(
            events: .init(
                getLocalUserSettings: { nil },
                getUserWallet: { .preview },
                createRecieveTonReducerState: { .preview },
                createSendReducerState: { _ in .preview },
                createEnterAmountReducerState: { _, _, _ in .preview },
                createScanQRCodeReducerState: { .init(events: .init()) }
            )
        )
    }

    struct Events: AlwaysEquitable {
        var getLocalUserSettings: () async throws -> UserSettings?
        var getUserWallet: () async throws -> UserSettings.UserWallet
        var createRecieveTonReducerState: () async -> RecieveTonReducer.State
        var createSendReducerState: (UserSettings.UserWallet) async -> SendReducer.State
        var createEnterAmountReducerState: (String, String, UserSettings.UserWallet) async -> EnterAmountReducer.State
        var createScanQRCodeReducerState: () async -> ScanQRCodeReducer.State
    }

    enum Action: Equatable {
        case onAppear
        case configure(userWallet: UserSettings.UserWallet)
        case tappedRecieveButton
        case tappedSendButton
        case tappedBackButton
        case destinationState(Destination.State)
        case destination(PresentationAction<Destination.Action>)
        case transactionView(TransactionReducer.Action)
        case tappedTransaction(Transaction1)
        case tappedScanButton
        case tappedSettingsButton
        case openEnterAmountView(String, String)
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination(.presented(.scanQRCodeView(.scanSuccess(let address)))):

                return .run { send in
                    await send(.openEnterAmountView(address, ""))
                }
            case .tappedScanButton:

                return .run { [events = state.events] send in
                    await send(.destinationState(.scanQRCodeView(await events.createScanQRCodeReducerState())))
                }
            case .tappedSettingsButton:
                return .none
            case let .tappedTransaction(transaction):
                print("Transaction Tapped: \(transaction)")

                state.transactionReducerState = .init(transaction: transaction, isShowing: true, events: .init())
                return .none

            case let .transactionView(.sendTransaction(transaction)):
                state.transactionReducerState = nil

                return .run { send in
                    await send(.openEnterAmountView(transaction.destinationAddress, transaction.destinationShortAddress))
                }

            case let .openEnterAmountView(address, shortAddres):

                return .run { [events = state.events, state] send in
                    guard let userWallet = state.userWallet else { return }
                    var state = await events.createSendReducerState(userWallet)
                    state.address = address
                    state.destination = .enterAmountView(await events.createEnterAmountReducerState(address, shortAddres, userWallet))
                    await send(.destinationState(.sendView(state)))
                }

            case .transactionView(.doneButtonTapped):
                state.transactionReducerState = nil
                return .none

            case .transactionView:
                return .none

            case .tappedSendButton:

                return .run { [events = state.events, state] send in
                    guard let userWallet = state.userWallet else { return }
                    await send(.destinationState(.sendView(await events.createSendReducerState(userWallet))))
                }
            case .destinationState(let destinationState):
                state.destination = destinationState
                return .none
            case .onAppear:
                return .run { [events = state.events] send in
                    if let userSettings = try? await events.getLocalUserSettings() {
                        await send(.configure(userWallet: userSettings.userWallet))
                    }

                    let userWallet = try await events.getUserWallet()
                    await send(.configure(userWallet: userWallet))
                }

            case .tappedBackButton:
                state.destination = nil
                return .none
            case .tappedRecieveButton:

                return .run { [events = state.events] send in
                    await send(.destinationState(.recieveTonView(await events.createRecieveTonReducerState())))
                }

            case let .configure(userWallet):
                state.userWallet = userWallet

                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.transactionReducerState, action: /Action.transactionView) {
            TransactionReducer()
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
            case scanQRCodeView(ScanQRCodeReducer.State)

            var id: AnyHashable {
                switch self {
                case let .recieveTonView(state):
                    return state.id

                case let .sendView(state):
                    return state.id

                case let .scanQRCodeView(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case recieveTonView(RecieveTonReducer.Action)
            case sendView(SendReducer.Action)
            case scanQRCodeView(ScanQRCodeReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.recieveTonView, action: /Action.recieveTonView) {
                RecieveTonReducer()
            }
            Scope(state: /State.sendView, action: /Action.sendView) {
                SendReducer()
            }
            Scope(state: /State.scanQRCodeView, action: /Action.scanQRCodeView) {
                ScanQRCodeReducer()
            }
        }
    }
}
