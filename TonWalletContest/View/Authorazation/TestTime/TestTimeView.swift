import SwiftUI
import ComposableArchitecture

struct TestTimeView: View {
    
    let store: StoreOf<TestTimeReducer>
    
    init(store: StoreOf<TestTimeReducer>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView {
                LottieView(name: "teacher", loop: .loop)
                    .frame(width: 124, height: 124, alignment: .center)
                Text("Test time!")
                    .fontWeight(.semibold)
                    .font(.title)
                    .padding()
                Text("Let’s check that you wrote them down correctly. Please enter the words 4, 15 and 18.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 30)
                #warning("we need to chang words number in a subheading")
                ForEach(viewStore.testWords.sorted(by: { $0.key < $1.key }), id: \.key) { (key, value) in
                    HStack {
                        Text("\(key). ")
                            .foregroundColor(.gray)
                            .padding(.vertical, 15)
                            .frame(width: 40, alignment: .trailing)
                        TextField("", text: Binding(get: { viewStore.state.word1 }, set: { value, _ in
                            viewStore.send(.wordChanged(type: .word1, value: value))
                        }))
                        #warning("Need to change wordChanged value to dict keys")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("LightGray"))
                    .cornerRadius(12)
                    .padding(.horizontal, 48)
                    .padding(.bottom, 10)
                }
                NavigationLink(
                    isActive: Binding(get: {
                        viewStore.state.passcode != nil
                    }, set: { isActive in
                        if isActive {
                            viewStore.send(.continueButtonTapped)
                        } else {
                            viewStore.send(.dismissPasscodeView)
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
