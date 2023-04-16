import SwiftUI
import ComposableArchitecture

struct ImportFailureView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var showingAlert: Bool = false
    let store: StoreOf<ImportFailureReducer>

    init(store: StoreOf<ImportFailureReducer>) {
        self.store = store
    }

    struct ViewState: Equatable {
        var testWords: IdentifiedArrayOf<ImportFailureReducer.Word>

        init(state: ImportFailureReducer.State) {
            self.testWords = state.testWords
        }
    }

    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            ScrollView {
                LottieView(name: "list", loop: .loop)
                    .frame(width: 124, height: 124, alignment: .center)
                Text("24 Secret Words")
                    .fontWeight(.semibold)
                    .font(.title)
                    .padding()
                Text("You can restore access to your wallet by entering 24 words you wrote when down you creating the wallet.")
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

                NavigationLinkStore(
                    self.store.scope(state: \.$destination, action: ImportFailureReducer.Action.destination),
                    state: /ImportFailureReducer.Destination.State.passcode,
                    action: ImportFailureReducer.Destination.Action.passcode
                ) {
                    viewStore.send(.continueButtonTapped)
                } destination: { store in
                    PasscodeView(store: store)
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                        .customBlueButtonStyle()
                }
            }
            .alert(
                self.store.scope(
                    state: { guard case let .alert(state) = $0.destination else { return nil }
                        return state
                    },
                    action: { ImportFailureReducer.Action.destination(.presented(.alert($0)))}
                ),
                dismiss: .dismiss
            )
        }
    }
}

struct ImportFailureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImportFailureView(store: .init(
                initialState: .init(),
                reducer: ImportFailureReducer()
            ))
        }
    }
}
