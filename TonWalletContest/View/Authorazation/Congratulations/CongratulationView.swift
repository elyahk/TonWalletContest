//
//  CongratulationView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 04/04/23.
//

import SwiftUI
import ComposableArchitecture
import _SwiftUINavigationState
import SwiftyTON


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
                    NavigationLink(
                        isActive: Binding(get: {
                            viewStore.recoveryPhrase != nil
                        }, set: { isActive in
                            if isActive {
                                viewStore.send(.proceedButtonTapped)
                            } else {
                                
                            }
                        }),
                        destination: {
                            IfLetStore(self.store.scope(state: \.recoveryPhrase, action: CongratulationReducer.Action.recoveryPhrase), then: { viewStore in
                                RecoveryPhraseView(store: viewStore)
                            })
                        },
                        label: {
                            Text("Proceed")
                                .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                                .customBlueButtonStyle()
                        }
                    )
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct CongratulationView_Previews: PreviewProvider {
    
    static var previews: some View {
        CongratulationView(store: .init(
            initialState: .init(
                key: try! .init(publicKey: "Pua9oBjA-siFCL6ViKk5hyw57jfuzSiZUvMwshrYv9m-MdVc", encryptedSecretKey: .init()),
                buildType: .preview
            ),
            reducer: CongratulationReducer()
        ))
        
    }
}
