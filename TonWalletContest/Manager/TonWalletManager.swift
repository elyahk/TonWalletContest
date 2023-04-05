//
//  TonWalletManager.swift
//  TonWalletContest
//
//  Created by Eldorbek Nusratov on 03/04/23.
//

import Foundation
import SwiftyTON

enum WalletManagerErrors: Error {
    case unvalidURL
    case invalidAddress
    case invalidWallet
}

class TonWalletManager {
    static let shared: TonWalletManager = .init()
    
    let passcode = "parole"
    let data = Data("parole".utf8)

    func createKey() async throws -> Key {
        // Create local passcode
        // Configurate SwiftyTON with mainnet
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let passcodeData = passcode.data(using: .utf8) else {
            throw WalletManagerErrors.unvalidURL
        }
        
        SwiftyTON.configurate(with: .init(network: .main, logging: .plain, keystoreURL: url))
        let key = try await Key.create(password: passcodeData)
        
        return key
    }
    
    func words(key: Key, buildType: BuildType = .real) async throws -> [String] {
        switch buildType {
        case .preview: return [""]
        case .real:
            let words = try await key.words(password: data)
            return words
        }
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
        
        return wallet
    }
    
    
//        let key = try await Key.import(password: passcodeData, words: words)

//        // Create Wallet v3R2 initial state
//        let initialState = try await Wallet3.initial(
//            revision: .r2,
//            deserializedPublicKey: try key.deserializedPublicKey()
//        )
//
//        // Get address from initial data
//        guard let myAddress = await Address(initial: initial)
//        else {
//            fatalError()
//        }
//
//        // Parse address (and resolve, if needed) from example.ton, example.t.me or simple address string
//        guard let displayableAddress = await DisplayableAddress(string: "example.ton")
//        else {
//            fatalError()
//        }
//
//        // Transfer
//        var contract = try await Contract(address: myAddress)
//        let selectedContractInfo = contract.info
//
//        switch contract.kind {
//        case .none:
//            fatalError()
//        case .uninitialized: // for uninited state we should pass initial data
//            contract = Contract(
//                address: myAddress,
//                info: selectedContractInfo,
//                kind: .walletV3R2,
//                data: .zero // will be created automatically
//            )
//        default:
//            break
//        }
//
//        guard let wallet = AnyWallet(contract: contract) else {
//          fatalError()
//        }
//
//        let message = try await wallet.subsequentTransferMessage(
//            to: displayableAddress.concreteAddress,
//            amount: Currency(0.5), // 0.5 TON
//            message: ("SwiftyTON".data(using: .utf8), nil),
//            key: key,
//            passcode: passcode
//        )
//
//        let fees = try await message.fees() // get estimated fees
//        print("Estimated fees - \(fees)")
//
//        try await message.send() // send transaction
//    }
}


extension Key {
    static let demoKey: Key = try! .init(publicKey: "Pua9oBjA-siFCL6ViKk5hyw57jfuzSiZUvMwshrYv9m-MdVc", encryptedSecretKey: Data())
}

extension Array where Element == String {
    static let words24: [String] = {
        return (0...23).map { "Word \($0)" }
    }()
}
