import ComposableArchitecture
import SwiftyTON
import Foundation

struct ImportSuccessReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var events: Events
        
        init(destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.events = events
        }
        
        static let preview: State = .init(
            events: .init(
                createMainViewReducerState: { .preview }
            )
        )
    }
    
    struct Events: AlwaysEquitable {
        var createMainViewReducerState: () async -> MainViewReducer.State
    }
    
    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case destinationState(Destination.State)
        case viewWalletButtonTapped
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .destinationState(let destinationState):
                state.destination = destinationState
                return .none
                
            case .viewWalletButtonTapped:
                
                return .run { [events = state.events] send in
                    await send(.destinationState(.mainView(await events.createMainViewReducerState())))
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

extension ImportSuccessReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case mainView(MainViewReducer.State)
            
            var id: AnyHashable {
                switch self {
                case let .mainView(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case mainView(MainViewReducer.Action)
        }
        
        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.mainView, action: /Action.mainView) {
                MainViewReducer()
            }
        }
    }
}
