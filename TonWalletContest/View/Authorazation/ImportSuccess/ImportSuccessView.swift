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
            // Create My Wallet app
            NavigationLinkStore (
                self.store.scope(state: \.$destination, action: ImportSuccessReducer.Action.destination)
            ) {

            } destination: { store in
                Text("New page")
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
                initialState: .init(),
                reducer: ImportSuccessReducer()
            ))
        }
    }
}

