//
//  MainView.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 26/04/23.
//

import SwiftUI
import SwiftyTON
import ComposableArchitecture


struct MainViewReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var wallet3: Wallet3
        var balance: String = "zero"
    }

    enum Action: Equatable {
        case onAppear
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.balance = state.wallet3.contract.info.balance.string(with: .maximum9)
                print(state.wallet3.contract.info)
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

extension MainViewReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case wallet(PasscodeReducer.State)

            var id: AnyHashable {
                switch self {
                case let .wallet(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case wallet(PasscodeReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.wallet, action: /Action.wallet) {
                PasscodeReducer()
            }
        }
    }
}



struct MainView: View {
    let store: StoreOf<MainViewReducer>

    init(store: StoreOf<MainViewReducer>) {
        self.store = store
    }



    var body: some View {

        @State var isModal: Bool = false

        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text(viewStore.balance)
                Button {
                    isModal = true
                } label: {
                    Text("Send money")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                        .padding([.leading, .trailing], 48)
                        .padding(.bottom, 124)
                }
                .sheet(isPresented: $isModal) {
//                    SendView()
                }

            }
            .onAppear {
                viewStore.send(.onAppear)
                UserDefaults.standard.set(AppState.walletCreated.rawValue , forKey: "state")
            }
        }
    }
}
//
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            MainView(store: .init(
//                initialState: .init(),
//                reducer: MainViewReducer()
//            ))
//        }
//    }
//}
//
