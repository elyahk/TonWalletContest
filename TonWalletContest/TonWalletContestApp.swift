//
//  TonWalletContestApp.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//

import SwiftUI
import ComposableArchitecture

enum AppState: String {
    case new
    case keyCreated
    case walletCreated
}

@main
struct TonWalletContestApp: App {
    @State var state: String = UserDefaults.standard.string(forKey: "state") ?? "new"

    var body: some Scene {
        WindowGroup {
            NavigationView {
                switch AppState(rawValue: state) ?? .new {
                case .new:
                    StartView(store: .init(
                        initialState: .init(),
                        reducer: StartReducer()
                    ))
                case .keyCreated:
                    CongratulationView(store: .init(initialState: .init(words: []), reducer: CongratulationReducer()))
                case .walletCreated:
                    Text("Wallet Created")
                }
                
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


