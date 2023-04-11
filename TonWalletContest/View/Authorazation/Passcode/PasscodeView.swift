import SwiftUI
import ComposableArchitecture

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

struct ConfirmPasscodeView: View {
    let store: StoreOf<ConfirmPasscodeReducer>
    
    init(store: StoreOf<ConfirmPasscodeReducer>) {
        self.store = store
    }

    struct ViewState: Equatable {
        var passcode: String = ""
        var showKeyboad: Bool = true

        init(state: ConfirmPasscodeReducer.State) {
            self.passcode = state.passcode
            self.showKeyboad = state.showKeyboad
        }
    }

    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            VStack {
                Text("Confirm")
                ZStack {
                    TextField("", text: Binding(
                        get: { viewStore.passcode },
                        set: { viewStore.send(.passwordAdded(password: $0)) }
                    ))
                    .hidden()

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
                    .frame(width: 10, height: 0)
                }
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
