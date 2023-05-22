import SwiftUI
import SwiftyTON
import ComposableArchitecture

struct MainViewReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var events: Events
        @PresentationState var destination: Destination.State?
        var id: UUID = .init()
        var userWallet: UserWalletSettings.UserWallet?
        var walletAddress: String = ""
        var transactions: [Transaction1] = []
        var transactionReducerState: TransactionReducer.State?
        var timer: Int = 0
        var balance: Double = 0.0

        static let preview: State = .init(
            events: .init(
                getLocalUserSettings: { nil },
                getUserWallet: { .preview },
                createRecieveTonReducerState: { .preview },
                createSendReducerState: { _ in .preview },
                createEnterAmountReducerState: { _, _, _ in .preview },
                createScanQRCodeReducerState: { .init(events: .init()) },
                createSettingsReducerState: { .preview }
            )
        )
    }

    struct Events: AlwaysEquitable {
        var getLocalUserSettings: () async throws -> UserWalletSettings?
        var getUserWallet: () async throws -> UserWalletSettings.UserWallet
        var createRecieveTonReducerState: () async -> RecieveTonReducer.State
        var createSendReducerState: (UserWalletSettings.UserWallet) async -> SendReducer.State
        var createEnterAmountReducerState: (String, String, UserWalletSettings.UserWallet) async -> EnterAmountReducer.State
        var createScanQRCodeReducerState: () async -> ScanQRCodeReducer.State
        var createSettingsReducerState: () async throws -> SettingsReducer.State
    }

    enum Action: Equatable {
        case onAppear
        case configure(userWallet: UserWalletSettings.UserWallet)
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
        case startTimer
        case updateTimer
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .updateTimer:
                state.timer += 1
                return .none
            case .startTimer:
                return .run { [events = state.events] send in
                    print("Timer")
                    do {
                        let userWallet = try await events.getUserWallet()
                        await send(.configure(userWallet: userWallet))
                    } catch {
                    }
                    try await Task.sleep(nanoseconds: 15_000_000_000)
                    await send(.updateTimer)
                }
            case .destination(.presented(.scanQRCodeView(.scanSuccess(let address)))):

                return .run { send in
                    await send(.openEnterAmountView(address, ""))
                }
            case .tappedScanButton:

                return .run { [events = state.events] send in
                    await send(.destinationState(.scanQRCodeView(await events.createScanQRCodeReducerState())))
                }
            case .tappedSettingsButton:

                return .run { [events = state.events] send in
                    await send(.destinationState(.settingsView(try await events.createSettingsReducerState())))
                }
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
                state.timer += 1
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
                state.balance = userWallet.allAmmount ?? 0.0

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
            case settingsView(SettingsReducer.State)

            var id: AnyHashable {
                switch self {
                case let .recieveTonView(state):
                    return state.id

                case let .sendView(state):
                    return state.id

                case let .scanQRCodeView(state):
                    return state.id
                case let .settingsView(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case recieveTonView(RecieveTonReducer.Action)
            case sendView(SendReducer.Action)
            case scanQRCodeView(ScanQRCodeReducer.Action)
            case settingsView(SettingsReducer.Action)
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
            Scope(state: /State.settingsView, action: /Action.settingsView) {
                SettingsReducer()
            }
        }
    }
}
