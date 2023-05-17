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
        case wallet3(Wallet3)
        
        var description: String {
            switch self {
            case let .key(key):
                return "Key saved to memory: \(key.publicKey)"
                
            case let .wallet(wallet):
                return "Wallet saved to memory: Contract - \(wallet.contract)"
                
            case let .wallet3(wallet):
                return "Wallet saved to memory: Contract - \(wallet.contract)"
                
            case let .state(cases):
                return "AppState changed to: \(cases.rawValue)"
            
            }
        }
    }
    
    enum Keys: String {
        case appState = "state"
        case key = "key"
        case keyWords = "keyWords"
        case wallet = "wallet"
    }
    
    enum Cases: String {
        case new
        case keyCreated
        case keyConfirmed
    }
    
    static func set(_ appCase: Cases) {
        UserDefaults.standard.set(appCase.rawValue, forKey: Keys.appState.rawValue)
        debug(.state(appCase))
    }
    
    static func getCase() -> Cases {
        let caseString = UserDefaults.standard.string(forKey: Keys.appState.rawValue)
        let cases = Cases(rawValue: caseString ?? "new") ?? .new
        
        return cases
    }
    
    static func set(key: Key, words: [String]) {
        set(.keyCreated)
//        try await TonKeyStore.shared.save(key: key)
        let encoder = PropertyListEncoder()
        let data = try? encoder.encode(key)
        UserDefaults.standard.set(data, forKey: Keys.key.rawValue)
        UserDefaults.standard.set(words, forKey: Keys.keyWords.rawValue)
        debug(.key(key))
    }
    
    static func getKey() throws -> Key {
        let decoder = PropertyListDecoder()
        
        guard let data = UserDefaults.standard.data(forKey: Keys.key.rawValue), let key = try? decoder.decode(Key.self, from: data) else {
            throw WalletManagerErrors.keyNotFoundInMemory
        }
        
        return key
    }
    
    static func getWords() throws -> [String] {
        guard let words = UserDefaults.standard.stringArray(forKey: Keys.keyWords.rawValue) else {
            throw WalletManagerErrors.keyWordsNotFoundInMemory
        }
        
        return words
    }
    
    static func set(wallet3: Wallet3) {
        let encoder = PropertyListEncoder()
        let data = try? encoder.encode(wallet3)
        UserDefaults.standard.set(data, forKey: Keys.wallet.rawValue)
        debug(.wallet3(wallet3))
    }
    
    static func getWallet() throws -> Wallet3 {
        let decoder = PropertyListDecoder()
        
        guard let data = UserDefaults.standard.data(forKey: Keys.wallet.rawValue), let wallet = try? decoder.decode(Wallet3.self, from: data) else {
            throw WalletManagerErrors.keyNotFoundInMemory
        }
        
        return wallet
    }
}

class ComposableAuthenticationViews {
    func makeMainViewReducerState(wallet: Wallet3?) -> MainViewReducer.State {
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
                        #warning("Wallet dont create")
//                        let key = try AppState.getKey()
//                        let wallet = try await TonWalletManager.shared.anyWallet(key: key)
//                        AppState.set(wallet: wallet)
    
                        return self.makeMainViewReducerState(wallet: nil)
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
                    AppState.set(.keyConfirmed)
                    
                    return self.makePasscodeReducerState()
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

    func makeImportFailureReducerState() -> ImportFailureReducer.State {
        let state = ImportFailureReducer.State(events: .init(
            createStartReducerState: {
                return self.makeStartReducerState()
            }
        ))
        
        return state
    }
    
    func makeImportSuccessReducerState(wallet: Wallet3) -> ImportSuccessReducer.State {
        let state = ImportSuccessReducer.State(events: .init(
            createMainViewReducerState: {
                return self.makeMainViewReducerState(wallet: wallet)
            }
        ))
        
        return state
    }
    
    func makeImportPhraseReducerState() -> ImportPhraseReducer.State {
        let state = ImportPhraseReducer.State(
            events: .init(
                createImportSuccessReducer: { wallet in
                    return self.makeImportSuccessReducerState(wallet: wallet)
                },
                createImportFailureReducer: {
                    return self.makeImportFailureReducerState()
                },
                isSecretWordsImported: { testWords in
                    do {
                        let words = testWords.map { $0.recivedWord }
                        let key = try await TonWalletManager.shared.importWords(words)
                        let wallet = try await TonWalletManager.shared.createWallet3(key: key)
                        
                        AppState.set(key: key, words: words)
                        AppState.set(wallet3: wallet)
                        AppState.set(.keyConfirmed)
                        
                        return wallet
                    } catch {
                        print(error)
                        return nil
                    }
                }
            )
        )
        
        return state
    }
    
    func makeStartReducerState() -> StartReducer.State {
        let state = StartReducer.State(events: .init(
            createCongratulationState: { [self] in
                let key = try await TonWalletManager.shared.createKey()
                let words = try await TonWalletManager.shared.words(key: key)
                AppState.set(key: key, words: words)

                Task(priority: .high) {
                    let wallet = try await TonWalletManager.shared.createWallet3(key: key)
                    AppState.set(wallet3: wallet)
                }
                return makeCongratulationReducerState(words: words)
            },
            createImportPhraseState: {
                return self.makeImportPhraseReducerState()
            }
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
    
    func getFirtView() -> some View {
        // Initialize Ton service
        _ = TonWalletManager.shared
        let currentCase = AppState.getCase()
        
        switch currentCase {
        case .new:

           return AnyView(makeStartView())

        case .keyCreated:
            guard let words = try? AppState.getWords() else {
                return AnyView(makeStartView())
            }

            return AnyView(CongratulationView(store: .init(
                initialState: makeCongratulationReducerState(words: words),
                reducer: CongratulationReducer()
            )))

        case .keyConfirmed:
            guard let wallet = try? AppState.getWallet() else {
                return AnyView(makeStartView())
            }
            
            return AnyView(MainView(store: .init(
                initialState: makeMainViewReducerState(wallet: wallet),
                reducer: MainViewReducer()
            )))
        }
    }
}

@main
struct TonWalletContestApp: App {
    var composableArchitecture: ComposableAuthenticationViews = .init()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                EnterAmountView(address: .constant("dlofjmo349rhfjdifcn3i4rhfkqjrh439qeifhu"))
//                composableArchitecture.getFirtView()
            }
        }
    }
}


