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
                    NavigationLink {

                    } label: {
                        Text("Create My Wallet")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 294, height: 50, alignment: .center)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
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
