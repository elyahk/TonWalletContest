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
            VStack {
                Spacer()
                LottieView(name: "crystal", loop: .loop)
                    .frame(width: 124, height: 124, alignment: .center)
                Text("TON Wallet")
                    .fontWeight(.semibold)
                    .font(.title)
                    .padding(.bottom, 5)
                Text("TON Wallet allows you to make fast and secure blockchain-based payments without intermediaries.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                // Create My Wallet app
                NavigationLinkStore(
                    store: self.store.scope(state: \.walletCreate, action: StartReducer.Action.createWallet),
                    id: viewStore.walletCreate?.id
                ) {
                    viewStore.send(.createMyWalletTapped)
                } destination: { store in
                    CongratulationView(store: store)
                        .navigationBarHidden(true)
                } label: {
                    Text("Create My Wallet")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 294, height: 50, alignment: .center)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                        .padding(.horizontal, 48)
                }
                
                NavigationLinkStore(
                    store: self.store.scope(state: \.walletCreate, action: StartReducer.Action.createWallet),
                    id: viewStore.walletCreate?.id
                ) {
                    viewStore.send(.createMyWalletTapped)
                } destination: { store in
                    CongratulationView(store: store)
                        .navigationBarHidden(true)
                } label: {
                    Text("Import Existing Wallet")
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .frame(minWidth: 294, minHeight: 50, alignment: .center)
                        .padding(.horizontal, 48)
                }
                .padding(.bottom, 30)
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        StartView(store: .init(
            initialState: .init(),
            reducer: StartReducer()
        ))
        }
    }
}
//"Pua9oBjA-siFCL6ViKk5hyw57jfuzSiZUvMwshrYv9m-MdVc"
