import ComposableArchitecture
import SwiftUI

struct ConfirmPasscodeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var oldPasscode: String
        var passcode: String = ""
        var showKeyboad: Bool = true
        @PresentationState var destination: Destination.State?
        var passcodes: [PasscodeReducer.Passcode] = [.empty, .empty, .empty, .empty]
    }
    
    enum Action: Equatable {
        case passwordAdded(password: String)
        case destination(PresentationAction<Destination.Action>)
        case onAppear
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .passwordAdded(passcode):
                state.passcode = passcode
                let count = passcode.count
                
                for (index, _) in state.passcodes.enumerated() {
                    state.passcodes[index] = index >= count ? .empty : .fill
                }
                
                if passcode.count == state.oldPasscode.count {
                    if passcode == state.oldPasscode {
                        state.showKeyboad = false
                        state.destination = .localAuthentication(.init())
                    } else {
                        return .run { await $0.send(.onAppear) }
                    }
                }
                
                
                return .none
                
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

extension ConfirmPasscodeReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case localAuthentication(LocalAuthenticationReducer.State)

            var id: AnyHashable {
                switch self {
                case let .localAuthentication(state):
                    return state.id
                }
            }
        }

        enum Action: Equatable {
            case localAuthentication(LocalAuthenticationReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.localAuthentication, action: /Action.localAuthentication) {
                LocalAuthenticationReducer()
            }
        }
    }
}

struct ConfirmPasscodeView: View {
    let store: StoreOf<ConfirmPasscodeReducer>
    
    init(store: StoreOf<ConfirmPasscodeReducer>) {
        self.store = store
    }
    
    struct ViewState: Equatable {
        var passcode: String = ""
        var showKeyboad: Bool = true
        var passcodes: [PasscodeReducer.Passcode]
        
        init(state: ConfirmPasscodeReducer.State) {
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
                        self.store.scope(state: \.$destination, action: ConfirmPasscodeReducer.Action.destination),
                        state: /ConfirmPasscodeReducer.Destination.State.localAuthentication,
                        action: ConfirmPasscodeReducer.Destination.Action.localAuthentication
                    ) {

                    } destination: { store in
                        LocalAuthenticationView(store: store)
                    } label: {
                        Color.clear
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

struct ConfirmPasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConfirmPasscodeView(store: .init(
                initialState: .init(oldPasscode: "1234"),
                reducer: ConfirmPasscodeReducer()
            ))
        }
    }
}
