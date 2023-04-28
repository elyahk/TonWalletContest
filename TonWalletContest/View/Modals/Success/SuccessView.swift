//
//  SuccessView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI
import ComposableArchitecture

struct SuccessView: View {
    var body: some View {
        VStack {
            Spacer()
            LottieView(name: "party", loop: .playOnce)
                .frame(width: 124, height: 124, alignment: .center)
            Text("Done")
                .fontWeight(.semibold)
                .font(.title)
                .padding(.bottom, 5)
            Text("2.2 Toncoin have been sent to")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom)
            Text("Wallet address")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()

            NavigationLinkStore() {
                //
            } destination: { store in
                //
            } label: {
                Text("View my wallet")
                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                    .customWideBlueButtonStyle()
                    .padding(.bottom)
            }
        }
    }
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView()
    }
}
