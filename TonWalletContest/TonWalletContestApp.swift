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
                StartView(store: .init(
                    initialState: .init(),
                    reducer: StartReducer()
                ))
            }
        }
    }
}
