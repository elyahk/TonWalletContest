import SwiftUI
import ComposableArchitecture

struct TestTimeView: View {
    @State var showingAlert: Bool = false
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

                ForEach(viewStore.testWords) { word in
                    HStack {
                        Text("\(word.key). ")
                            .foregroundColor(.gray)
                            .padding(.vertical, 15)
                            .frame(width: 40, alignment: .trailing)
                        TextField("", text: Binding(
                            get: { word.recivedWord },
                            set: { value, _ in
                                viewStore.send(.wordChanged(id: word.id, value: value))
                            }
                        ))
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
                            showingAlert = true
                            viewStore.send(.continueButtonTapped)
                        } else if viewStore.passcode != nil {
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
            .alert(
                self.store.scope(state: \.alert, action: TestTimeReducer.Action.alert),
                dismiss: .dismiss
            )
        }
    }
}

struct TestTimeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestTimeView(store: .init(
                initialState: .init(testWords: [
                    .init(key: 5, expectedWord: "Hello"),
                    .init(key: 10, expectedWord: "Xaxa"),
                    .init(key: 14, expectedWord: "Tomorrow")
                ]),
                reducer: TestTimeReducer()
            ))
        }
    }
}

