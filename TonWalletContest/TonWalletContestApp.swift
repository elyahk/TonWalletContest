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
    func makeMainViewReducerState() -> MainViewReducer.State {
        let state = MainViewReducer.State(events: .init(
            getBalance: {
                return "2.0000000"
            },
            getWalletAddress: {
                "Wallet Address"
            },
            getTransactions: {
                []
            }
        ))
        
        return state
    }
    
    func makeReadyToGoReducerState() -> ReadyToGoReducer.State {
        let state = ReadyToGoReducer.State(
            events: .init(
                createMainViewReducerState: {
                    self.makeMainViewReducerState()
                }
            )
        )
        
        return state
    }
    
    func makeLocalAuthenticationReducerState() -> LocalAuthenticationReducer.State {
        let state = LocalAuthenticationReducer.State(
            events: .init(
                createReadyToGoReducerState: {
                    self.makeReadyToGoReducerState()
                }
            )
        )
        
        return state
    }
    
    func makePasscodeReducerState() -> PasscodeReducer.State {
        let state = PasscodeReducer.State(events: .init(
            createConfirmPasscodeReducerState: { oldPasscode in
                let confirmPasscodeState = ConfirmPasscodeReducer.State(
                    oldPasscode: oldPasscode,
                    passcodes: oldPasscode.map { _ in .empty },
                    events: .init(
                        createLocalAuthenticationReducerState: {self.makeLocalAuthenticationReducerState()}
                    )
                )
                
                return confirmPasscodeState
            }
        ))
        
        return state
    }
    
    func makeTestTimeReducerState(words: IdentifiedArrayOf<TestTimeReducer.Word>) -> TestTimeReducer.State {
        let state = TestTimeReducer.State(
            testWords: words,
            events: .init(
                createPasscodeReducerState: {
                    self.makePasscodeReducerState()
                }
            )
        )
        
        return state
    }
    
    func makeCongratulationReducerState(words: [String]) -> CongratulationReducer.State {
        let state =  CongratulationReducer.State(
            events: .init(
                createRecoveryState: {
                    RecoveryPhraseReducer.State(
                        words: words,
                        events: .init(createTestTimeReducerState: { [self] testWords in
                            let words = IdentifiedArrayOf(uniqueElements: (testWords[0...2].sorted { $0.key < $1.key } ))
                            return self.makeTestTimeReducerState(words: words)
                        })
                    )
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


