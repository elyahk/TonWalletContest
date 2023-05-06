import SwiftUI
import ComposableArchitecture
import SwiftyTON

struct RecieveTonReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var qrCodeImage: UIImage = .init()
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case viewWalletButtonTapped
        case onAppear
        case qrCodeCreated(image: UIImage)
        case walletCreated(wallet3: Wallet3)
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let image = await generateInvoiceQrCode(invoice: "UQBFz01R2CU7YA8pevUaNIYEzi1mRo4cX-r3W2Dwx-WEAoKP")
                    await send(.qrCodeCreated(image: image))
                }
            case .qrCodeCreated(image: let image):
                state.qrCodeImage = image
                return .none

            case .viewWalletButtonTapped:
                print("button tapped")

                return .run { send in
                    let key = try await TonKeyStore.shared.loadKey()
                    print("Key created")

                    if let key = key {
                        let wallet = try await TonWalletManager.shared.createWallet3(key: key)
                        print(wallet.contract.info)
                        await send(.walletCreated(wallet3: wallet))
                    }
                }

            case .walletCreated(let wallet3):
//                state.destination = .wallet(.init())

                return .none

            case .destination:
                return .none

            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

extension RecieveTonReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case wallet(MainViewReducer.State)

            var id: AnyHashable {
                switch self {
                case let .wallet(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case wallet(MainViewReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.wallet, action: /Action.wallet) {
                MainViewReducer()
            }
        }
    }
}


struct RecieveTonView: View {
    let store: StoreOf<RecieveTonReducer>

    init(store: StoreOf<RecieveTonReducer>) {
        self.store = store
    }

    var body: some View {
        VStack {
            Text("Receive Toncoin")
                .fontWeight(.semibold)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
                .padding(.top, 32)

            Text("Send only **Toncoin (TON)** to this address. Sending other coins may result in permanent loss.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 12.0)

            ZStack {
                WithViewStore(store, observe: { $0.qrCodeImage }) { viewStore in
                    Image(uiImage: viewStore.state)
                        .resizable()
                        .foregroundColor(.accentColor)
                        .frame(width: 220, height: 220)
                        .onAppear {
                            viewStore.send(.onAppear)
                        }

                    LottieView(name: "crystal", loop: .loop)
                        .frame(width: 50.0, height: 50.0)

                }
            }
            .frame(width: 220, height: 220)
            .padding(.top, 50)

            Spacer()
            Text("UQBFz01R2CU7YA8pevUaNIYEzi1mRo4cX-r3W2Dwx-WEAoKP")
                .multilineTextAlignment(.center)
                .font(.init(.custom("Mono", fixedSize: 17.0)))
                .padding(.horizontal, 40)

            Text("Your wallet address")
                .foregroundColor(.secondary)
                .font(.init(.system(size: 17.0, weight: .regular)))
                .padding(.horizontal, 40)
            Spacer()
            // Create My Wallet app
            NavigationLinkStore (
                self.store.scope(
                    state: \.$destination,
                    action: RecieveTonReducer.Action.destination),
                state: /RecieveTonReducer.Destination.State.wallet,
                action: RecieveTonReducer.Destination.Action.wallet
            ) {
                ViewStore(store).send(.viewWalletButtonTapped)
            } destination: { store in
                MainView(store: store)
            } label: {
                Label("Share Wallet Address", image: "ic_share")
                    .font(.init(.system(size: 17.0, weight: .semibold)))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .padding([.leading, .trailing], 48)
            }
        }
        .onAppear {
            UserDefaults.standard.set(AppState.walletCreated.rawValue , forKey: "state")
        }
    }
}

struct RecieveTonView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecieveTonView(store: .init(
                initialState: .init(),
                reducer: RecieveTonReducer()
            ))
        }
    }
}

