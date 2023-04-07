import SwiftUI
import ComposableArchitecture

struct TestTimeView: View {
    
    let store: StoreOf<TestTimeReducer>
    
    init(store: StoreOf<TestTimeReducer>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                TextField("Title Key", text: Binding(get: { viewStore.state.word1 }, set: { value, _ in
                    viewStore.send(.wordChanged(type: .word1, value: value))
                }))
                
                TextField("Title Key", text: Binding(get: { viewStore.state.word2 }, set: { value, _ in
                    viewStore.send(.wordChanged(type: .word2, value: value))
                }))
                
                TextField("Title Key", text: Binding(get: { viewStore.state.word3 }, set: { value, _ in
                    viewStore.send(.wordChanged(type: .word3, value: value))
                }))
                
                NavigationLink(
                    isActive: Binding(get: {
                        viewStore.state.passcode != nil
                    }, set: { isActive in
                        if isActive {
                            viewStore.send(.continueButtonTapped)
                        } else {
                            
                        }
                    }),
                    destination: {
                        IfLetStore(
                            self.store.scope(state: \.passcode, action: TestTimeReducer.Action.passcode),
                            then: { viewStore in
                                PasscodeView(store: viewStore)
                            }
                        )
                    },
                    label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                            .customBlueButtonStyle()
                    }
                )
            }
            .onAppear {
                viewStore.send(.startTimer)
            }
        }
    }
}

struct TestTimeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestTimeView(store: .init(
                initialState: .init(
                    key: .demoKey,
                    words: .words24,
                    buildType: .preview
                ),
                reducer: TestTimeReducer()
            ))
        }
    }
}
