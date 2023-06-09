import SwiftUI
import ComposableArchitecture

struct LocalAuthenticationView: View {
    let store: StoreOf<LocalAuthenticationReducer>

    struct ViewState: Equatable {
        var imageName: String
        var title: String
        var description: String
        var buttonTitle: String

        init(state: LocalAuthenticationReducer.State) {
            self.imageName = state.imageName
            self.title = state.title
            self.description = state.description
            self.buttonTitle = state.buttonTitle
        }
    }
    
    init(store: StoreOf<LocalAuthenticationReducer>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            VStack {
                Spacer()
                Image(systemName: viewStore.imageName)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.accentColor)
                    .padding()
                    .frame(width: 124, height: 124, alignment: .center)
                    .padding(.bottom, 20)
                Text(viewStore.title)
                    .fontWeight(.semibold)
                    .font(.title)
                    .padding(.bottom, 5)
                Text(viewStore.description)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                // Create My Wallet app
                Button {
                    viewStore.send(.enableAuthenticationIDTapped)
                } label: {
                    Text(viewStore.buttonTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 294, height: 50, alignment: .center)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                        .padding(.horizontal, 48)
                }
                
                NavigationLinkStore (
                    self.store.scope(state: \.$destination, action: LocalAuthenticationReducer.Action.destination),
                    state: /LocalAuthenticationReducer.Destination.State.readyToGo,
                    action: LocalAuthenticationReducer.Destination.Action.readyToGo
                ) {
                    viewStore.send(.skipTapped)
                } destination: { store in
                    ReadyToGoView(store: store)
                        .navigationBarHidden(true)
                } label: {
                    Text("Skip")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .frame(minWidth: 294, minHeight: 50, alignment: .center)
                        .padding(.horizontal, 48)
                }
                .padding(.bottom, 30)
            }
            .alert(
                self.store.scope(
                    state: { guard case let .alert(state) = $0.destination else { return nil }
                        return state
                    },
                    action: { LocalAuthenticationReducer.Action.destination(.presented(.alert($0)))}
                ),
                dismiss: .dismiss
            )
        }
    }
}

struct FaceAndTouchIDView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocalAuthenticationView(store: .init(
                initialState: .preview,
                reducer: LocalAuthenticationReducer()
            ))
        }
    }
}

