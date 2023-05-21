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

        static let preview: State = .init(
            events: .init(
                getUserWallet: { .preview },
                createRecieveTonReducerState: { .preview },
                createSendReducerState: { _ in .preview }
            )
        )
    }

    struct Events: AlwaysEquitable {
        var getUserWallet: () async throws -> UserSettings.UserWallet
        var createRecieveTonReducerState: () async -> RecieveTonReducer.State
        var createSendReducerState: (UserSettings.UserWallet) async -> SendReducer.State
    }

    enum Action: Equatable {
        case onAppear
        case configure(userWallet: UserSettings.UserWallet)
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

                return .run { [events = state.events, state] send in
                    guard let userWallet = state.userWallet else { return }
                    await send(.destinationState(.sendView(await events.createSendReducerState(userWallet))))
                }
            case .destinationState(let destinationState):
                state.destination = destinationState
                return .none
            case .onAppear:
                return .run { [events = state.events] send in
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
