import SwiftUI
import ComposableArchitecture

struct LocalAuthenticationReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var imageName: String = "faceid"
        var title: String = "Enable Face ID"
        var description: String = "Face ID allows you to open your wallet faster without having to enter your password."
        var buttonTitle: String = "Enable Face ID"
    }
    
    indirect enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case createNewWalletTapped
        case importWordsTapped
        
        enum Alert: Equatable {
            case dismiss
            case skip
        }
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .createNewWalletTapped:
                state.destination = .readyToGo(.init())
                
                return .none
                
            case .importWordsTapped:
                //                state.destination = .importWords(.init())
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

extension LocalAuthenticationReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case readyToGo(StartReducer.State)
            case alert(AlertState<LocalAuthenticationReducer.Action.Alert>)
            
            var id: AnyHashable {
                switch self {
                case let .readyToGo(state):
                    return state.id
                    
                case let .alert(state):
                    return state.id
                }
            }
        }
        
        enum Action: Equatable {
            case readyToGo(StartReducer.Action)
            case alert(LocalAuthenticationReducer.Action.Alert)
        }
        
        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.readyToGo, action: /Action.readyToGo) {
                StartReducer()
            }
        }
    }
}

