//
//  TonWalletContestApp.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//

import SwiftUI
import ComposableArchitecture
import SwiftyTON

func debug(_ debug: AppState.Debug) {
    print(debug.description)
}

struct AppState {
    enum Debug {
        case key(Key)
        case state(Cases)
        case wallet(AnyWallet)
        
        var description: String {
            switch self {
            case let .key(key):
                return "Key saved to memory: \(key.publicKey)"
                
            case let .wallet(wallet):
                return "Wallet saved to memory: Contract - \(wallet.contract)"
                
            case let .state(cases):
                return "AppState changed to: \(cases.rawValue)"
            
            }
        }
    }
    
    enum Keys: String {
        case appState = "state"
        case key = "key"
        case wallet = "wallet"
    }
    
    enum Cases: String {
        case new
        case keyCreated
        case walletCreated
    }
    
    static func set(_ appCase: Cases) {
        UserDefaults.standard.set(appCase.rawValue, forKey: Keys.appState.rawValue)
        debug(.state(appCase))
    }
    
    static func set(key: Key) {
        set(.keyCreated)
        UserDefaults.standard.set(key, forKey: Keys.key.rawValue)
        debug(.key(key))
    }
    
    static func getKey() throws -> Key {
        guard let key = UserDefaults.standard.object(forKey: Keys.key.rawValue) as? Key else {
            throw WalletManagerErrors.keyNotFoundInMemory
        }
        
        return key
    }
    
    static func set(wallet: AnyWallet) {
        set(.walletCreated)
        UserDefaults.standard.set(wallet, forKey: Keys.wallet.rawValue)
        debug(.wallet(wallet))
    }
    
    static func getWallet() throws -> AnyWallet {
        guard let wallet = UserDefaults.standard.object(forKey: Keys.wallet.rawValue) as? AnyWallet else {
            throw WalletManagerErrors.keyNotFoundInMemory
        }
        
        return wallet
    }
}

class ComposableAuthenticationViews {
    func makeMainViewReducerState(wallet: AnyWallet?) -> MainViewReducer.State {
        let state = MainViewReducer.State(events: .init(
            getBalance: { [wallet] in
                return wallet?.contract.info.balance.string(with: .maximum9) ?? "0"
            },
            getWalletAddress: {
                wallet?.contract.address.rawValue ?? "Wallet Address"
            },
            getTransactions: {
                try await wallet?.contract.transactions(after: nil).map { transaction in
                    Transaction(
                        senderAddress: transaction.in?.sourceAccountAddress?.displayName ?? "Empty",
                        humanAddress: "Human address",
                        amount: 0.0,
                        comment: "Comment",
                        fee: transaction.storageFee.string(with: .maximum9).toDouble() + transaction.otherFee.string(with: .maximum9).toDouble(),
                        date: transaction.date
                    )
                } ?? []
            }
        ))
        
        return state
    }
    
    func makeReadyToGoReducerState() -> ReadyToGoReducer.State {
        let state = ReadyToGoReducer.State(
            events: .init(
                createMainViewReducerState: {
                    do {
                        let key = try AppState.getKey()
                        let wallet = try await TonWalletManager.shared.anyWallet(key: key)
                        AppState.set(wallet: wallet)
                        return self.makeMainViewReducerState(wallet: wallet)
                    } catch {
                        print(error.localizedDescription)
                        return self.makeMainViewReducerState(wallet: nil)
                    }
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
                AppState.set(key: key)
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
//    @State var state: String = UserDefaults.standard.string(forKey: AppState.appState) ?? "new"

    var body: some Scene {
        WindowGroup {
            NavigationView {
                composableArchitecture.makeStartView()
            }
        }
    }
}


