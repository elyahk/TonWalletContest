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
        case userSettings(UserWalletSettings)
        
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

            case let .userSettings(userSettings):
                return "User Settings changed: \(userSettings)"
            
            }
        }
    }
    
    enum Keys: String {
        case appState = "state"
        case key = "key"
        case keyWords = "keyWords"
        case wallet = "wallet"
        case userWalletSettings = "userWalletSettings"
        case userSettings = "userSettings"
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

    static func set(userWalletSettings: UserWalletSettings) {
        let encoder = PropertyListEncoder()
        let data = try? encoder.encode(userWalletSettings)
        UserDefaults.standard.set(data, forKey: Keys.userWalletSettings.rawValue)
    }

    static func set(userSettings: UserSettings) {
        let encoder = PropertyListEncoder()
        let data = try? encoder.encode(userSettings)
        UserDefaults.standard.set(data, forKey: Keys.userSettings.rawValue)
    }

    static func getUserWalletSettings() throws -> UserWalletSettings {
        let decoder = PropertyListDecoder()

        guard let data = UserDefaults.standard.data(forKey: Keys.userWalletSettings.rawValue), let userSettings = try? decoder.decode(UserWalletSettings.self, from: data) else {
            throw WalletManagerErrors.userWalletSettingsNotFoundInMemory
        }

        return userSettings
    }

    static func getUserSettings() -> UserSettings {
        let decoder = PropertyListDecoder()

        guard let data = UserDefaults.standard.data(forKey: Keys.userSettings.rawValue), let userSettings = try? decoder.decode(UserSettings.self, from: data) else {
            return .init()
        }

        return userSettings
    }
    
    static func getWallet() throws -> Wallet3 {
        let decoder = PropertyListDecoder()
        
        guard let data = UserDefaults.standard.data(forKey: Keys.wallet.rawValue), let wallet = try? decoder.decode(Wallet3.self, from: data) else {
            throw WalletManagerErrors.walletNotFoundInMemory
        }
        
        return wallet
    }
}

class ComposableAuthenticationViews {
    func makePendingReducerState(walletAddress: String) -> PendingReducer.State {
        let state = PendingReducer.State(
            walletAddress: walletAddress,
            events: .init()
        )

        return state
    }

    func makeConfirmReducerState(transcation: Transaction1) -> ConfirmReducer.State {
        let state = ConfirmReducer.State(
            transaction: transcation,
            events: .init(
                sendTon: { transaction in
                    let wallet = try AppState.getWallet()
                    let key = try AppState.getKey()
                    let message = try await TonWalletManager.shared.getMessage(
                        wallet: wallet,
                        with: key,
                        to: transaction.destinationShortAddress,
                        with: transaction.amount.description,
                        comment: transaction.comment
                    )

                    try await message.send()
                },
                createPendingReducerState: { walletAddress in
                    self.makePendingReducerState(walletAddress: walletAddress)
                }
            ))

        return state
    }

    func makeEnterAmountReducerState(recieverAddress: String, recieverShortAddress: String = "", userWallet: UserWalletSettings.UserWallet) -> EnterAmountReducer.State {
        let state = EnterAmountReducer.State(
            reciverAddress: recieverAddress,
            recieverShortAddress: recieverShortAddress,
            userWallet: userWallet,
            events: .init(
                createConfirmReducerState: { transcation in
                    self.makeConfirmReducerState(transcation: transcation)
                }, getTransaction: { amount in
                    let wallet = try AppState.getWallet()
                    let userAddress = wallet.contract.address.description
                    let key = try AppState.getKey()
                    let message = try await TonWalletManager.shared.getMessage(wallet: wallet, with: key, to: amount.address, with: amount.amount, comment: "")
                    let fee = try await message.fees()

                    let transaction = Transaction1(
                        destinationAddress: wallet.contract.address.description,
                        destinationShortAddress: amount.address,
                        userAddress: userAddress,
                        amount: amount.amount.toDouble(),
                        comment: "",
                        fee: fee.description.toDouble(),
                        date: .init(),
                        status: .pending,
                        isTransactionSend: true,
                        transactionId: ""
                    )

                    return transaction
                }
            )
        )

        return state
    }

    func makeRecieveTonReducerState() -> RecieveTonReducer.State {
        return RecieveTonReducer.State.init()
    }

    func makeSendReducerState(userWallet: UserWalletSettings.UserWallet) -> SendReducer.State {
        let state = SendReducer.State(
            userWallet: userWallet,
            events: .init(
                createEnterAmountReducerState: { recieverAddress, recieverShortAddress, userWallet  in
                    self.makeEnterAmountReducerState(recieverAddress: recieverAddress, recieverShortAddress: recieverShortAddress, userWallet: userWallet)

                },
                createScanQRCodeReducerState: {
                    .init(events: .init())
                }
            )
        )

        return state
    }

    func makeMainViewReducerState() -> MainViewReducer.State {
        let state = MainViewReducer.State(events: .init(
            getLocalUserSettings: {
                let userSeetings = try AppState.getUserWalletSettings()
                return userSeetings
            },
            getUserWallet: {
                let wallet = try AppState.getWallet()
                let key = try AppState.getKey()
                let balance = wallet.contract.info.balance.string(with: .maximum9).toDouble()
                let userAddress = await DisplayableAddress(string: wallet.contract.address.description)?.displayName ?? ""

//                wallet.contract.kind.

                let transactions = try await wallet.contract.transactions(after: nil).map { transaction in
                    var amount: Double = 0.0
                    var isTransactionSent: Bool = false
                    var destinationAddress: String = ""
                    var fee: Double = 0.0
                    var comment: String = ""

                    if let value = transaction.out.first {
                        amount = value.value.string(with: .maximum9).toDouble()
                        isTransactionSent = true
                        destinationAddress = value.destinationAccountAddress?.displayName ?? ""

                        fee = value.fees.string(with: .maximum9).toDouble()
                        switch value.body {
                        case .text(value: let text):
                            comment = text
                        default:
                            comment = ""
                        }

                    } else if let value = transaction.in {
                        amount = value.value.string(with: .maximum9).toDouble()
                        destinationAddress = value.sourceAccountAddress?.displayName ?? ""
                        fee = value.fees.string(with: .maximum9).toDouble()
                        isTransactionSent = false

                        switch value.body {
                        case .text(value: let text):
                            comment = text
                        default:
                            comment = "Encrepted: \(value.body)"
                        }
                    }

                    return Transaction1(
                        destinationAddress: destinationAddress,
                        destinationShortAddress: destinationAddress,
                        userAddress: userAddress,
                        amount: amount,
                        comment: comment,
                        fee: fee,
                        date: transaction.date,
                        status: .pending,
                        isTransactionSend: isTransactionSent,
                        transactionId: "2343ewds"
                    )
                }

                let userWallet = UserWalletSettings.UserWallet(allAmmount: balance, address: userAddress, transactions: transactions)
                let userWalletSettings = UserWalletSettings(userWallet: userWallet, key: key, wallet: wallet)
                AppState.set(userWalletSettings: userWalletSettings)

                return userWallet

            },
            createRecieveTonReducerState: {
                self.makeRecieveTonReducerState()
            },
            createSendReducerState: { userWallet in
                self.makeSendReducerState(userWallet: userWallet)
            },
            createEnterAmountReducerState: { recieverAddress, recieverShortAddress, userWallet in
                self.makeEnterAmountReducerState(recieverAddress: recieverAddress, recieverShortAddress: recieverShortAddress, userWallet: userWallet)
            },
            createScanQRCodeReducerState: {
                .init(events: .init())
            },
            createSettingsReducerState: {
                let userSettings = AppState.getUserSettings()

                return .init(userSettings: userSettings)
            }
        ))
        
        return state
    }
    
    func makeReadyToGoReducerState() -> ReadyToGoReducer.State {
        let state = ReadyToGoReducer.State(
            events: .init(
                createMainViewReducerState: {
                    return self.makeMainViewReducerState()
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
    
    func makeImportSuccessReducerState() -> ImportSuccessReducer.State {
        let state = ImportSuccessReducer.State(events: .init(
            createMainViewReducerState: {
                return self.makeMainViewReducerState()
            }
        ))
        
        return state
    }
    
    func makeImportPhraseReducerState() -> ImportPhraseReducer.State {
        let state = ImportPhraseReducer.State(
            events: .init(
                createImportSuccessReducer: {
                    return self.makeImportSuccessReducerState()
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
                        
                        return true
                    } catch {
                        print(error)
                        return false
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
                initialState: makeMainViewReducerState(),
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
//                EnterAmountView(address: .constant("dlofjmo349rhfjdifcn3i4rhfkqjrh439qeifhu"))
                composableArchitecture.getFirtView()
//                ScanQRCodeView(store: .init(initialState: .init(events: .init()), reducer: ScanQRCodeReducer()))
            }
        }
    }
}


