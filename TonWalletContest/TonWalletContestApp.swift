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

class ComposableAuthenticationViews {
    func makeCongratulationReducerState(words: [String]) -> CongratulationReducer.State {
        let state =  CongratulationReducer.State(
            events: .init(
                createRecoveryState: {
                    RecoveryPhraseReducer.State(words: words)
                }),
            words: words
        )

        return state
    }

    func makeStartReducerState() -> StartReducer.State {
        let state = StartReducer.State(events: .init(
            createCongratulationState: { [self] in
                let key = try await TonWalletManager.shared.createKey()
                try await TonKeyStore.shared.save(key: key)
                UserDefaults.standard.set(AppState.keyCreated.rawValue, forKey: "state")
                try await TonKeyStore.shared.save(key: key)
                let words = try await TonWalletManager.shared.words(key: key)

                return makeCongratulationReducerState(words: words)
            },
            createImportPhraseState: { return ImportPhraseReducer.State() }
        ))

        return state
    }

    func makeStartView() -> StartView {
        let view = StartView(store: .init(
            initialState: makeStartReducerState(),
            reducer: StartReducer()
        ))

        return view
    }
}

@main
struct TonWalletContestApp: App {
    var composableArchitecture: ComposableAuthenticationViews = .init()
    @State var state: String = UserDefaults.standard.string(forKey: "state") ?? "new"

    var body: some Scene {
        WindowGroup {
            NavigationView {
                composableArchitecture.makeStartView()
            }
        }
    }
}


