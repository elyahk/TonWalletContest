//
//  TonWalletContestApp.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct TonWalletContestApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LocalAuthenticationView(store: .init(
                    initialState: .init(),
                    reducer: LocalAuthenticationReducer()
                ))
                
//                StartView(store: .init(
//                    initialState: .init(
//                        destination: .createWallet(
//                            .init(
//                                recoveryPhrase: .init(
//                                    destination: .testTime(
//                                        .init(
//                                            testWords: .words3(),
//                                            destination: .passcode(.init())
//                                        )
//                                    ),
//                                    words: .words24
//                                ),
//                                words: .words24
//                            )
//                        )
//                    ),
//                    reducer: StartReducer()
//                        ._printChanges()
//                ))
                
            }
        }
    }
}


