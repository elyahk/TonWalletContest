import ComposableArchitecture
import SwiftyTON
import Foundation

struct UserSettings: Equatable, Codable {
    var userWallet: UserWallet
    var key: Key
    var wallet: Wallet3

    struct UserWallet: Equatable, Codable {
        var allAmmount: Double
        var address: String
        var transactions: [Transaction1]

        static let preview: UserWallet = .init(allAmmount: 2.00333, address: "AsfdsfsdSDFSdfsDfsdfsD", transactions: [.previewInstance, .previewInstance])
    }

    static let preview: UserSettings = .init(userWallet: .preview, key: .demoKey, wallet: .demoWallet)
}

struct EnterAmountReducer: ReducerProtocol {
    struct Amount: Equatable {
        var address: String
        var amount: String
    }

    struct State: Equatable, Identifiable {
        var recieverAddress: String
        var recieverShortAddress: String
        var userWallet: UserSettings.UserWallet
        var events: Events
        var amount: String = "20.33232"
        var isAllAmount = false
        var isLoading: Bool = false

        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        
        init(reciverAddress: String, recieverShortAddress: String = "", userWallet: UserSettings.UserWallet, destination: Destination.State? = nil, events: Events) {
            self.recieverAddress = reciverAddress
            self.recieverShortAddress = recieverShortAddress
            self.userWallet = userWallet
            self.destination = destination
            self.events = events
        }

        static let preview: State = .init(
            reciverAddress: "RasdfsfSDfssdfsdfsDD",
            userWallet: .init(allAmmount: 44.0, address: "SDfsdfsdfsdfsdSDFsS", transactions: []),
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
        case loading(Bool)
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
            case let .loading(isLoading):
                state.isLoading = isLoading
                return .none
            case .changed(let type):
                switch type {
                case .text(let value):
                    state.amount = value
                case .toggle(let value):
                    if value {
                        state.amount = state.userWallet.allAmmount.description
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
                guard !state.isLoading else { return .none }

                return .run { [events = state.events, state] send in
                    await send(.loading(true))
                    let transaction = try await events.getTransaction(.init(address: state.recieverAddress, amount: state.amount))
                    await send(.destinationState(.confirmView(await events.createConfirmReducerState(transaction))))
                    await send(.loading(false))
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
