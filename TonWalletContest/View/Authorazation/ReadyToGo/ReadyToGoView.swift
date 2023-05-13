import SwiftUI
import ComposableArchitecture

struct ReadyToGoView: View {
    let store: StoreOf<ReadyToGoReducer>

    init(store: StoreOf<ReadyToGoReducer>) {
        self.store = store
    }

    var body: some View {
        VStack {
            Spacer()
            LottieView(name: "crystal", loop: .playOnce)
                .frame(width: 124, height: 124, alignment: .center)
            Text("Ready to go!")
                .fontWeight(.semibold)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
            Text("You are all set. Now you have a wallet that only you control — directly, without middlemen or bankers.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            // Create My Wallet app
            NavigationLinkStore (
                self.store.scope(
                    state: \.$destination,
                    action: ReadyToGoReducer.Action.destination),
                state: /ReadyToGoReducer.Destination.State.wallet,
                action: ReadyToGoReducer.Destination.Action.wallet
            ) {
                ViewStore(store).send(.viewWalletButtonTapped)
            } destination: { store in
                MainView(store: store)
                    .navigationBarHidden(true)
            } label: {
                Text("View my wallet")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .padding([.leading, .trailing], 48)
                    .padding(.bottom, 124)
            }
        }
    }
}

struct ReadyToGoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReadyToGoView(store: .init(
                initialState: .init(events: .init(
                    createMainViewReducerState: { .preview })),
                reducer: ReadyToGoReducer()
            ))
        }
    }
}

