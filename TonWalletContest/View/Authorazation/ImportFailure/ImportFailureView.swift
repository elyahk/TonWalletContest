import SwiftUI
import ComposableArchitecture

struct ImportFailureView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var showingAlert: Bool = false
    let store: StoreOf<ImportFailureReducer>

    init(store: StoreOf<ImportFailureReducer>) {
        self.store = store
    }

    var body: some View {
        VStack {
            Spacer()
            LottieView(name: "sad", loop: .playOnce)
                .frame(width: 124, height: 124, alignment: .center)
            Text("Too Bad!")
                .fontWeight(.semibold)
                .font(.title)
                .padding(.bottom, 5)
            Text("Without the secret words you can’t restore access to the wallet.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            // Create My Wallet app
            Button {
                ViewStore(store).send(.importWordsTapped)
            } label: {
                Text("Enter 24 secret words")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 294, height: 50, alignment: .center)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .padding(.horizontal, 48)
            }

            NavigationLinkStore (
                self.store.scope(state: \.$destination, action: ImportFailureReducer.Action.destination),
                state: /ImportFailureReducer.Destination.State.createWallet,
                action: ImportFailureReducer.Destination.Action.createWallet
            ) {
                ViewStore(store).send(.createNewWalletTapped)
            } destination: { store in
                StartView(store: store)
                    .navigationBarBackButtonHidden()
            } label: {
                Text("Create a new empty wallet instead")
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                    .frame(minWidth: 294, minHeight: 50, alignment: .center)
                    .padding(.horizontal, 48)
            }
            .padding(.bottom, 30)
        }
    }
}

struct ImportFailureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImportFailureView(store: .init(
                initialState: .preview,
                reducer: ImportFailureReducer()
            ))
        }
    }
}

