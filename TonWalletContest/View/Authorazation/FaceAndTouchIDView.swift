import SwiftUI
import ComposableArchitecture

struct FaceAndTouchIDReducer: ReducerProtocol {
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

extension FaceAndTouchIDReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case readyToGo(StartReducer.State)
            case alert(AlertState<FaceAndTouchIDReducer.Action.Alert>)
            
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
            case alert(FaceAndTouchIDReducer.Action.Alert)
        }
        
        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.readyToGo, action: /Action.readyToGo) {
                StartReducer()
            }
        }
    }
}

struct FaceAndTouchIDView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var showingAlert: Bool = false
    let store: StoreOf<FaceAndTouchIDReducer>
    
    init(store: StoreOf<FaceAndTouchIDReducer>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            VStack {
                Spacer()
                Image(systemName: viewStore.imageName)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.accentColor)
                    .padding()
                    .frame(width: 124, height: 124, alignment: .center)
                    .padding(.bottom, 20)
                Text(viewStore.title)
                    .fontWeight(.semibold)
                    .font(.title)
                    .padding(.bottom, 5)
                Text(viewStore.description)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                // Create My Wallet app
                Button {
                    print("")
                } label: {
                    Text(viewStore.buttonTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 294, height: 50, alignment: .center)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                        .padding(.horizontal, 48)
                }
                
                NavigationLinkStore (
                    self.store.scope(state: \.$destination, action: FaceAndTouchIDReducer.Action.destination),
                    state: /FaceAndTouchIDReducer.Destination.State.readyToGo,
                    action: FaceAndTouchIDReducer.Destination.Action.readyToGo
                ) {
                    ViewStore(store).send(.importWordsTapped)
                } destination: { store in
                    StartView(store: store)
                } label: {
                    Text("Skip")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .frame(minWidth: 294, minHeight: 50, alignment: .center)
                        .padding(.horizontal, 48)
                }
                .padding(.bottom, 30)
            }
            .alert(
                self.store.scope(
                    state: { guard case let .alert(state) = $0.destination else { return nil }
                        return state
                    },
                    action: { FaceAndTouchIDReducer.Action.destination(.presented(.alert($0)))}
                ),
                dismiss: .dismiss
            )
        }
    }
}

struct FaceAndTouchIDView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FaceAndTouchIDView(store: .init(
                initialState: .init(),
                reducer: FaceAndTouchIDReducer()
            ))
        }
    }
}

