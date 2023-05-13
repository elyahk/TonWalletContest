import SwiftUI
import ComposableArchitecture

struct PasscodeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        @PresentationState var destination: Destination.State?
        var events: Events
        var id: UUID = .init()
        var passcode: String = ""
        var showKeyboad: Bool = true
        var passcodes: [Passcode] = [.empty, .empty, .empty, .empty]
        
        init(destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.events = events
        }
        
        static let preview: State = .init(events: .init(
            createConfirmPasscodeReducerState: { _ in .preview }
        ))
    }
    
    struct Events: AlwaysEquitable {
        var createConfirmPasscodeReducerState: (String) async ->  ConfirmPasscodeReducer.State
    }
    
    enum Passcode: Hashable {
        case empty
        case fill
    }
    
    enum Action: Equatable {
        case passwordAdded(password: String)
        case destination(PresentationAction<Destination.Action>)
        case showConfirm(oldPasscode: String)
        case destinationState(Destination.State)
        case onAppear
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .destinationState(destinationState):
                state.destination = destinationState
                return .none
                
            case let .passwordAdded(passcode):
                state.passcode = passcode
                let count = passcode.count
                
                for (index, _) in state.passcodes.enumerated() {
                    state.passcodes[index] = index >= count ? .empty : .fill
                }
                
                if passcode.count == 4 {
                    state.showKeyboad = false
                    
                    return .run { send in
                        try await Task.sleep(nanoseconds: 200_000_000)
                        await send(.showConfirm(oldPasscode: passcode))
                    }
                }
                
                return .none
                
            case let .showConfirm(oldPasscode):
                return .run { [events = state.events] send in
                    await send(.destinationState(
                        .confirmPasscode(await events.createConfirmPasscodeReducerState(oldPasscode))
                    ))
                }
                
            case .onAppear:
                state.showKeyboad = true
                state.passcode = ""
                state.passcodes = [.empty, .empty, .empty, .empty]
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

extension PasscodeReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case confirmPasscode(ConfirmPasscodeReducer.State)
            
            var id: AnyHashable {
                switch self {
                case let .confirmPasscode(state):
                    return state.id
                }
            }
        }
        
        enum Action: Equatable {
            case confirmPasscode(ConfirmPasscodeReducer.Action)
        }
        
        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.confirmPasscode, action: /Action.confirmPasscode) {
                ConfirmPasscodeReducer()
            }
        }
    }
}



struct PasscodeView: View {
    let store: StoreOf<PasscodeReducer>
    
    init(store: StoreOf<PasscodeReducer>) {
        self.store = store
    }
    
    struct ViewState: Equatable {
        var passcode: String = ""
        var showKeyboad: Bool = true
        var passcodes: [PasscodeReducer.Passcode]
        
        init(state: PasscodeReducer.State) {
            self.passcode = state.passcode
            self.showKeyboad = state.showKeyboad
            self.passcodes = state.passcodes
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            ZStack {
                LegacyTextField(
                    text: Binding(
                        get: { viewStore.passcode },
                        set: { value, _ in
                            viewStore.send(.passwordAdded(password: value))
                        }),
                    isFirstResponder: Binding(
                        get: { viewStore.showKeyboad },
                        set: { value, _ in
                            
                        })
                )
                .keyboardType(.numberPad)
                .frame(width: 20, height: 20)
                .background(Color.clear)
                .foregroundColor(.clear)
                
                VStack {
                    Spacer()
                    LottieView(name: "password", loop: .playOnce)
                        .frame(width: 124, height: 124, alignment: .center)
                        .padding([.top], 46)
                    Text("Set a Passcode")
                        .fontWeight(.semibold)
                        .font(.title)
                        .padding(.top, 20)
                    Text("Enter the 4 digits in the passcode.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                    
                    HStack {
                        ForEach(viewStore.passcodes, id: \.self) { passcode in
                            Image(systemName: passcode == .empty ? "circle" : "circle.fill")
                                .resizable()
                                .foregroundColor(passcode == .empty ? .secondary : .black)
                                .frame(width: 16, height: 16)
                        }
                    }
                    .padding(.top, 40)
                    
                    NavigationLinkStore(
                        self.store.scope(state: \.$destination, action: PasscodeReducer.Action.destination),
                        state: /PasscodeReducer.Destination.State.confirmPasscode,
                        action: PasscodeReducer.Destination.Action.confirmPasscode
                    ) {
                        
                    } destination: { store in
                        ConfirmPasscodeView(store: store)
                    } label: {
                        Color.clear
                    }
                    
                    Button {
                        
                    } label: {
                        Text("Passcode options")
                            .frame(height: 48)
                            .padding(.bottom, 8)
                    }
                    
                }
                .background(Color.white)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}


struct PasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasscodeView(store: .init(
                initialState: .preview,
                reducer: PasscodeReducer()
            ))
        }
    }
}
