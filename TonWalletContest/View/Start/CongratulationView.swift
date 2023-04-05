//
//  CongratulationView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 04/04/23.
//

import SwiftUI
import ComposableArchitecture
import _SwiftUINavigationState

struct CongratulationView: View {

    let store: StoreOf<CongratulationReducer>

    init(store: StoreOf<CongratulationReducer>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack {
                    Spacer()
                    LottieView(name: "boomstick", loop: .playOnce)
                        .frame(width: 124, height: 124, alignment: .center)
                    Text("Congratulations")
                        .fontWeight(.semibold)
                        .font(.title)
                        .padding(.bottom, 5)
                    Text("Your TON Wallet has just been created. Only you control it.\n\nTo be able to always have access to it, please write down secret words and set up a secure passcode.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    Spacer()
                    NavigationLink {
#warning("action for reducer")
                    } label: {
                        Text("Proceed")
                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                            .customBlueButtonStyle()

                    }
                    .padding(.bottom, 90)
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct CongratulationView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationView(store: .init(
            initialState: .init(destination: .recoveryPhraseView),
            reducer: CongratulationReducer()
        ))
    }
}
