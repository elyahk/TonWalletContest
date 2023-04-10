//
//  StartReducer.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//
import Foundation
import SwiftyTON
import ComposableArchitecture

struct StartReducer: ReducerProtocol {
    struct State: Equatable {
        var createWallet: CongratulationReducer.State?
        var importWallet: CongratulationReducer.State?
    }

    enum Action: Equatable {
        case createMyWalletTapped
        case importMyWalletTapped
        case keyCreated(key: Key, words: [String])
        case createWallet(PresentationAction<CongratulationReducer.Action>)
        case importWallet(CongratulationReducer.Action)
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .createMyWalletTapped:
    
                return .run { send in
                    let key = try await TonWalletManager.shared.createKey()
                    let words = try await TonWalletManager.shared.words(key: key)

                    await send(.keyCreated(key: key, words: words))
                }
                
            case .importMyWalletTapped:
//                state.destination = .createWallet(.init())
                #warning("Implement opening import wallet screen")
                return .none
                
            case let .keyCreated(key: key, words: words):
                state.createWallet = .init(words: words)
                return .none
                
            case .createWallet, .importWallet:
                return .none
            }
        }
        .ifLet(\.createWallet, action: /Action.createWallet) {
            CongratulationReducer()
        }
    }
}
