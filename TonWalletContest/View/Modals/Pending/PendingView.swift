//
//  PendingView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI
import ComposableArchitecture

struct PendingView: View {
    let store: StoreOf<PendingReducer>

    init(store: StoreOf<PendingReducer>) {
        self.store = store
    }

    var body: some View {
        VStack {
            Spacer()
            LottieView(name: "money", loop: .loop)
                .frame(width: 124, height: 124, alignment: .center)
            Text("Sending TON")
                .fontWeight(.semibold)
                .font(.title)
                .padding(.bottom, 5)
            Text("Please wait a few seconds for your transaction to be processed…")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()

            NavigationLink {
                //
            } label: {
                Text("View my wallet")
                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                    .customWideBlueButtonStyle()
                    .padding(.bottom)
            }

//            NavigationLinkStore() {
//                //
//            } destination: { store in
//                //
//            } label: {
//                Text("View my wallet")
//                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
//                    .customWideBlueButtonStyle()
//                    .padding(.bottom)
//            }
        }
    }
}

struct PendingView_Previews: PreviewProvider {
    static var previews: some View {
        PendingView(store: .init(
            initialState: .init(),
            reducer: PendingReducer()
        ))
    }
}
