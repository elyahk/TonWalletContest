//
//  StartView.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//

import SwiftUI
import ComposableArchitecture

struct StartView: View {
    let store: StoreOf<StartReducer>

    init(store: StoreOf<StartReducer>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                NavigationLink {

                } label: {
                    Text("Create My Wallet")
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
