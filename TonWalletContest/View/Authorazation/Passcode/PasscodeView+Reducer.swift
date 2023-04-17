import SwiftUI
import ComposableArchitecture

struct PasscodeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var passcode: String = ""
        var showKeyboad: Bool = true
        @PresentationState var confirmPasscode: ConfirmPasscodeReducer.State?
    }

    enum Action: Equatable {
        case passwordAdded(password: String)
        case confirmPasscode(PresentationAction<ConfirmPasscodeReducer.Action>)
        case showConfirm(oldPasscode: String)
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .passwordAdded(passcode):
                state.passcode = passcode
                if passcode.count == 4 {
                    state.showKeyboad = false

                    return .run { send in
                        try await Task.sleep(nanoseconds: 200_000_000)
                        await send(.showConfirm(oldPasscode: passcode))
                    }
                }

                return .none

            case let .showConfirm(oldPasscode):
                state.confirmPasscode = .init(oldPasscode: oldPasscode)
                return .none

            case .confirmPasscode(.dismiss):
                state.passcode = ""
                state.showKeyboad = true

                return .none

            case .confirmPasscode:
                return .none
            }
        }
        .ifLet(\.$confirmPasscode, action: /Action.confirmPasscode) {
            ConfirmPasscodeReducer()
        }
    }
}


struct PasscodeView: View {
    let store: StoreOf<PasscodeReducer>
    @State var show: Bool = false
    
    init(store: StoreOf<PasscodeReducer>) {
        self.store = store
    }

    struct ViewState: Equatable {
        var passcode: String = ""
        var showKeyboad: Bool = true

        init(state: PasscodeReducer.State) {
            self.passcode = state.passcode
            self.showKeyboad = state.showKeyboad
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
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
                    Image(systemName: "circle")
                        .resizable()
                        .foregroundColor(Color.secondary)
                        .frame(width: 16, height: 16)
                    Image(systemName: "circle")
                        .resizable()
                        .foregroundColor(Color.secondary)
                        .frame(width: 16, height: 16)
                    Image(systemName: "circle")
                        .resizable()
                        .foregroundColor(Color.secondary)
                        .frame(width: 16, height: 16)
                    Image(systemName: "circle")
                        .resizable()
                        .foregroundColor(Color.secondary)
                        .frame(width: 16, height: 16)
                }
                .padding(.top, 40)

                NavigationLinkStore(
                    self.store.scope(state: \.$confirmPasscode, action: PasscodeReducer.Action.confirmPasscode)
                ) {
                } destination: { store in
                    ConfirmPasscodeView(store: store)
                } label: {
                    Color.clear
                }

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
                    .frame(width: 10, height: 0)
                }
                
                Button("Options") {
                    show = true
                }
            }
            .sheet(isPresented: $show) {
                Text("Sheet")
            }
        }
    }
}


struct PasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasscodeView(store: .init(
                initialState: .init(),
                reducer: PasscodeReducer()
            ))
        }
    }
}
