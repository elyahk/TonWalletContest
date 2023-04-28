//
//  PendingView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI

struct PendingView: View {
    var body: some View {
        VStack {
            Spacer()
            LottieView(name: "money", loop: .playOnce)
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

            //            NavigationLinkStore(
            //                self.store.scope(state: \.$recoveryPhrase, action: CongratulationReducer.Action.recoveryPhrase)
            //            ) {
            //                ViewStore(store).send(.proceedButtonTapped)
            //            } destination: { store in
            //                RecoveryPhraseView(store: store)
            //            } label: {
            //                Text("Proceed")
            //                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
            //                    .customBlueButtonStyle()
            //                    .padding(.bottom, 90)
            //            }
        }
    }
}

struct PendingView_Previews: PreviewProvider {
    static var previews: some View {
        PendingView()
    }
}
