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
//                RecoveryPhraseView(store: .init(initialState: .init(words: .words24), reducer: RecoveryPhraseReducer()))
                StartView(store: .init(
                    initialState: .init(),
                    reducer: StartReducer()
                ))
            }
        }
    }
}
