import ComposableArchitecture
import SwiftyTON
import Foundation

struct PendingReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var walletAddress: String
        @PresentationState var destination: Destination.State?
        var events: Events
        
        init(walletAddress: String, destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.walletAddress = walletAddress
            self.events = events
        }
        
        static let preview: State = .init(walletAddress: "WalletAsdfdfdsfsdf", events: .init())
    }
    
    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case destinationState(Destination.State)
        case doneButtonTapped
    }
    
    struct Events: AlwaysEquitable {
    }
    
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .destinationState(destinationState):
                state.destination = destinationState
                
                return .none
            case .doneButtonTapped:
                return .run { _ in
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

extension PendingReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case successView(SuccessReducer.State)

            var id: AnyHashable {
                switch self {
                case let .successView(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case successView(SuccessReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.successView, action: /Action.successView) {
                SuccessReducer()
            }
        }
    }
}

