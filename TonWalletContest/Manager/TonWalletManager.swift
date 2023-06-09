//
//  TonWalletManager.swift
//  TonWalletContest
//
//  Created by Eldorbek Nusratov on 03/04/23.
//

import Foundation
import SwiftyTON
import TON3
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
    case userSettingsNotFoundInMemory
    case userWalletSettingsNotFoundInMemory
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
            revision: .r2,
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

    func getMessage(
        wallet: Wallet3,
        with key: Key,
        to address: String,
        with amount: String,
        comment: String
    ) async throws -> Message {
        guard let displayableAddress = await DisplayableAddress(string: address) else { throw WalletManagerErrors.invalidAddress }

        let message = try await wallet.subsequentTransferMessage2(
            to: displayableAddress.concreteAddress,
            amount: Currency.init(value: Int64(amount.toDouble() * 1_000_000_000.0)),
            message: (comment.data(using: .utf8), nil),
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

extension Wallet3 {
    static let demoWallet: Wallet3 = .init(contract: .init(address: .init(workchain: 0, hash: []), info: .init(balance: .zero, synchronizationDate: .init()), kind: nil, data: .init(bytes: [])))!
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

extension Wallet {
    func subsequentTransferMessage2(
        to concreteAddress: ConcreteAddress,
        amount: Currency,
        message: (body: Data?, initial: Data?),
        key: Key,
        passcode: Data
    ) async throws -> Message {
        let updated = try await Contract(address: contract.address)
        guard updated.info.balance > amount
        else {
            throw ContractError.notEnaughtBalance
        }

        let subsequentExternalMessageBody = try await TON3.transfer(
            external: try await subsequentExternalMessage(),
            workchain: concreteAddress.address.workchain,
            address: concreteAddress.address.hash,
            amount: amount.value,
            bounceable: false,
            payload: message.body?.bytes,
            state: message.initial?.bytes
        )

        var subsequentInitialCondition: Contract.InitialCondition?
        if updated.kind == .uninitialized {
            subsequentInitialCondition = try await subsequentExternalMessageInitialCondition(
                key: key
            )
        }

        let boc = BOC(bytes: subsequentExternalMessageBody)
        return try await Message(
            destination: contract.address,
            initial: subsequentInitialCondition,
            body: try await boc.signed(with: key, localUserPassword: passcode)
        )
    }
}
