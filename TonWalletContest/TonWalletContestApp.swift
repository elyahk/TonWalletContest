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
                //                TestTimeView(store: .init(
                //                    initialState: .init(
                //                        key: .demoKey,
                //                        words: .words24,
                //                        buildType: .preview
                //                    ),
                //                    reducer: TestTimeReducer()
                //                ))

                RecoveryPhraseView(store: .init(
                    initialState: .init(
                        key: .demoKey,
                        words: .words24
                    ),
                    reducer: RecoveryPhraseReducer()
                ))

                //                PasscodeView(store: .init(
                //                    initialState: .init(
                //                        key: .demoKey,
                //                        words: .words24,
                //                        buildType: .preview
                //                    ),
                //                    reducer: xPasscodeReducer()
                //                ))
            }
        }
    }
}
