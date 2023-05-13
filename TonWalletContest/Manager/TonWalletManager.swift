//
//  TonWalletManager.swift
//  TonWalletContest
//
//  Created by Eldorbek Nusratov on 03/04/23.
//

import Foundation
import SwiftyTON
import IdentifiedCollections

enum DebugType: String {
    case importWords = "Import Words Successfully"
    case createWallet = "Create Wallet Succesfully"
    case createMassage = "Create Message Succesfully"
}

func debug(_ debug: DebugType) {
    print(debug.rawValue)
}

enum WalletManagerErrors: Error {
    case unvalidURL
    case invalidAddress
    case invalidWallet
    case keyNotFoundInMemory
    case keyWordsNotFoundInMemory
    case walletNotFoundInMemory
}

class TonWalletManager {
    static let shared: TonWalletManager = .init()

    private init() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Could not create url. TonWalletManager error")
        }

        SwiftyTON.configurate(with: .init(network: .main, logging: .info, keystoreURL: url))
    }
    
    let passcode = "parole"
    let data = Data("parole".utf8)

    func createKey() async throws -> Key {
        // Create local passcode
        // Configurate SwiftyTON with mainnet

        let key = try await Key.create(password: data)

        return key
    }
    
    func words(key: Key) async throws -> [String] {
        let words = try await key.words(password: data)

        return words
    }

    func importWords(_ words: [String]) async throws -> Key {
        let key = try await Key.import(password: data, words: words)
        debug(.importWords)
        return key
    }

    func createWallet3(key: Key, revision: Wallet3.Revision = .r2) async throws -> Wallet3 {
        let initialState = try await Wallet3.initial(
            revision: revision,
            deserializedPublicKey: try key.deserializedPublicKey()
        )

        guard let address = await Address.init(initial: initialState) else {
            throw WalletManagerErrors.invalidAddress
        }
    
        var contract = try await Contract(address: address)
        let selectedContractInfo = contract.info

        switch contract.kind {
        case .none:
            fatalError()
        case .uninitialized: // for uninited state we should pass initial data
            contract = Contract(
                address: address,
                info: selectedContractInfo,
                kind: .walletV3R2,
                data: .zero // will be created automatically
            )
        default:
            break
        }

        guard let wallet = Wallet3(contract: contract) else {
            throw WalletManagerErrors.invalidWallet
        }

        debug(.createWallet)

        return wallet
    }

    func anyWallet(key: Key, revision: Wallet3.Revision = .r2) async throws -> AnyWallet {
        let initialState = try await Wallet3.initial(
            revision: .r1,
            deserializedPublicKey: try key.deserializedPublicKey()
        )

        guard let address = await Address.init(initial: initialState) else {
            throw WalletManagerErrors.invalidAddress
        }

        var contract = try await Contract(address: address)
        let selectedContractInfo = contract.info

        switch contract.kind {
        case .none:
            fatalError()
        case .uninitialized: // for uninited state we should pass initial data
            contract = Contract(
                address: address,
                info: selectedContractInfo,
                kind: .walletV3R2,
                data: .init(code: data) // will be created automatically
            )
        default:
            break
        }

        guard let wallet = AnyWallet(contract: contract) else {
            throw WalletManagerErrors.invalidWallet
        }

        debug(.createWallet)

        return wallet
    }

    func createWallet4(key: Key, revision: Wallet4.Revision = .r1) async throws -> Wallet4 {
        let initialState = try await Wallet4.initial(
            revision: revision,
            deserializedPublicKey: try key.deserializedPublicKey()
        )

        guard let address = await Address.init(initial: initialState) else {
            throw WalletManagerErrors.invalidAddress
        }

        var contract = try await Contract(address: address)
        let selectedContractInfo = contract.info

        switch contract.kind {
        case .none:
            fatalError()
        case .uninitialized: // for uninited state we should pass initial data
            contract = Contract(
                address: address,
                info: selectedContractInfo,
                kind: .walletV4R1,
                data: .zero // will be created automatically
            )
        default:
            break
        }

        guard let wallet = Wallet4(contract: contract) else {
            throw WalletManagerErrors.invalidWallet
        }
        debug(.createWallet)

        return wallet
    }

    func sendMoney(wallet: Wallet3, with key: Key, to address: String) async throws {
        guard let concreateAddress = ConcreteAddress(string: address) else { throw WalletManagerErrors.invalidAddress }

        let message = try await wallet.subsequentTransferMessage(
            to: concreateAddress,
            amount: Currency(0.01), // 0.5 TON
            message: ("My test message".data(using: .utf8), nil),
            key: key,
            passcode: data
        )

        let fees = try await message.fees() // get estimated fees
        print("Estimated fees - \(fees)")
//        try await message.send()
        print("Send money")
    }

    func getMessage(wallet: Wallet4, with key: Key, to address: String) async throws -> Message {
        guard let displayableAddress = await DisplayableAddress(string: address) else { throw WalletManagerErrors.invalidAddress }

        let message = try await wallet.subsequentTransferMessage(
            to: displayableAddress.concreteAddress,
            amount: Currency(0.01), // 0.5 TON
            message: ("My test message".data(using: .utf8), nil),
            key: key,
            passcode: data
        )
        debug(.createMassage)

        return message
    }

    func getMessage(wallet: AnyWallet, with key: Key, to address: String) async throws -> Message {
        guard let displayableAddress = await DisplayableAddress(string: address) else { throw WalletManagerErrors.invalidAddress }

        let message = try await wallet.subsequentTransferMessage(
            to: displayableAddress.concreteAddress,
            amount: Currency(value: "0.01")!, // 0.5 TON
            message: ("My test message".data(using: .utf8), nil),
            key: key,
            passcode: data
        )
        debug(.createMassage)

        return message
    }
}


extension Key {
    static let demoKey: Key = try! .init(publicKey: "Pua9oBjA-siFCL6ViKk5hyw57jfuzSiZUvMwshrYv9m-MdVc", encryptedSecretKey: Data())
}

extension Array where Element == String {
    static let words24: [String] = {
        return ["spike", "rifle", "mother", "clown", "crucial", "endorse", "orbit", "music", "slight", "vocal", "ranch", "moon", "author", "million", "appear", "fine", "quiz", "century", "mixture", "blur", "census", "hub", "cereal", "govern"]
    }()

    static let words24_withTon: [String] = {
        return ["about", "group", "click", "shrug", "prevent", "camp", "fit", "mercy", "govern", "life", "cargo", "goose", "increase", "gossip", "fold", "machine", "certain", "bid",  "mystery", "daughter", "record", "staff", "denial", "junk"]
    }()
}

extension IdentifiedArrayOf where Element == TestTimeReducer.Word {
    static func words24() -> IdentifiedArrayOf<TestTimeReducer.Word> {
        let words: Array<String> = .words24

        return IdentifiedArrayOf(uniqueElements: words.enumerated().map { TestTimeReducer.Word(key: $0, expectedWord: $1) })
    }

    static func words3() -> IdentifiedArrayOf<TestTimeReducer.Word> {
        let words: IdentifiedArrayOf<TestTimeReducer.Word> = .words24()

        return IdentifiedArrayOf(words[0...2])
    }
}
