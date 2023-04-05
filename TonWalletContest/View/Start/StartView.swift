//
//  StartView.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//

import SwiftUI
import ComposableArchitecture
import _SwiftUINavigationState

struct StartView: View {
    let store: StoreOf<StartReducer>

    init(store: StoreOf<StartReducer>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack {
                    Spacer()
                    LottieView(name: "crystal", loop: .loop)
                        .frame(width: 124, height: 124, alignment: .center)
                    Text("TON Wallet")
                        .fontWeight(.semibold)
                        .font(.title)
                        .padding(.bottom, 5)
                    Text("""
                        TON Wallet allows you to make fast and
                         secure blockchain-based payments
                         without intermediaries.
                    """)
                    .multilineTextAlignment(.center)
                    Spacer()
                    // Create My Wallet app
                    NavigationLink(
                        isActive: Binding(get: {
                            viewStore.walletCreate != nil
                        }, set: { isActive in
                            if isActive {
                                viewStore.send(.createMyWalletTapped)
                            } else {
                                
                            }
                        }),
                        destination: {
                            IfLetStore(self.store.scope(state: \.walletCreate, action: StartReducer.Action.createWallet), then: { viewStore in
                                CongratulationView(store: viewStore)
                                    .navigationBarHidden(true)
                            })
                        },
                        label: {
                            Text("Create My Wallet")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 294, height: 50, alignment: .center)
                                .background(Color.accentColor)
                                .cornerRadius(12)
                                .padding(.horizontal, 48)
                        }
                    )
                      
                    NavigationLink(
                        isActive: Binding(get: {
                            viewStore.importWallet != nil
                        }, set: { isActive in
                            if isActive {
                                viewStore.send(.importMyWalletTapped)
                            } else {
                                
                            }
                        }),
                        destination: {
                            IfLetStore(self.store.scope(state: \.importWallet, action: StartReducer.Action.importWallet), then: { viewStore in
                                CongratulationView(store: viewStore)
                                    .navigationBarHidden(true)
                                #warning("Open ImportWallet screen when view will be ready!")
                            })
                        },
                        label: {
                            Text("Import Existing Wallet")
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                                .frame(minWidth: 294, minHeight: 50, alignment: .center)
                                .padding(.horizontal, 48)
                        }
                    )
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(store: .init(
            initialState: .init(),
            reducer: StartReducer()
        ))
    }
}
