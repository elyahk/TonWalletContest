import SwiftUI
import ComposableArchitecture
import LocalAuthentication

struct LocalAuthenticationReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var imageName: String = "faceid"
        var title: String = "Enable Face ID"
        var description: String = "Face ID allows you to open your wallet faster without having to enter your password."
        var buttonTitle: String = "Enable Face ID"
        var events: Events
        
        init(events: Events) {
            self.events = events
            let context = LAContext()

            switch context.biometryType {
            case .faceID:
                self.imageName = "faceid"
                self.title = "Enable Face ID"
                self.description = "Face ID allows you to open your wallet faster without having to enter your password."
                self.buttonTitle = "Enable Face ID"
            case .touchID:
                self.imageName = "touchid"
                self.title = "Enable Touch ID"
                self.description = "Touch ID allows you to open your wallet faster without having to enter your password."
                self.buttonTitle = "Enable Touch ID"
            default:
                break
            }
        }
        
        static let preview: State = .init(events: .init(
            createReadyToGoReducerState: { .preview }
        ))
    }
    
    struct Events: AlwaysEquitable {
        var createReadyToGoReducerState: () async ->  ReadyToGoReducer.State
    }
    
    indirect enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case enableAuthenticationIDTapped
        case skipTapped
        case authenticated(success: Bool)
        case destinationState(Destination.State)
        
        enum Alert: Equatable {
            case dismiss
            case skip
        }
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .destinationState(destinationState):
                state.destination = destinationState
                return .none
                
            case .enableAuthenticationIDTapped:
                return .run { send in
                    let success = await authenticate()
                    await send(.authenticated(success: success))
                }
                
            case .skipTapped:
                return .run { [events = state.events] send in
                    await send(.destinationState(.readyToGo(await events.createReadyToGoReducerState())))
                }
               
            case let .authenticated(success):
                return .run {  [events = state.events] send in
                    if success {
                        await send(.destinationState(.readyToGo(await events.createReadyToGoReducerState())))
                    } else {
                        // state.destination = .alert()
                        #warning("Show alert")
                    }
                }
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
    
    func authenticate() async -> Bool {
        let context = LAContext()
        let reason = "We need to unlock your data."
        
        return (try? await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)) ?? false
    }
}

extension LocalAuthenticationReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case readyToGo(ReadyToGoReducer.State)
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
            case readyToGo(ReadyToGoReducer.Action)
            case alert(LocalAuthenticationReducer.Action.Alert)
        }
        
        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.readyToGo, action: /Action.readyToGo) {
                ReadyToGoReducer()
            }
        }
    }
}

