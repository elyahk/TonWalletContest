import SwiftUI
import ComposableArchitecture

struct PasscodeView: View {
    let store: StoreOf<PasscodeReducer>
    @State var show: Bool = false
    
    init(store: StoreOf<PasscodeReducer>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                NavigationLink(
                    isActive: Binding(get: {
                        viewStore.state.confirmPasscode != nil
                    }, set: { _ in }),
                    destination: {
                        IfLetStore(self.store.scope(
                            state: \.confirmPasscode, action: PasscodeReducer.Action.confirmPasscode)) { store in
                                ConfirmPasscodeView(store: store)
                            }
                    },
                    label: {
                        Color.clear
                    }
                )

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
//                    .hidden()

//                    Button("Title") {
//                        sdf
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: 60)
//                    .background(Color.green)
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
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
//                NavigationLink(
//                    isActive: Binding(get: {
//                        viewStore.state.confirmPasscode != nil
//                    }, set: { _ in }),
//                    destination: {
//                        PasscodeView(store: .init(
//                            initialState: viewStore.state, reducer: PasscodeReducer()))
//                    },
//                    label: {
//                        Color.clear
//                    }
//                )

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
//                    .hidden()

//                    Button("Title") {
//                        sdf
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: 60)
//                    .background(Color.green)
                }
                
                Button("Options") { }
            }
        }
    }
}


struct PasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasscodeView(store: .init(
                initialState: .init(
                    key: .demoKey,
                    words: .words24
                ),
                reducer: PasscodeReducer()
            ))
        }
    }
}
