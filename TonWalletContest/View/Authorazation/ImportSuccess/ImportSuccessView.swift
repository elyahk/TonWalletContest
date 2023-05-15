import SwiftUI
import ComposableArchitecture

struct ImportSuccessView: View {
    let store: StoreOf<ImportSuccessReducer>

    init(store: StoreOf<ImportSuccessReducer>) {
        self.store = store
    }

    var body: some View {
        VStack {
            Spacer()
            LottieView(name: "boomstick", loop: .playOnce)
                .frame(width: 124, height: 124, alignment: .center)
            Text("Your wallet has just been imported!")
                .fontWeight(.semibold)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
            Spacer()
            
            NavigationLinkStore(
                self.store.scope(state: \.$destination, action: ImportSuccessReducer.Action.destination),
                state: /ImportSuccessReducer.Destination.State.mainView,
                action: ImportSuccessReducer.Destination.Action.mainView
            ) {
                ViewStore(store).send(.viewWalletButtonTapped)
            } destination: { store in
                MainView(store: store)
                    .navigationBarBackButtonHidden()
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

struct ImportSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImportSuccessView(store: .init(
                initialState: .preview,
                reducer: ImportSuccessReducer()
            ))
        }
    }
}

