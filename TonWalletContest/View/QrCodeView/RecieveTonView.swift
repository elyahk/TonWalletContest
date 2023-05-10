import SwiftUI
import ComposableArchitecture
import SwiftyTON
import UIKit

// 1. Activity View
struct ActivityView: UIViewControllerRepresentable, ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()


    }
    enum Action: Equatable {
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            return .none
        }
    }

    let text: String

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {
        uiViewController.view.backgroundColor = .clear
    }
}

// 2. Share Text
struct ShareText: Identifiable {
    let id = UUID()
    let text: String
}


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
                state.destination = .shareView(.init())
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
            case invoice(TestReducer.State)
            case shareView(ActivityView.State)

            var id: AnyHashable {
                switch self {
                case let .invoice(state):
                    return state.id
                case let .shareView(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case invoice(TestReducer.Action)
            case shareView(ActivityView.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.invoice, action: /Action.invoice) {
                TestReducer()
            }
        }
    }
}


struct RecieveTonView: View {
    let store: StoreOf<RecieveTonReducer>
    @State var showSheet: Bool = false

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
            //            ShareLink(item: URL(string: "https://developer.apple.com/xcode/swiftui/")!) {
            //                Label("Share Wallet Address", image: "ic_share")
            //                    .font(.init(.system(size: 17.0, weight: .semibold)))
            //                    .foregroundColor(.white)
            //                    .frame(maxWidth: .infinity, maxHeight: 50)
            //                    .background(Color.accentColor)
            //                    .cornerRadius(12)
            //                    .padding([.leading, .trailing], 48)
            //            }
//            NavigationLinkStore (
//                self.store.scope(
//                    state: \.$destination,
//                    action: RecieveTonReducer.Action.destination),
//                state: /RecieveTonReducer.Destination.State.shareView,
//                action: RecieveTonReducer.Destination.Action.shareView
//            ) {
//                ViewStore(store).send(.viewWalletButtonTapped)
//            } destination: { store in
//                ActivityView(text: "Text")
//            } label: {
//                Label("Share Wallet Address", image: "ic_share")
//                    .font(.init(.system(size: 17.0, weight: .semibold)))
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, maxHeight: 50)
//                    .background(Color.accentColor)
//                    .cornerRadius(12)
//                    .padding([.leading, .trailing], 48)
//            }

            Button("Tap") {
                ViewStore(store).send(.viewWalletButtonTapped)
                showSheet.toggle()
            }
        }
        .onAppear {
            UserDefaults.standard.set(AppState.walletCreated.rawValue , forKey: "state")
        }
        .sheet(isPresented: $showSheet, content: {
            HalfSheetView(isPresented: $showSheet)
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .offset(y: showSheet ? 0 : UIScreen.main.bounds.height)

        })
//        .sheet(
//            store: self.store.scope(
//                state: \.$destination,
//                action: RecieveTonReducer.Action.destination),
//            state: /RecieveTonReducer.Destination.State.shareView,
//            action: RecieveTonReducer.Destination.Action.shareView) { store in
//
//            }

    }
}


struct HalfSheetView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("Half Sheet")
                .font(.title)
                .padding()

            // Add your content here

            Spacer()

            Button(action: {
                isPresented = false
            }) {
                Text("Close")
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear) // Use clear background color
        .edgesIgnoringSafeArea(.all)
        .transition(.move(edge: .bottom))
        .animation(.spring())
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

