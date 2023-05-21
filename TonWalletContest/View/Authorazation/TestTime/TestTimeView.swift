import SwiftUI
import ComposableArchitecture

struct TestTimeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var showingAlert: Bool = false
    let store: StoreOf<TestTimeReducer>
    
    init(store: StoreOf<TestTimeReducer>) {
        self.store = store
    }

    struct ViewState: Equatable {
        var testWords: IdentifiedArrayOf<TestTimeReducer.Word>
        var presentableTestNumbers: String

        init(state: TestTimeReducer.State) {
            self.testWords = state.testWords
            self.presentableTestNumbers = state.presentableTestNumbers
        }
    }

    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            ScrollView {
                LottieView(name: "teacher", loop: .loop)
                    .frame(width: 124, height: 124, alignment: .center)
                    .padding(.top, 46)
                Text("Test time!")
                    .fontWeight(.semibold)
                    .font(.title)
                    .padding()
                Text("Let’s check that you wrote them down correctly. Please enter the words \(viewStore.presentableTestNumbers).")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 30)

                ForEach(viewStore.testWords) { word in
                    HStack {
                        Text("\(word.key + 1). ")
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

                NavigationLinkStore(
                    self.store.scope(state: \.$destination, action: TestTimeReducer.Action.destination),
                    state: /TestTimeReducer.Destination.State.passcode,
                    action: TestTimeReducer.Destination.Action.passcode
                ) {
                    viewStore.send(.continueButtonTapped)
                } destination: { store in
                    PasscodeView(store: store)
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                        .customBlueButtonStyle()
                        .padding(.horizontal, 48)
                }

                Button("Auto fill") {
                    viewStore.send(.autoFillCorrectWords)
                }
            }
            .alert(
                self.store.scope(
                    state: { guard case let .alert(state) = $0.destination else { return nil }
                        return state
                    },
                    action: { TestTimeReducer.Action.destination(.presented(.alert($0)))}
                ),
                dismiss: .dismiss
            )
        }
    }
}

struct TestTimeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestTimeView(store: .init(
                initialState: .preview,
                reducer: TestTimeReducer()
            ))
        }
    }
}

